import 'package:diary_app/service/file_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  final FileService _fileService = FileService();

  // state
  // 날짜 문자열(yyyy-MM-dd) -> 해당 날짜의 DiaryEntry 목록 매핑
  Map<String, List<DiaryEntry>> _eventMap = {};
  bool _isLoading = true; // 로딩중
  DateTime _focusedDay = DateTime.now(); // 현재 달력에서 지정한 날자
  DateTime? _selectedDay; // 사용자가 선택한 날짜

  @override
  void initState() {
    super.initState();
    // 초기 선택 날짜를 오늘로 설정
    _selectedDay = DateTime.now();
    _loadEntries();
  }

  // 일기 목록 데이터 가져오기
  Future<void> _loadEntries() async {
    final entries = await _fileService.getDiaryEntries();
    final map = <String, List<DiaryEntry>>{};
    for (final e in entries) {
      // 같은 날짜의 여러 일기 누적
      // put : 넣다, 추가하다
      // If : ~한다면
      // absent : 없다, 부재
      // putIfAbsent : 첫번째 인자로 지정한 key(e.date/2026-03-31)가 없으면, 두 번째 인자의 함수를 실행 후 반환
      // 여기서는 해당 날짜 key 없으면, 새로운 [] 리스트를 생성하고, 반환
      // 반환된 [] 리스트에 add() 메서드로 날짜 객체를 추가

      // 첫번째 일기가 있다면(2026-03-31), () => [] 실행X
      map.putIfAbsent(e.date, () => []).add(e);
    }

    if ( mounted ) {
      setState(() {
        _eventMap = map;
        _isLoading = false;
      });
    }
  }

  // day 날짜에 해당하는 일기 목록을 반환하는 함수
  List<DiaryEntry> _eventsFor(DateTime day) {
    final key =
      "${day.year}-"
      "${day.month.toString().padLeft(2,'0')}-"
      "${day.day.toString().padLeft(2, '0')}";
    return _eventMap[key] ?? [];
  }

  // TableCalendar 날짜 탭 콜백함수
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final entries = _eventsFor(selectedDay);
    if( entries.isEmpty ) return;

    if ( entries.length == 1 ) {
      // TODO: 일기 상세화면으로 바로 이동
      _openDetail(entries.first);
    } else {
      // TODO: 일기 목록 PickerSheet 보여주기
      _showPickerSheet(entries);
    }
  }

  // 선택한 날짜의 일기 상세 화면으로 이동
  Future<void> _openDetail(DiaryEntry entry) async {
    await Navigator.pushNamed(context, '/detail',
      arguments: entry
    );
    // 상세 화면으로 갔다가, 뒤로가기하면 다시 목록 갱신
    _loadEntries();
  }

  // 같은 날짜에 일기가 2개 이상 있을 때
  // BottomSheet를 띄워서 목록에서 선택하도록 하는 함수
  void _showPickerSheet(List<DiaryEntry> entries) {
    showModalBottomSheet(
      context: context, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8,),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2)
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '${entries.first.date} - ${entries.length}개의 일기',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),  
          ),
          Divider(height: 0,),
          ListView.builder(
            shrinkWrap: true,
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final e = entries[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber.shade100,
                  child: Text('${i + 1}',
                    style: TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                title: Text(
                  e.title.isNotEmpty ? e.title : '(제목 없음)',
                  style: TextStyle(fontWeight: FontWeight.w600),                  
                ),
                subtitle: Text(e.time.isNotEmpty ? e.time : ''),
                trailing: Icon(Icons.chevron_right, color: Colors.grey,),
                onTap: () {
                  Navigator.pop(ctx);
                  _openDetail(e);
                }
              );
            },
          ),
          SizedBox(height: 12,)
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          }, 
          icon: Icon(Icons.home)
        ),
        title: Text('일기 달력'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
        ? Center(
          child: CircularProgressIndicator(
            color: Colors.amber,
          ),
        )
        : Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,    // 현재 달력 표시 기준 날짜
              firstDay: DateTime(2000),   // 이동 가능한 첫 날짜
              lastDay: DateTime(2100),    // 이동 가능한 끝 날짜
              // 선택된 날짜 강조 여부
              selectedDayPredicate: (day) => 
                isSameDay(_selectedDay, day),
              // 날짜 선택 시, 일기 목록을 반환하는 콜백 함수
              eventLoader: _eventsFor,
              // 날짜 선택 시, 콜백함수 
              onDaySelected: _onDaySelected,
              // 월 페이지가 바뀔 때, 콜백함수
              onPageChanged: (day) =>
                setState(() => _focusedDay = day),
              // ------ 스타일 -------
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.amber.shade300,
                  shape: BoxShape.circle
                ),
                todayTextStyle: TextStyle(
                  color: Colors.black
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle
                ),
                selectedTextStyle: TextStyle(
                  color: Colors.white
                ),
                // 마커 스타일 (점)
                markerDecoration: BoxDecoration(
                  color: Colors.deepOrange,
                  shape: BoxShape.circle
                ),
                // 마커 최대 개수
                markersMaxCount: 3,
                // 이번달 밖의 날짜 표시 여부
                outsideDaysVisible: false
              ),
              headerStyle: HeaderStyle(
                // 포맷 전환 버튼 표시 여부
                formatButtonVisible: false,
                // 헤더 월 제목 가운데 정렬
                titleCentered: true,
                // 헤더 월 제목 텍스트 스타일
                titleTextStyle: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold,
                ),
                // 왼쪽 화살표 아이콘
                rightChevronIcon: Icon(Icons.chevron_right),
                // 오른쪽 화살표 아이콘
                leftChevronIcon: Icon(Icons.chevron_left),
                // 헤더 패딩
                headerPadding: EdgeInsets.symmetric(vertical: 8),
                // 헤더 배경색
                decoration: BoxDecoration(
                  color: Colors.amber.shade50
                )
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                // 평일 텍스트 스타일
                weekdayStyle: TextStyle(color: Colors.black87),
                // 주말 텍스트 스타일
                weekendStyle: TextStyle(color: Colors.redAccent)
              ),
            ),
            Divider(height: 0,),
            Expanded(
              child: _buildSelectedDayList()
            )
          ],
        )
      ,
    );
  }
  // 선택된 날짜의 일기 목록 뷰
  Widget _buildSelectedDayList() {
    final entries = 
      _selectedDay == null ? [] : _eventsFor(_selectedDay!);

    if ( entries.isEmpty ) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note, size: 48, color: Colors.grey.shade300,),
            SizedBox(height: 12,),
            Text('이 날의 일기가 없습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            )
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[i];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber.shade100,
              child: Icon(Icons.book, color: Colors.amber,),
            ),
            title: Text(
              e.title.isNotEmpty ? e.title : '(제목 없음)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              e.time.isNotEmpty ? '작성 시각: ${e.time}' : e.date,
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey,),
            onTap: () => _openDetail(e),
          ),
        );
      },
    );
  }
}