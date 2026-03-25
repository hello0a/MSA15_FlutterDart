import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final TextStyle style = TextStyle(
      fontSize: 30, fontWeight: FontWeight.bold
    );

    // 데이터 넘겨받기
    Map<String, dynamic>?  data
      = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: const Text("설정 화면"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("설정 화면입니다.", style: style),
            Text("ID : ${data?['id']}", style: style),
            Text("name : ${data?['name']}", style: style),
            Text("content : ${data?['content']}", style: style),
          ],
        )
      ),
    );
  }
}