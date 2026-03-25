import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필 화면"),
      ),
      body: const Center(
        child: Text("프로필 화면입니다."),
      ),
    );
  }
}