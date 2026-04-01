import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:diary_app/service/file_service.dart';
import 'package:flutter/material.dart';

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {

// 날짜 선택
  DateTime _selectedDate = DateTime.now();
  String get _selectedDateStr => _selectedDate.toString().substring(0, 10);

// 컨트롤러
final TextEditingController _titleController = TextEditingController();
final TextEditingController _contentController = TextEditingController();

// 저장
bool _isSaving = false;
final FileService _fileService = FileService();

@override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

// 날짜 선택 Dialog
  Future<void> _pickDate() async {
    final result = await showCalendarDatePicker2Dialog(
      context: context, 
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        selectedDayHighlightColor: Colors.amber,
        okButton: 
          const Text('확인', style: TextStyle(color: Colors.amber),),
        cancelButton:
          const Text('취소'),
      ), 
        dialogSize: const Size(325, 400),
        borderRadius: BorderRadius.circular(15),
        value: [_selectedDate],
      );
      if ( result != null && result.isNotEmpty && result.first != null ) {
        setState(() => _selectedDate = result.first!);
      }
  }

  // 저장
  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty) {
      // 스낵바
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }
    if (content.isEmpty) {
      // 스낵바
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.')),
      );
      return;
    }
    // 저장중(T) -> 저장 요청 -> 저장중(F)
    setState(() => _isSaving = true);
    await _fileService.saveDiaryForDate(_selectedDateStr, title, content);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("일기가 저장되었습니다.")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("일기 작성"),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _save, 
            icon: _isSaving
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2,),
              )
              : Icon(Icons.save)
          )
        ]
      ),
      bottomSheet: SafeArea(
        child: Padding(
          // padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          // 하단에 있는 시스템 Navigation Bar 위로 BottomSheet 버튼 겹치는 문제 해결
          padding: EdgeInsets.fromLTRB(16, 8, 16, 80 + MediaQuery.of(context).padding.bottom + 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              label: const Text(
                "작성하기",
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold
                ),
              ),
              icon: _isSaving
                ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black,
                  ),
                ) 
                : const Icon(Icons.edit_note, size: 22,),
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          children: [
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.amber,),
                    const SizedBox(width: 12,),
                    Expanded(
                      child: Text(
                        '날짜: $_selectedDateStr',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold
                        ),                        
                      ),
                    ),
                    const Text(
                      '변경',
                      style: TextStyle(color: Colors.amber, fontSize: 13),
                    )
                  ]
                ),
              ),
            ),
            const SizedBox(height: 14,),
            // 제목 입력
            TextField(
              controller: _titleController,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFFFFDE7),
                prefixIcon: Icon(Icons.title, color: Colors.amber,)
              ),
            ),
            const SizedBox(height: 12,),
            Expanded(
              // 내용 입력
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '이 날의 하루를 기록해보세요....',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFFFFDE7),
                ),
                style: const TextStyle(fontSize: 16, height: 1.6),
              )
            )
          ],
        ),
      ),
    );
  }
}