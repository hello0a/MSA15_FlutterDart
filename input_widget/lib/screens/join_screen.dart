import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart' as picker;

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {

  // 폼 키
  final _formKey = GlobalKey<FormState>();  // Form 위젯을 제어하는 키

  // state
  // _변수 : private 변수
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwChkController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();

  String _gender = "남자";

  final config = picker.CalendarDatePicker2Config(
    // 캘린더 타입 : single, multi, range
    calendarType: picker.CalendarDatePicker2Type.range,
    // 선택한 날짜 색상
    selectedDayHighlightColor: Colors.redAccent,
    // 요일 라벨
    weekdayLabels: ['일','월','화','수','목','금','토'],
    // 요일 스타일
    weekdayLabelTextStyle: const TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.bold
    ),
    // 시작 요일 : 0 (일), 1(월)
    firstDayOfWeek: 0,
    // 컨트롤 높이 사이즈
    controlsHeight: 50,
    // 날짜 스타일
    dayTextStyle: const TextStyle(
      color: Colors.black,
    ),
    // 비활성화된 날짜 스타일
    disabledDayTextStyle: const TextStyle(
      color: Colors.grey
    ),
    // 선택가능한 날짜 설정
    // DateTime.now() : 현재 날짜 시간          - 2025/09/01
    // difference()   : 두 날짜 객체 간의 차이
    // DateTime.now().subtract(const Duration(days: 1)) 
    // : 오늘 날짜에서 1일을 뺀 값              - 2025/08/31
    // day.difference( 어제 ) : 선택된 날짜와 어제 날짜 사이의 시간 간격 
    // isNegative : 음수인 확인 (특정 날짜와 어제 날짜 사이의 차이 음수면 true)
    selectableDayPredicate: (day) => !day
                                  .difference(DateTime.now().subtract(const Duration(days: 1)))
                                  .isNegative,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: ListView(
        children: [
          const Text("회원가입", style: TextStyle(fontSize: 30),),
          Form(
            key: _formKey,
            child: Column(
              children: [
                // 아이디
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "아이디",
                    hintText: "아이디를 입력해주세요."
                  ),
                  controller: _idController,
                  // 유효성 검사
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "아이디를 입력해주세요.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                // 비밀번호
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "비밀번호",
                    hintText: "비밀번호를 입력해주세요."
                  ),
                  controller: _pwController,
                  // 유효성 검사
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "비밀번호를 입력해주세요.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                // 비밀번호 확인
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "비밀번호 확인",
                    hintText: "비밀번호를 입력해주세요."
                  ),
                  controller: _pwChkController,
                  // 유효성 검사
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "비밀번호를 입력해주세요.";
                    }
                    // 비밀번호 일치 여부 확인
                    if (value != _pwController.text) {
                      return "비밀번호가 일치하지 않습니다.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                // 성별
                Row(
                  children: [
                    Text("성별"),
                    RadioGroup(
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value ?? '';
                        });
                      }, 
                      child: Row(
                        children: [
                          Radio(value: "남자"),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _gender = "남자";
                              });
                            }, child: Text("남자"),
                          ),
                          Radio(value: "여자"),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _gender = "여자";
                              });
                            }, child: Text("여자"),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.0,),
                // 생년월일
                Column(
                  children: [
                    TextFormField(
                      controller: _birthController,
                      readOnly: true,
                      decoration: InputDecoration(
                        // 뒤쪽 아이콘
                        suffixIcon: GestureDetector(
                          onTap: () async {
                            print("생년월일 달력 아이콘 클릭");
                            final result = await showDialog(
                              context: context, builder: (context) {
                                return Dialog(
                                  child: picker.CalendarDatePicker2(
                                    // 캘린더 설정
                                    config: picker.CalendarDatePicker2Config(
                                      calendarType: picker.CalendarDatePicker2Type.single,
                                      selectedDayHighlightColor: Colors.orange,
                                      weekdayLabels: ["월", "화", "수", "목", "금", "토", "일"],
                                    ), 
                                    // config: config,
                                    value: [],
                                    // 달력에서 선택한 값 변경 시
                                    onValueChanged: (dates) {
                                      print(dates[0]);
                                      if (dates.isNotEmpty) {
                                        // 선택한 날짜 반환하면서 showDialog 닫기
                                        // result에 담겨지는 것
                                        // 리스트로 반환(?)
                                        Navigator.pop(context, dates);
                                        // 날짜 하나만 반환(?)
                                        // Navigator.pop(context, dates[0]);
                                      }
                                    },
                                  )
                                );
                              }
                            );
                            if (result != null && result.isNotEmpty) {
                              print(result);
                              // 선택된 날짜 - 2026/03/25
                              final selectedDate = result[0];
                              final formatDate
                                = "${selectedDate.year}/"
                                  "${selectedDate.month.toString().padLeft(2, '0')}/"
                                  "${selectedDate.day.toString().padLeft(2, '0')}";
                              print(formatDate);
                              // 생년월일 입력에, 달력에서 선택한 값 지정
                              _birthController.text = formatDate;
                            }
                          },
                          child: Icon(Icons.calendar_month),
                        )
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.0,),
                // 회원가입 버튼
                ElevatedButton(
                  onPressed: () {
                    // 유효성 검사
                    if (_formKey.currentState!.validate()) {
                      // 유효성 검사 성공
                      print("유효성 검사 성공!");
                      // 폼 제출
                      print("아이디 : ${_idController.text}");
                      print("비밀번호 : ${_pwController.text}");
                      print("비밀번호 확인 : ${_pwChkController.text}");
                      print("성별 : ${_gender}");
                      print("생년월일 : ${_birthController.text}");
                    } else {
                      // 유효성 검사 실패
                      print("유효성 검사 실패!");
                    }
                  }, 
                  child: Text("회원가입")
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}