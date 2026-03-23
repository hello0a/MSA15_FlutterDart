// 주의
// 파일명 스네이크 케이스!

// stls: ctrl + space
import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "텍스트 위젯입니다",
        style: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }
}