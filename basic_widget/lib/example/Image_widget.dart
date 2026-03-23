import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 50,),
            const Text(
              "네트워크 이미지",
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 10,),
            // 앱 외 이미지 경로
            Image.network(
              'https://i.imgur.com/fzADqJo.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 50,),
            const Text(
              "로컬 이미지",
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 10,),
            const Image(
              // 정적 이미지 경로 (앱 자체)
              image: AssetImage("image/logo.jpg"),
              width: 400,
              height: 400,
            )
          ],
        ),
      )
    );
  }
}