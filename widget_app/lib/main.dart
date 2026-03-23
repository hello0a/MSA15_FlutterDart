

import 'dart:math';

import 'package:flutter/material.dart';

// 프로그램 시작점
void main() {
  // 1. MyApp 위젯 생성해서 맨 처음 run
  runApp(const MyApp());
}
// >> 직접 구현 코드
// class MyApp extends StatelessWidget {
//   // 생성자
//   const MyApp({super.key});

//   // UI 
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             onPressed: () {}, 
//             icon: const Icon(Icons.menu)
//           ),
//           title: const Text("My App"),
//           actions: [
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Icons.more_vert)
//               )
//             ],
//           ),
//           body: const Center(
//             child: Text("Hello World!"),
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             // items
//             // : 기본 2개 이상 필요!
//             items: [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.home),
//                 label: 'Home'
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.shopping_bag),
//                 label: 'Cart'
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.settings),
//                 label: 'Settings'
//               ),
//             ]
//           ),
//         ),
//       );
//   }
// }

// >> 직접 구현2
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // state 선언
  String _menu = '점메추';
  final _menuList = ['오', '늘', '뭐', '먹', '으', '심', '?'];

  void _random() {
    // 랜덤으로 임의의 정수 반환
    final r = Random().nextInt(_menuList.length);
    // State Update
    setState(() {
      _menu = _menuList[r];
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 그럼 이거는 다 이름매개변수..?
      // 이름 매개변수로 객체 생성하여 위젯 만드는 것
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {}, 
            // const 차이
            // 바뀌지 않음 (State 없음)
            // 정적이다!
            icon: const Icon(Icons.menu)
          ),
          title: const Text('점메추 앱'),
          actions: [
            IconButton(
              onPressed: () {}, 
              icon: Icon(Icons.more_vert)
            )
          ]
        ),
        body: Center(
          // const 차이
          // _menu State : 값이 바뀌어야함.
          // 동적이다!
          child: Text(
            _menu,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _random();
          }, 
          child: const Icon(Icons.restaurant),
        ),
      ),
    );
  }
}




// >> 초기 코드
// // stl : StatelessWidget 자동완성
// class MyApp extends StatelessWidget {
//   // 1) 생성자
//   const MyApp({super.key});

//   // 2) build 메소드
//   // : 출력할 위젯을 반환하는 메소드
//   @override
//   Widget build(BuildContext context) {
//     // 3) 화면UI (?)
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: .fromSeed(seedColor: Colors.deepPurple),
//       ),
//       // 2. 가장 먼저 시작할 widget 지정
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// // 3.
// // stf: StatefulWidget 자동완성
// class MyHomePage extends StatefulWidget {
//   // 1) 생성자
//   const MyHomePage({super.key, required this.title});
//   // 변수
//   final String title;
//   // 2) state
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// // 4.
// class _MyHomePageState extends State<MyHomePage> {
//   // state
//   int _counter = 0;

//   // setState
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//  // 5.
//   @override
//   Widget build(BuildContext context) {
//     // 1) 앱 기본 구조 : appbar/body/bottomNav
//     return Scaffold(
//       // appBar
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       // body
//       body: Center(
//         child: Column(
//           mainAxisAlignment: .center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       // bottom 현재 없음
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
