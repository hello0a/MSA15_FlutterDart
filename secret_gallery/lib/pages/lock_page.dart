import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secret_gallery/services/auth_service.dart';

class LockPage extends StatefulWidget {
  const LockPage({super.key});

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {

  final _auth = AuthService();
  final _controller = TextEditingController();
  bool _isSettingMode = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPasswordExists();
  }

  // 앱 잠금 비밀번호 존재 확인
  Future<void> _checkPasswordExists() async {
    final hasPassword = await _auth.hasAppPassword();

    if (!hasPassword) {
      setState(() => _isSettingMode = true);
    }
  }

  // 비밀번호 입력 처리
  Future<void> _onSubmit() async {
    final input = _controller.text.trim();

    if(input.isEmpty) return;
    // 최초 앱 잠금 비밀번호 세팅
    if (_isSettingMode) {
      await _auth.setAppPassword(input);
      _navigateToAlbumList();
    } else {
      final ok = await _auth.checkAppPassword(input);

      if (ok) {
        _navigateToAlbumList();
      } else {
        setState(() => _errorMessage = '비밀번호가 틀렸습니다.');
        _controller.clear();
      }
    }
  }

  void _navigateToAlbumList() {
    Navigator.of(context).pushReplacementNamed('/album');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 72, color: Colors.white,),
              SizedBox(height: 24,),
              Text(
               _isSettingMode 
                ? '새 비밀번호를 설정하세요' 
                : '비밀번호를 입력하세요',
                style: TextStyle(
                  color: Colors.white, fontSize: 18
                ),
              ),
              SizedBox(height: 24,),
              TextField(
                controller: _controller,
                obscureText: true,  // 기호로 입력값 숨김
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: TextStyle(
                  color: Colors.white, fontSize: 24, letterSpacing: 8
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
                onSubmitted: (_) => _onSubmit(),
              ),
              // ... : 전개연산자, spread operator
              // 조건부 처리
              // 1.( 조건 ) ? 참 : 거짓
              // 2. if() 단일 위젯 (중괄호X)
              // 3. if() ...[ 위젯1, 위젯2 ] (중괄호X)
              if (_errorMessage.isNotEmpty) ... [
                SizedBox(height: 24,),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.redAccent),
                )
              ],
              SizedBox(height: 24,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSubmit, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, 
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12)
                    )
                  ),
                  child: Text(
                    _isSettingMode ? '설정' : '잠금 해제',
                    style: TextStyle(fontSize: 20),
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}