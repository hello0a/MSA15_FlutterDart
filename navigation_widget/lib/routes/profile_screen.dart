import 'package:flutter/material.dart';
import 'package:navigation_widget/models/profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {

    final TextStyle style = TextStyle(
      fontSize: 25, fontWeight: FontWeight.bold
    );

    // 데이터 전달 받기
    Profile? profile = ModalRoute.of(context)?.settings.arguments as Profile;

    return Scaffold(
      appBar: AppBar(title: const Text("프로필 화면"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("프로필 화면입니다.", style: style),
            Text("ID : ${profile.id}", style: style),
            Text("name : ${profile.name}", style: style),
            Text("e-mail : ${profile.email}", style: style),
          ],
        )
      ),
    );
  }
}