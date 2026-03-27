import 'package:diary_app/pages/calender_page.dart';
import 'package:diary_app/pages/detail_page.dart';
import 'package:diary_app/pages/home_page.dart';
import 'package:diary_app/pages/write_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '다이어리 앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true
      ),
      // home: const HomePage(),
      initialRoute: '/home',
      routes: {
        "/home" : (context) => HomePage(),
        "/write" : (context) => WritePage(),
        "/detail" : (context) => DetailPage(),
        "/calendar" : (context) => CalendarPage(),
      },
    );
  }
}
