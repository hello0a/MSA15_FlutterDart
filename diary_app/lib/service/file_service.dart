import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DiaryEntry {
  final String path; //일기 txt 파일 저장경로
  final String date; // 날짜
  final String time; // 시간
  final String title; // 일기 제목

  const DiaryEntry({
    required this.path,
    required this.date,
    required this.time,
    required this.title,
  });
}

// 파일 서비스
// - 파일 저장
// - 일기 목록
// - 일기 조회
// - 날짜 변경
// - 파일 삭제
const _seperator = '---DIARY---';
class FileService {
  // 앱 문서 디렉토리 경로 반환
  Future<String> getDirPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
  // 제목, 내용을 파일에 저장할 형식으로 변환
  String _serialize(String title, String content)
    => '$title\n$_seperator\n$content';
  // 일기 저장
  Future<void> saveDiaryForDate(
    String date, String title, String content
  ) async {
    final dirPath = await getDirPath();
    final now = DateTime.now();
    // 시간 포맷
    // - 052045 : 5시 20분 45초
    // - 110535 : 11시 5분 35초
    final t = 
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}'
    ;
    // 파일명 : 2026-03-27_131022.txt
    final file = File('$dirPath/${date}_$t.txt');
    await file.writeAsString(_serialize(title, content));
  }

  // 파일에서 제목 추출
  String parseTitleFromRaw(String raw) {
    final idx = raw.indexOf('\n$_seperator\n');
    if (idx == -1) return '';
    return raw.substring(0, idx);
  }
  // 파일에서 내용 추출
  String parseContentFromRaw(String raw) {
    final idx = raw.indexOf('\n$_seperator\n');
    final sep = '\n$_seperator\n';
    if (idx == -1) return raw;
    return raw.substring(idx + sep.length);
  }

  // 파일명에서 날짜 추출
  String getDateFromPath(String path) {
    final name =
      path.split(Platform.pathSeparator).last.replaceAll('.txt', '');
    return name.contains('_') ? name.split('_').first : name;
  }
  // 일기 목록 가져오기
  String getTimeFromPath(String path) {
    final name =
      path.split(Platform.pathSeparator).last.replaceAll('.txt', '');
    if (!name.contains('_')) return '';
    final t = name.split("_").last; // 165238
    if (t.length < 6 ) return '';
    return '${t.substring(0,2)}:${t.substring(2,4)}:${t.substring(4,6)}';
  }
  Future<List<DiaryEntry>> getDiaryEntries() async {
    final dirPath = await getDirPath();
    final dir = Directory(dirPath);
    // 저장 경로의 있는 모든 파일
    final all = dir.listSync();
    // 저장 경로의 .txt 파일만 추출
    final txts = all.where((e) => e.path.endsWith('.txt')).toList();
    // 정렬 : 날짜순으로 내림차순 (최신순)
    txts.sort((a, b) => b.path.compareTo(a.path));

    // .txt 리스트 -> List<DiaryEntry>
    final entries = <DiaryEntry>[];
    for (final f in txts) {
      String title = '';
      try {
        final raw = await File(f.path).readAsString();  // 텍스트파일 내용
        title = parseTitleFromRaw(raw); // 제목 추출
      } catch (_) {}
      entries.add(DiaryEntry(
        path: f.path, 
        date: getDateFromPath(f.path), 
        time: getTimeFromPath(f.path), 
        title: title)
      );
    }
    return entries;
  }

  /// 일기 조회
  /// - 파일 경로를 받아 해당 파일의 내용을 문자열로 반환
  Future<String> readDiaryRaw(String path) async =>
    File(path).readAsString();

  /// 날짜 변경
  /// - 기존 파일 경로, 새 날짜, 제목, 내용을 받아서 새파일로 저장
  /// - 기존 파일을 삭제
  /// - 새 경로를 반환
  /// 파일명 "date_time.txt" 형식으로 저장 (2026-03-30_ 105920.txt)
  Future<String> changeDiaryDate(
    String oldPath, String newDate, String title, String content
  ) async {
    final dirPath = await getDirPath();
    // 기본 파일명에서 시간 부분 추출(HHmmss)
    final name =
      oldPath.split(Platform.pathSeparator).last.replaceAll('.txt', '');
    final timePart = name.contains('_') ? name.split('_').last : '';
    final newPath = '$dirPath/${newDate}_$timePart.txt';

    await File(newPath).writeAsString(_serialize(title, content));
    await File(oldPath).delete();
    return newPath;
  }

  /// 일기 삭제
  /// - 파일 경로를 받아 해당 파일 삭제
  Future<void> deleteDiary(String path) async => File(path).delete();

  /// 다중 일기 삭제
  Future<void> deleteMultiple(List<String> paths) async {
    for (final p in paths) {
      await deleteDiary(p);
    }
  }

  // 기존 경로의 일기 저장
  Future<void> saveDiaryToPath(
    String path, String title, String content
  ) async {
    await File(path).writeAsString(_serialize(title, content));
  }

  // 일기 검색
  // - 검색어를 받아서 제목, 날짜, 내용에서 검색어가 포함된 여부를 조건으로 필터링
  // -- DiaryEntry 리스트로 반환
  Future<List<DiaryEntry>> searchEntries(String query) async {
    if ( query.trim().isEmpty ) return getDiaryEntries();
    final all = await getDiaryEntries();
    final q = query.toLowerCase();
    final result = <DiaryEntry>[];
    for (final entry in all) {
      if(
        entry.date.contains(q) ||
        entry.title.toLowerCase().contains(q)
      ) {
        result.add(entry);
        continue;
      }
      try {
        final raw = await readDiaryRaw(entry.path);
        final content = parseContentFromRaw(raw);
        if (content.toLowerCase().contains(q)) {
          result.add(entry);
        }
      } catch (_) {}
    }
    return result;
  }
}