import 'dart:async';

import 'package:diary_app/service/file_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // state
  List<DiaryEntry> _diaryList = [];
  List<DiaryEntry> _filteredList = [];
  // 다중 선택 삭제
  bool _isMultiSelect = false;
  Set<String> _selectedPaths = {};
  // 검색
  bool _isSearching = false;
  bool _isSearchLoading = false;
  final TextEditingController _searchController
    = TextEditingController();

  Timer? _debounce;

  // 파일
  final FileService _fileService = FileService();

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // 일기 목록 불러오기
  Future<void> _loadDiaries() async {
    final list = await _fileService.getDiaryEntries();
    if (mounted) {
      setState(() {
        _diaryList = list;
        _filteredList = _isSearching && _searchController.text.isNotEmpty
          ? _filteredList
          : list;
      });
    }
  }

  // 샘플 일기 목록
  // List<DiaryEntry> _diaryList = [
  //   DiaryEntry(
  //     path: '/storage/2026-03-27_1120.txt', 
  //     date: '2026-03-27', 
  //     time: '11:20', 
  //     title: '공부해야할 것이 한더미이다.'
  //   ),
  //   DiaryEntry(
  //     path: '/storage/2026-03-26_1120.txt', 
  //     date: '2026-03-26', 
  //     time: '18:20', 
  //     title: '짝꿍이 내일 안와서 슬프다.'
  //   ),
  //   DiaryEntry(
  //     path: '/storage/2026-03-25_1120.txt', 
  //     date: '2026-03-25', 
  //     time: '11:20', 
  //     title: '더벤티 피스타치오 먹고 싶다.'
  //   ),
  // ];

  // 단일 삭제
  Future<void> _deleteSingle(String path) async {
    await _fileService.deleteDiary(path);
    await _loadDiaries();
  }

  // 다중 선택 삭제
  void _startMultiSelect() => setState(() {
    _isMultiSelect = true;
    _selectedPaths.clear();
    // 검색 모드 초기화
    _searchController.clear();
    _filteredList = _diaryList;
  });

  void _stopMultiSelect() {
    setState(() {
      _isMultiSelect = false;
      _selectedPaths.clear();
    });
  }

  // 다중 삭제 처리
  Future<void> _deletedSelected() async {
    if( _selectedPaths.isEmpty ) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('선택 삭제'),
        content: Text(
          '${_selectedPaths.length}'
          '개의 일기를 삭제하시겠습니까?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: Text('취소')
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text('삭제', style: TextStyle(color: Colors.red),)
          ),
        ],
      )
    );
    if ( confirmed == true) {
      await _fileService.deleteMultiple(_selectedPaths.toList());
      _stopMultiSelect();
      _loadDiaries();
    }
  }

  // 검색
  // - 검색어(query)를 받아와서 검색된 목록으로 적용
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if ( query.trim().isEmpty ) {
      setState(() {
        _filteredList = _diaryList;
        _isSearchLoading = false;
      });
      return;
    }
    setState(() => _isSearchLoading = true);
    // 0.5초 후에 함수 실행
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await _fileService.searchEntries(query);
      if ( mounted ) {
        setState(() {
          _filteredList = results;
          _isSearchLoading = false;
        });
      }
    });
  }

  // 검색 모드
  void _startSearch() => setState(() {
    _isSearching = true;
    _isMultiSelect = false;
    _selectedPaths.clear();
  });

  // 검색 모드 해제
  void _stopSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _isSearchLoading = false;
      _filteredList = _diaryList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Widget 쪼개기 :)
  // -------[AppBar]-----------
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black,
      title:  _isSearching 
        ? TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '날짜(2026-03) 또는 제목/내용으로 검색',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.black45)
            ),
            style: TextStyle(color: Colors.black, fontSize: 16),
            onChanged: _onSearchChanged,
        )
        : const Text("hello_0's Dairy"),
      actions: [
        if (_isMultiSelect) ... [
          if(_selectedPaths.isNotEmpty) 
            IconButton(
              icon: Icon(Icons.delete_sweep),
              tooltip: '선택 삭제 (${_selectedPaths.length})',
              onPressed: _deletedSelected,
            ),
          TextButton(
            onPressed: _stopMultiSelect,
            child: Text('취소', style: TextStyle(color: Colors.black),)
          )
        ] else ... [
          // 검색 아이콘
          IconButton(
            onPressed: _isSearching ? _stopSearch : _startSearch, 
            tooltip: _isSearching ? '검색 닫기' : '검색',
            icon: Icon(_isSearching ? Icons.close : Icons.search)
          ),
          // 선택 삭제 아이콘
          IconButton(
            onPressed: _startMultiSelect, 
            tooltip: '선택 삭제 모드',
            icon: Icon(Icons.checklist_outlined)
          ),
        ]
      ],
    );
  }
  // --------[FloatingActionButton]---------
  FloatingActionButton? _buildFloatingActionButton() {
    return _isMultiSelect
      ? null
      : FloatingActionButton(
          onPressed: () async {
            await Navigator.pushNamed(context, "/write");
            // 목록 -> 작성 (작성 완료 후 pop이 되면 목록 갱신)
            _loadDiaries();
          },
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          child: const Icon(Icons.edit),
        );
  }
  // --------[body]-------------
  Widget _buildBody() {
    // 검색 로딩
    if ( _isSearchLoading ) {
      return Center(
        child: CircularProgressIndicator(color: Colors.amber,),
      );
    }
    // 검색된 데이터가 없는 경우
    if ( _filteredList.isEmpty ) {
      return Center(
        child: Text(
          _isSearching && _searchController.text.isNotEmpty
            ? '검색 결과가 없습니다.'
            : '작성된 일기가 없습니다.\n일기를 써보세요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return _isMultiSelect ? _buildMultiSelectList() : _buildList();
  }

  // 일반 목록
  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final entry = _filteredList[index];
        final date = entry.date;
        final time = entry.time;

        return Dismissible(
          key: Key(entry.path),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            margin: EdgeInsets.symmetric(
              vertical: 6, horizontal: 4
            ),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete, 
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(height: 4,),
                Text('삭제', style: TextStyle(
                  color: Colors.white, fontSize: 12
                ),)
              ],
            ),
          ),
          confirmDismiss: (_) => showDialog<bool>(
            context: context, 
            builder: (ctx) => AlertDialog(
              title: Text("일기 삭제"),
              content: Text('[$date] 일기를 삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false), 
                  child: Text('취소')
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true), 
                  child: Text('삭제',
                    style: TextStyle(color: Colors.red),
                  )
                ),
              ],
            )
          ),
          onDismissed: (_) => _deleteSingle(entry.path),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber.shade100,
                child: const Icon(Icons.book, color: Colors.amber,),
              ),
              title: Text(entry.title,),
              subtitle: Text(date, style: TextStyle(fontSize: 10.0),),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey,),
              onTap: () async {
                // 상세 화면으로 이동
                await Navigator.pushNamed(context, '/detail',
                  arguments: entry
                );
                // 상세화면 이동 후, 뒤로가기 했을 때 일기목록 다시 로드
                _loadDiaries();
              },
            ),
          ),
        );
      }
    );
  }
  // 다중 선택 목록
  Widget _buildMultiSelectList() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.amber.shade50,
          child: Row(
            children: [
              Text(
                _selectedPaths.isEmpty
                  ? '삭제할 일기를 선택하세요'
                  : '${_selectedPaths.length}개 선택됨',
                style: TextStyle(
                  color: _selectedPaths.isEmpty
                    ? Colors.grey
                    : Colors.amber.shade800,
                  fontWeight: FontWeight.bold
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                  // 검색 적용 시 _diaryList -> _filteredList 변경 필요 
                    // 전체 선택 중인 경우 => 전체 해제
                    if (_selectedPaths.length == _filteredList.length) {
                      _selectedPaths.clear();
                    } else {
                      _selectedPaths = _filteredList.map((e) => e.path).toSet();
                    }
                  });
                }, 
                child: Text(
                  // 검색 적용 시 _diaryList -> _filteredList 변경 필요 
                  _selectedPaths.length == _filteredList.length
                    ? '전체 해제'
                    : '전체 선택',
                  style: TextStyle(color: Colors.amber),
                )
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _filteredList.length,
            itemBuilder: (context, index) {
              final entry = _filteredList[index];
              final date = entry.date;
              final isSelected = _selectedPaths.contains(entry.path);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: isSelected
                    ? BorderSide(color: Colors.amber, width: 2)
                    : BorderSide(color: Colors.grey.shade300)
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      if( isSelected ) {
                        _selectedPaths.remove(entry.path);
                      } else {
                        _selectedPaths.add(entry.path);
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 12, vertical: 12
                    ),
                    child: Row(
                      children: [
                        Icon(isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                          color: isSelected
                          ? Colors.amber
                          : Colors.grey,
                          size: 26,
                        ),
                        SizedBox(width: 14,),
                        Icon(Icons.book, color: Colors.amber,),
                        SizedBox(width: 12,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.title, style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                              ),),
                              Text(
                                '${entry.date} ${entry.time}',
                                style: TextStyle(
                                  fontSize: 12, color: Colors.grey
                                ),
                              )
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                )
              );
            }
          )
        ),
        if( _selectedPaths.isNotEmpty ) 
        SafeArea(
          child: Padding( 
            padding: EdgeInsets.fromLTRB(16, 8, 16, 80 + MediaQuery.of(context).padding.bottom + 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _deletedSelected, 
                icon: Icon(Icons.delete_forever),
                label: Text('${_selectedPaths.length}개 일기 삭제'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold
                  )
                )
              )
            ),
          )
        )
      ],
    );
  }

  // ----- [Drawer] -----
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // 열리면 이것도 한 스택으로 추가되는 것
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.amber),
            child: SizedBox(
              width: double.infinity, // 가로 100%
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.menu_book, size: 48, color:  Colors.white,),
                  SizedBox(height: 8,),
                  Text("hello_0 다이어리",
                    style: TextStyle(
                      color:  Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            )
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text("달력으로 보기"),
                  onTap: () {
                    // 쌓이지 않은 채 화면 전환
                    Navigator.pushReplacementNamed(context, "/calendar");
                  },
                ),
                ListTile(
                  tileColor: const Color.fromARGB(127, 252, 238, 161),
                  leading: const Icon(Icons.list_alt),
                  title: const Text("일기 목록"),
                  onTap: () {
                    // 쌓인 채 화면 전환
                    Navigator.pushNamed(context, "/home");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.search_rounded),
                  title: const Text("일기 검색"),
                  onTap: () {
                    Navigator.pop(context);
                    // 검색 모드로 상태 업데이트
                    _startSearch();
                  },
                ),
                ListTile(
                  tileColor: const Color.fromARGB(127, 252, 238, 161),
                  leading: const Icon(Icons.checklist_rounded),
                  title: const Text("선택 삭제"),
                  onTap: () {
                    Navigator.pop(context);
                    // 선택 삭제 모드로 상태 업데이트
                    _startMultiSelect();
                  },
                ),
              ],
            )
          ),
          Spacer(),
          Divider(),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text("새 일기 쓰기", style: TextStyle(fontWeight: FontWeight.w600),),
            onTap: () async {
              Navigator.pop(context); // Drawer 제거
              await Navigator.pushNamed(context, "/write");
              _loadDiaries();
            },
          ),
        ],
      ),
    );
  }
}