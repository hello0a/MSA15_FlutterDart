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

  // 파일
  final FileService _fileService = FileService();

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  // 일기 목록 불러오기
  Future<void> _loadDiaries() async {
    final list = await _fileService.getDiaryEntries();
    if (mounted) {
      setState(() {
        _diaryList = list;
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
      title: const Text("hello_0's Dairy"),
      actions: [
        // 오른쪽 검색/선택 아이콘
        IconButton(
          onPressed: () {}, 
          icon: Icon(Icons.search)
        ),
        IconButton(
          onPressed: () {}, 
          icon: Icon(Icons.checklist_outlined)
        ),
      ],
    );
  }
  // --------[FloatingActionButton]---------
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
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
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _diaryList.length,
      itemBuilder: (context, index) {
        final entry = _diaryList[index];
        final date = entry.date;
        final time = entry.time;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber.shade100,
              child: const Icon(Icons.book, color: Colors.amber,),
            ),
            title: Text(entry.title,),
            subtitle: Text(date, style: TextStyle(fontSize: 10.0),),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey,),
            onTap: () {},
          ),
        );
      }
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
                    // TODO: 검색 모드로 상태 업데이트
                  },
                ),
                ListTile(
                  tileColor: const Color.fromARGB(127, 252, 238, 161),
                  leading: const Icon(Icons.checklist_rounded),
                  title: const Text("선택 삭제"),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: 선택 삭제 모드로 상태 업데이트
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