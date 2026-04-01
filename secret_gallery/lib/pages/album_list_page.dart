import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:secret_gallery/models/album.dart';
import 'package:secret_gallery/services/auth_service.dart';
import 'package:secret_gallery/services/db_service.dart';

/// 앨범 목록 정렬 방식
enum _SortType { custom, newest, oldest, nameAZ, nameZA }


class AlbumListPage extends StatefulWidget {
  const AlbumListPage({super.key});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  final _db =DbService();   // DB 서비스 인스턴스
  List<Album> _albums = [];   // 전체 앨범 목록

  // 다중선택
  final Set<int> _selectedIds = {}; // 현재 선택한 앨범 ID SET
  final Map<int, GlobalKey> _itemKeys = {}; // 드래그 선택을 위한 카드형 GlobalKey
  bool get _isSelecting => _selectedIds.isNotEmpty; // 하나라도 선택 중이면 true

  // 검색
  bool _isSearching = false;  // 검색 모드 활성화 여부
  String _searchQuery = '';   // 현재 검색어
  final TextEditingController _searchController = TextEditingController();

  // 정렬
  _SortType _sortType = _SortType.newest;   // 현재 정렬 방식 (기본: 최신순)
  final _reorderScrollController = ScrollController(); // 드래그 정렬 그리드용 스크롤 컨트롤러
  bool _customSortSelectMode = false; // 직접 정렬 모드에서 선택 삭제 활성화 여부
  bool get _showSelectAppBar => _selectedIds.isNotEmpty || _customSortSelectMode; // AppBar 표시 조건

  // 검색어, 정렬 조건이 적용된 앨범 목록
  List<Album> get _displayedAlbums {
    var list = _searchQuery.isEmpty 
      ? List<Album>.from(_albums)
      : _albums
        .where((a) =>
          a.name.toLowerCase().contains(_searchQuery.toLowerCase())
        )
        .toList();
    switch (_sortType) {
      case _SortType.custom:
        break;
      case _SortType.newest:
        list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      case _SortType.oldest:
        list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      case _SortType.nameAZ:
        list.sort((a, b) => (a.name).compareTo(b.name));
      case _SortType.nameZA:
        list.sort((a, b) => (b.name).compareTo(a.name));
    } 
    return list;
  }

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reorderScrollController.dispose();
    super.dispose();
  }

  // 앨범 목록 조회
  Future<void> _loadAlbums() async {
    final albums = await _db.getAlbums();
    setState(() => _albums = albums);
  }

  // 검색 모드 시작
  void _startSearch() => setState(() => _isSearching = true);

  // 검색 모드 종료
  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  // 앨범 선택 상태 토글
  void _toggleSelect(int id) {
    HapticFeedback.selectionClick();  // 터치에 반응하는 기능
    setState(() {
      if (_selectedIds.contains(id)) _selectedIds.remove(id);
      else _selectedIds.add(id);
    });
  }

  // 전체 선택 해제
  void _clearSelection() => setState(() {
    _selectedIds.clear();
    _customSortSelectMode = false;
  });

  // 드래그 선택
  void _selectAtPos(Offset globalPos) {
    for (final entry in _itemKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect.contains(globalPos) && !_selectedIds.contains(entry.key)) {
        setState(() => _selectedIds.add(entry.key));
        HapticFeedback.selectionClick();
        break;
      }
    }
  }

  // 선택 삭제
  Future<void> _deleteSelected() async {
    final ok = await showDialog<bool>(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text('앨범 삭제'),
        content: Text(
          '선택한 ${_selectedIds.length}개의 앨범을 삭제할까요?\n'
          '앨범 안의 모든 사진도 삭제합니다.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: Text('취소')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('삭제', style: TextStyle(color: Colors.white),)
          )
        ],
      )
    );
    if (ok == true) {
      for (final id in List.from(_selectedIds)) {
        await _db.deleteAlbum(id);
      }
      _clearSelection();
      _loadAlbums();
    }
  }

  // UI

  /// 새 앨범 생성 다이얼로그를 표시하고, 확인 시 DB에 저장한다.
  void _showCreateAlbumDialog() {
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    bool isSecret = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('앨범 만들기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '앨범 이름'),
              ),
              Row(
                children: [
                  const Text('비밀 앨범'),
                  Switch(
                    value: isSecret,
                    onChanged: (v) => setDialogState(() => isSecret = v),
                  ),
                ],
              ),
              if (isSecret)
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '앨범 비밀번호'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final album = Album(
                  name: name,
                  type: isSecret ? 'secret' : 'normal',
                  password: isSecret ? passwordController.text.trim() : null,
                );
                await _db.insertAlbum(album);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadAlbums();
              },
              child: const Text('만들기'),
            ),
          ],
        ),
      ),
    );
  }

  /// 앨범을 연다. 비밀 앨범이면 비밀번호 확인 후 진입한다.
  Future<void> _openAlbum(Album album) async {
    if (album.type == 'secret') {
      final confirmed = await _showPasswordDialog(album.password);
      if (!confirmed) return;
    }

    if (!mounted) return;
    // 사진 목록으로 이동
    await Navigator.of(context).pushNamed('/photo', arguments: album);
    _loadAlbums();
  }

  /// 비밀 앨범 접근 시 비밀번호 입력 다이얼로그를 표시하고 인증 결과를 반환한다.
  Future<bool> _showPasswordDialog(String? correctPassword) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('비밀 앨범'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: '비밀번호를 입력하세요'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          ElevatedButton(
            onPressed: () => Navigator.pop(
                ctx, AuthService().checkAlbumPassword(correctPassword, ctrl.text.trim())),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    if (ok != true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('비밀번호가 틀렸습니다.')));
    }
    return ok == true;
  }

  /// 정렬 팝업 메뉴 아이템을 생성한다. 현재 선택된 항목은 파란색으로 강조된다.
  PopupMenuItem<_SortType> _sortMenuItem(
      _SortType value, String label, IconData icon) {
    final selected = _sortType == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: selected ? Colors.blueAccent : Colors.white70),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: selected ? Colors.blueAccent : Colors.white,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // ─── 앨범 카드 공통 위젯 ─────────────────────────────────────
  /// 앨범 카드를 빌드한다.
  /// [reorderMode]가 true이면 드래그 핸들을 표시하며 선택 기능을 비활성화한다.
  Widget _buildAlbumCard(Album album, {bool reorderMode = false}) {
    final id = album.id!;
    final isSelected = _selectedIds.contains(id);
    return GestureDetector(
      key: ValueKey<String>('album_$id'),
      onTap: reorderMode
          ? () => _openAlbum(album)
          : (_showSelectAppBar ? () => _toggleSelect(id) : () => _openAlbum(album)),
      onLongPress: reorderMode ? null : () => _toggleSelect(id),
      child: AnimatedContainer(
        key: reorderMode ? null : _itemKeys.putIfAbsent(id, () => GlobalKey()),
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected && !reorderMode
              ? Colors.blue.withOpacity(0.25)
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected && !reorderMode
                ? Colors.blueAccent
                : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  album.type == 'secret'
                      ? Icons.lock
                      : Icons.photo_album_rounded,
                  size: 52,
                  color: album.type == 'secret'
                      ? Colors.amber
                      : Colors.blue[300],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    album.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  album.type == 'secret' ? '비밀 앨범' : '일반 앨범',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
            if (isSelected && !reorderMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
            if (reorderMode)
              const Positioned(
                top: 8,
                right: 8,
                child:
                    Icon(Icons.drag_handle, color: Colors.white38, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  /// 일반(검색·정렬) 모드에서 사용하는 고정 그리드를 빌드한다.
  /// 선택 중일 때는 스크롤을 막고 드래그 선택([_selectAtPos])을 활성화한다.
  Widget _buildNormalGrid() {
    // Listener : 드래그 선택을 위한 이벤트 감지 위젯
    return Listener(
      // 그리드 전체에서 포인터 이벤트를 감지하도록 설정
      behavior: HitTestBehavior.translucent,
      // 포인터가 움직일 때 이벤트
      onPointerMove: (e) {
        if (_isSelecting) _selectAtPos(e.position);
      },
      child: GridView.builder(
        // physics : 스크롤 물리 효과를 설정하는 속성
        physics: _isSelecting
            // Never~ : 스크롤 비활성화
            ? const NeverScrollableScrollPhysics()
            // Bouncing : 바운스 효과로 스크롤 효과
            : const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        // 그리드 뷰 설정
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,    // 컬럼 개수
          crossAxisSpacing: 12, // 컬럼 간격
          mainAxisSpacing: 12,  // 행 사이 간격
          childAspectRatio: 0.9,  // 아이템의 가로 세로 비율
        ),
        itemCount: _displayedAlbums.length,
        itemBuilder: (_, index) => _buildAlbumCard(_displayedAlbums[index]),
      ),
    );
  }

  /// 직접 정렬([_SortType.custom]) 모드에서 사용하는 드래그 재정렬 그리드를 빌드한다.
  /// 순서 변경 시 DB의 sort_order를 즉시 업데이트한다.
  Widget _buildReorderableGrid() {
    final children =
        _albums.map((a) => _buildAlbumCard(a, reorderMode: true)).toList();
    return ReorderableBuilder<Album>(
      scrollController: _reorderScrollController,
      children: children,
      // 카드 옮겼을 때 재정렬
      onReorder: (reorderCallback) {
        setState(() {
          _albums = reorderCallback(_albums);
        });
        // 앨범 순서 업데이트
        _db.updateAlbumSortOrders(_albums.map((a) => a.id!).toList());
      },
      builder: (updatedChildren) {
        return GridView(
          controller: _reorderScrollController,
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          children: updatedChildren,
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // PopScope : 뒤로가기를 제어하는 위젯
    return PopScope(
      // * canPop : pop 가능 여부
      // 지금 화면에서 뒤로가기 가능한지 여부 지정
      // 선택모드도 아니고 검색모드도 아닌 경우 pop 가능
      canPop: !_showSelectAppBar && !_isSearching,
      // 뒤로가기 처리
      onPopInvokedWithResult: (didPop, result) {
        // 뒤로가기가 막힌 경우
        if (!didPop) {
          // 선택모드 및 검색모드 종료
          if (_showSelectAppBar) _clearSelection();
          if (_isSearching) _stopSearch();
        }
      },
      child: Scaffold(
        appBar: _showSelectAppBar
            // 선택 모드
          ? AppBar(
            backgroundColor: Colors.blueGrey[800],
            foregroundColor: Colors.white,
            leading: IconButton(
              onPressed: _clearSelection, 
              icon: Icon(Icons.close)
            ),
            title: Text('${_selectedIds.length}개 선택됨'),
            actions: [
              IconButton(
                onPressed: _deleteSelected, 
                icon: Icon(Icons.delete),
                tooltip: '선택 삭제',
              )
            ],
          )
            // 일반 모드
          : AppBar(
            title: _isSearching
                // 검색 모드
              ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: '앨범 이름 검색...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
                // 기본 모드
              : Text('시크릿 갤러리')
            ,
            centerTitle: !_isSearching,
            backgroundColor: Colors.grey[900],
            foregroundColor: Colors.white,
            leading: _isSearching
              ? IconButton(
                onPressed: _stopSearch, 
                icon: Icon(Icons.arrow_back)
              )
              : null
            ,
            actions: 
              _isSearching
              ? [
                if(_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    }, 
                  ),
              ]
              : [
                IconButton(
                  onPressed: _startSearch,
                  icon: Icon(Icons.search),
                  tooltip: '검색',
                ),
                PopupMenuButton<_SortType>(
                  icon: Icon(Icons.sort),
                  tooltip: '정렬',
                  color: Colors.grey[850],
                  onSelected: (v) => setState(() => _sortType = v ),
                  itemBuilder: (_) => [
                    _sortMenuItem(_SortType.custom, '직접 정렬',
                        Icons.touch_app),
                    _sortMenuItem(_SortType.newest, '최신순',
                        Icons.schedule),
                    _sortMenuItem(_SortType.oldest, '오래된순',
                        Icons.history),
                    _sortMenuItem(
                        _SortType.nameAZ, '이름 ㄱ→ㅎ', Icons.sort_by_alpha),
                    _sortMenuItem(
                        _SortType.nameZA, '이름 ㅎ→ㄱ', Icons.sort_by_alpha),
                  ],
                ),
                if (_sortType == _SortType.custom)
                  IconButton(
                    onPressed: () => setState(
                      () => _customSortSelectMode = true
                    ), 
                    icon: Icon(Icons.checklist),
                    tooltip: '선택 삭제',
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/setting'),
                    icon: Icon(Icons.settings),
                    tooltip: '설정',
                  )
              ]
            ,
          ),
          backgroundColor: Colors.grey[850],
          body: _albums.isEmpty
            ? Center(
              child: Text(
                '앨범이 없습니다\n+ 버튼을 눌러서 앨범을 만들어보세요!',
                style: TextStyle(color: Colors.white54, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
            : _displayedAlbums.isEmpty
              ? Center(
                child: Text(
                  '검색 결과가 없습니다.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              )
              // 직접 정렬 and 검색모드 아님 and 선택모드 아님
              : (_sortType == _SortType.custom && !_isSearching && !_showSelectAppBar )
                ? _buildReorderableGrid()   // 정렬가능한 그리드뷰
                : _buildNormalGrid()        // 일반 그리드뷰
        ,
        floatingActionButton: _isSelecting
          ? null
          : FloatingActionButton(
            onPressed: _showCreateAlbumDialog,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: Icon(Icons.add),
          ),
      ),
    );
  }
}