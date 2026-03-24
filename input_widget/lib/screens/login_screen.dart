import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // state
  bool _rememberId = false; // 아이디 저장
  bool _rememberMe = false; // 자동 로그인

  // controller
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  // FocusNode
  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _pwFocusNode = FocusNode();

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _idFocusNode.dispose();
    _pwFocusNode.dispose();
    super.dispose();
  }

  void _onLogin() {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();
    if (id.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("아이디와 비밀번호를 입력하세요."),
        )
      );
      return;
    }
    // TODO: 실제 로그인 처리
    debugPrint("아이디 : $id, 비밀번호 : $pw");
    debugPrint("아이디저장 : $_rememberId");
    debugPrint("자동로그인 : $_rememberMe");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: ListView(
        children: [
          const Text("로그인", style: TextStyle(fontSize: 30),),
          SizedBox(height: 50,),
          TextField(
            controller: _idController,
            focusNode: _idFocusNode,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "아이디",
              hintText: "아이디를 입력해주세요.",
              prefixIcon: Icon(Icons.person),
              suffixIcon: IconButton(
                onPressed: ()  => _idController.clear(), 
                icon: Icon(Icons.clear)
              )
            ),
            // 아이디 입력 후, 엔터 입력 시 패스워드로 포커스 되도록
            onSubmitted: (_) => FocusScope.of(context).requestFocus(_pwFocusNode),
          ),
          SizedBox(height: 20,),
          TextField(
            controller: _pwController,
            focusNode: _pwFocusNode,
            obscureText: true,      // 입력 기호로 숨김 여부
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "비밀번호",
              hintText: "비밀번호를 입력해주세요.",
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: () => _pwController.clear(), 
                icon: const Icon(Icons.clear)
              ),
            ),
            // TODO: 엔터 입력 시, 로그인 이벤트 연결
            onSubmitted: (_) => _onLogin(),
          ),
          SizedBox(height: 20.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              // 아이디 저장
              Row(children: [
                Checkbox(value: _rememberId, onChanged: (value) {
                  setState(() {
                    _rememberId = value!;
                  });
                }),
                GestureDetector(
                  child: Text("아이디 저장"),
                  onTap: () {
                    setState(() {
                      _rememberId= !_rememberId;
                    });
                  },
                )
              ],),
              // 자동 로그인
              // 아이디 저장
              Row(children: [
                Checkbox(value: _rememberMe, onChanged: (value) {
                  setState(() {
                    _rememberMe = value!;
                  });
                }),
                GestureDetector(
                  child: Text("자동 로그인"),
                  onTap: () {
                    setState(() {
                      _rememberMe= !_rememberMe;
                    });
                  },
                )
              ],)
            ],
          ),
          // 로그인 버튼
          ElevatedButton(
            // TODO: 로그인 처리
            onPressed: _onLogin, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,  // 배경색
              foregroundColor: Colors.white,  // 폰트색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0) // 테두리 곡률
              ),
              // 버튼 최소 크기
              // double.infinity : 디바이스의 최대크기로 지정
              minimumSize: const Size(double.infinity, 50)
            ),
            child: const Text("로그인", style: TextStyle(fontSize: 24),),
          )
        ],
      ),
    );
  }
}