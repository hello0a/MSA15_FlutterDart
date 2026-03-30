import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:diary_app/service/file_service.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  final FileService _fileService = FileService();

  String path = '';
  String date = '';
  String time = '';

  String _title = '';
  String _content = '';
  bool _isInit = false;
  bool _isLoading = true;
  bool _isEditing = false;

  late DateTime _selectedDate;
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override 
  void initState() {
    super.initState();
    // _selectedDate = DateTime.tryParse(date) ?? DateTime.now();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override 
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _contentController.dispose();
  }

  @override 
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      // 데이터 전달받기
      DiaryEntry entry = ModalRoute.of(context)!.settings.arguments as DiaryEntry;

      path = entry.path;
      date = entry.date;
      time = entry.time;

      _selectedDate = DateTime.tryParse(date) ?? DateTime.now();
      _loadContent();   // 일기 정보 조회
      _isInit = true;
    }
  }

  Future<void> _loadContent() async {
    // 결로로 일기 텍스트 파일 읽어오기
    final raw = await _fileService.readDiaryRaw(path);
    // 텍스트파일 데이터로부터, 제목/내용 가져오기
    final parsedTitle = _fileService.parseTitleFromRaw(raw);
    final parsedContent = _fileService.parseContentFromRaw(raw);

    setState(() {
      _title = parsedTitle;
      _content = parsedContent;
      _titleController.text = parsedTitle;
      _contentController.text = parsedContent;
      _isLoading = false;
    });
  }

  // 날짜 형식 함수
  String get _selectedDateStr =>
   '${_selectedDate.year}-'
   '${_selectedDate.month.toString().padLeft(2, '0')}-'
   '${_selectedDate.day.toString().padLeft(2, '0')}';

  // 날짜 선택
  Future<void> _pickDate() async {
    final result = await showCalendarDatePicker2Dialog(
      context: context, 
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        selectedDayHighlightColor: Colors.amber,
        okButton: Text('확인', style: TextStyle(color: Colors.amber),),
        cancelButton: Text('취소')
      ), 
      dialogSize: Size(325, 400),
      borderRadius: BorderRadius.circular(15),
      value: [_selectedDate]
    );
    if (result != null && result.isNotEmpty && result.first != null) {
      setState(() => _selectedDate = result.first! );
    }
  }

  // 수정
  Future<void> _saveEdit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목을 입력해주세요.'))
      );
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내용을 입력해주세요.'))
      );
      return;
    }
    // 날짜가 변경된 경우, 파일 이름도 변경
    if ( _selectedDateStr != date ) {
      await _fileService.changeDiaryDate(
        path, _selectedDateStr, title, content
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정되었습니다!'))
        );
        Navigator.pop(context);
      }
      return;
    }
    // 일기 제목, 내용 저장
    await _fileService.saveDiaryToPath(path, title, content);

    setState(() {
      _title = title;
      _content = content;
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정되었습니다!'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLoading ? date : (_title.isNotEmpty ? _title : date),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              '${ date } / ${ time }',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        actions: [
          if ( !_isLoading )
            _isEditing
            ? // 수정모드
              IconButton(
                onPressed: _saveEdit, // TODO: 저장함수 연결
                icon: Icon(Icons.check),
                tooltip: '저장',
              )
            : // 읽기모드
              IconButton(
                onPressed: () => setState(() =>
                  _isEditing = true
                ),
                icon: Icon(Icons.edit),
                tooltip: '저장',
              )
        ],
      ),
      bottomSheet: !_isEditing ? null : SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isEditing
                ? _saveEdit
                : null, 
                icon: !_isEditing
                // 읽기모드
                ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black,
                  ),
                )
                : Icon(Icons.edit_note, size: 22,),
                // 수정모드
                label: Text(
                  '수정하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, 
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12)
                    )
                  ),
                ),
              ),
            )
          ),
      body: _isLoading
        ? // 로딩 중
          Center(child: CircularProgressIndicator(color: Colors.amber,),)
        : _isEditing
        ? // 수정 모드
        Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 88),
          child: Column(
            children: [
              // 날짜 선택
              InkWell(
                onTap: _pickDate, // TODO: 날짜 선택,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: 
                      Border.all(color: Colors.amber, width: 1.5)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.amber,),
                      SizedBox(width: 12,),
                      Expanded(child: Text(
                        '날짜 : $_selectedDateStr',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                        ),
                      )),
                      Text('변경', style: TextStyle(
                        color: Colors.grey, fontSize: 13
                      ),)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12,),
              // 제목
              TextField(
                controller: _titleController,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: '제목',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFFFFDE7),
                  prefixIcon: Icon(Icons.title, color: Colors.amber,),
                ),
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 12,),
              // 내용
              Expanded(child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: '내용',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFFFFDE7),
                ),
                style: TextStyle(fontSize: 16, height: 1.6),
              ))
            ],
          ),
        )
        : // 읽기 모드
        SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold
                ),
              ),
              Divider(height: 24, thickness: 1,),
              Text(
                _content,
                style: TextStyle(fontSize: 16, height: 1.8),
              )
            ],
          ),
        ),
    );
  }
}