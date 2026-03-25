import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("사용자 화면"),
      ),
      body: const Center(
        child: Text("사용자 화면입니다."),
      ),
    );
  }
}