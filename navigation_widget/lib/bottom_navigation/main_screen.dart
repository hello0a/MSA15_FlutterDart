import 'package:flutter/material.dart';
import 'package:navigation_widget/bottom_navigation/product_screen.dart';
import 'package:navigation_widget/bottom_navigation/user_screen.dart';
import 'package:navigation_widget/routes/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  // 선택된 화면
  Widget _selectedScreen = HomeScreen();
  // 선택된 화면 index
  int _selectedIndex = 0;

  // onTap 함수
  void _onTap(int index) {
    print("화면을 이동합니다. (${index})");
    // setState()
    // : StatefulWidget에서 변경된 state를 반영하여
    // UI를 업데이트 하는 함수
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0: _selectedScreen = HomeScreen();
        case 1: _selectedScreen = ProductScreen();
        case 2: _selectedScreen = UserScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: const [
          // Icon과 label 필수!
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User'
          ),
        ]
      ),
    );
  }
}