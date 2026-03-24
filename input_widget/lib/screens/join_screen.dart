import 'package:flutter/material.dart';

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