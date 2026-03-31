import 'package:path/path.dart';
import 'package:secret_gallery/models/album.dart';
import 'package:secret_gallery/models/photo.dart';
import 'package:sqflite/sqflite.dart';

class DbService {

 // 싱글턴 DB 인스턴스 — 앱 수명 동안 1개만 유지
  static Database? _db;
  // getter: _db가 null이면 초기화, 아니면 기존 인스턴스 반환
  Future<Database> get db async {
    _db ??= await _initDB();
    return _db!;
  }
  Future<Database> _initDB() async {
    // getDatabasesPath(): 플랫폼별 DB 저장 디렉토리 경로 반환
    // join(): path 패키지로 경로 + 파일명 결합 (플랫폼 구분자 자동 처리)
    final path = join(await getDatabasesPath(), 'gallery.db');

    // openDatabase(): DB 파일을 열거나 없으면 생성
    //   version    — 스키마 버전 (올릴 때마다 onUpgrade 실행)
    //   onCreate   — 최초 생성 시 1회 실행
    //   onUpgrade  — version이 이전보다 높을 때 실행
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        // db.execute(): SQL DDL 직접 실행 (CREATE, ALTER, DROP 등)
        await db.execute('''
          CREATE TABLE albums (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            password TEXT,
            sort_order INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE photos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            album_id INTEGER NOT NULL,
            path TEXT NOT NULL,
            title TEXT,
            memo TEXT,
            created_at TEXT NOT NULL,
            sort_order INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // v1 → v2: albums에 sort_order 컬럼 추가
        if (oldVersion < 2) {
          // ALTER TABLE: 기존 테이블에 컬럼 추가 (데이터 보존)
          await db.execute(
              'ALTER TABLE albums ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0');
          // db.query(): SELECT 쿼리, 결과는 List<Map<String, dynamic>>
          final albums = await db.query('albums', orderBy: 'id ASC');
          for (int i = 0; i < albums.length; i++) {
            // db.update(): WHERE 조건에 맞는 행의 컬럼 값 변경
            //   where의 ?는 whereArgs로 순서대로 바인딩 (SQL 인젝션 방지)
            await db.update(
              'albums',
              {'sort_order': i},
              where: 'id = ?',
              whereArgs: [albums[i]['id']],
            );
          }
        }
        // v2 → v3: photos에 sort_order 컬럼 추가
        if (oldVersion < 3) {
          await db.execute(
              'ALTER TABLE photos ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0');
          final photos = await db.query('photos', orderBy: 'id ASC');
          for (int i = 0; i < photos.length; i++) {
            await db.update(
              'photos',
              {'sort_order': i},
              where: 'id = ?',
              whereArgs: [photos[i]['id']],
            );
          }
        }
      },
    );
  } 

  // ─── Album CRUD ───────────────────────────────────────────────
  Future<int> insertAlbum(Album album) async {
    final database = await db;
    // rawQuery(): 자유 형식 SQL SELECT 실행 — query()로 표현하기 어려운 집계 함수에 사용
    // MAX(sort_order): 현재 가장 큰 순서값 조회 → 새 앨범을 맨 뒤에 배치
    final result =
        await database.rawQuery('SELECT MAX(sort_order) as max_o FROM albums');
    final maxOrder = (result.first['max_o'] as int?) ?? -1;
    final map = album.toMap()
      ..remove('id') // AUTOINCREMENT이므로 id는 DB가 자동 할당
      ..['sort_order'] = maxOrder + 1;
    // insert(): Map을 테이블에 삽입, 생성된 id(rowid) 반환
    return database.insert('albums', map);
  }
  Future<List<Album>> getAlbums() async {
    final database = await db;
    // query(): SELECT 쿼리를 파라미터로 구성
    //   orderBy — ORDER BY sort_order ASC (사용자 지정 순서대로)
    final rows = await database.query('albums', orderBy: 'sort_order ASC');
    return rows.map(Album.fromMap).toList();
  }
  Future<void> updateAlbumSortOrders(List<int> orderedIds) async {
    final database = await db;
    // batch(): 여러 SQL을 하나의 트랜잭션으로 묶어 일괄 실행
    //   → 개별 update() 반복보다 훨씬 빠름
    final batch = database.batch();
    for (int i = 0; i < orderedIds.length; i++) {
      // batch.update(): 실제 실행은 commit() 시점에 일괄 처리
      batch.update(
        'albums',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [orderedIds[i]],
      );
    }
    // commit(): 배치에 쌓인 모든 SQL을 트랜잭션으로 실행
    //   noResult: true — 각 쿼리의 결과값이 필요 없을 때 메모리 절약
    await batch.commit(noResult: true);
  }
  Future<void> updateAlbumPassword(int id, String? newPassword) async {
    final database = await db;
    // update(): 지정 컬럼만 부분 업데이트 (null 전달 시 DB에 NULL 저장)
    await database.update(
      'albums',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> deleteAlbum(int id) async {
    final database = await db;
    // delete(): WHERE 조건에 맞는 행 삭제
    await database.delete('albums', where: 'id = ?', whereArgs: [id]);
    // 앨범 삭제 시 소속 사진 레코드도 연쇄 삭제 (파일 삭제는 FileService에서 별도 처리)
    await database.delete('photos', where: 'album_id = ?', whereArgs: [id]);
  }

  // ─── Photo CRUD ───────────────────────────────────────────────
  Future<int> insertPhoto(Photo photo) async {
    final database = await db;
    // rawQuery()의 ?에 두 번째 인수로 바인딩값 전달 (positional parameters)
    // WHERE album_id = ? → 해당 앨범 내 사진의 최대 sort_order만 조회
    final result = await database.rawQuery(
        'SELECT MAX(sort_order) as max_o FROM photos WHERE album_id = ?',
        [photo.albumId]);
    final maxOrder = (result.first['max_o'] as int?) ?? -1;
    final map = photo.toMap()
      ..remove('id')
      ..['sort_order'] = maxOrder + 1;
    return database.insert('photos', map);
  }
  Future<List<Photo>> getPhotos(int albumId) async {
    final database = await db;
    // query()의 where + whereArgs: SQL 인젝션 방지를 위해 값은 항상 whereArgs로 분리
    final rows = await database.query(
      'photos',
      where: 'album_id = ?',
      whereArgs: [albumId],
      orderBy: 'sort_order ASC',
    );
    return rows.map(Photo.fromMap).toList();
  }
  Future<void> updatePhotoSortOrders(List<int> orderedIds) async {
    final database = await db;
    // updateAlbumSortOrders()와 동일한 batch 패턴, 대상 테이블만 photos로 다름
    final batch = database.batch();
    for (int i = 0; i < orderedIds.length; i++) {
      batch.update(
        'photos',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [orderedIds[i]],
      );
    }
    await batch.commit(noResult: true);
  }
  Future<void> updatePhotoMeta(int id, String title, String memo) async {
    final database = await db;
    // update()로 여러 컬럼을 Map에 묶어 한 번에 UPDATE
    await database.update(
      'photos',
      {'title': title, 'memo': memo},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> deletePhoto(int id) async {
    final database = await db;
    await database.delete('photos', where: 'id = ?', whereArgs: [id]);
  }
}