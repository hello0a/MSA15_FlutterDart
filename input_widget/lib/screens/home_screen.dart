import 'package:flutter/material.dart';
import 'package:input_widget/screens/join_screen.dart';
import 'package:input_widget/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    // length : 탭의 개수
    // with SingleTickerProviderStateMixin을 지정해서 this를 사용
    // vsync : vertical sync
    // 화면이 새로고침 될 때 애니메이션이 부드럽게 진행되도록 도와줌
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: TabBarView(
          children: [
            LoginScreen(),
            JoinScreen(),
          ],
          controller : controller,
        ),
        bottomNavigationBar: TabBar(
          tabs: const [
            Tab(child: Text("로그인"),),
            Tab(child: Text("회원가입"),),
          ],
          controller: controller,
        ),
      ),
    );
  }
}