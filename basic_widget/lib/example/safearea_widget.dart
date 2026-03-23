import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SafeareaWidget extends StatelessWidget {
  const SafeareaWidget({super.key});

  @override
  Widget build(BuildContext context) {

    // 상태바, 네비게이션바 숨기기(ex 게임)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
    
    // SafeArea 차이맨 하단에 차이가 있음

    // 1. SafeArea에 Container 넣었을 때
    return SafeArea(
      // 안전영역 사용여부
      // - top, bottom, left, right : 안전영역 사용방향 지정
      top: true,
      bottom: true,
      left: true,
      right: true,
      // 안전영역과의 간격 지정
      minimum: const EdgeInsets.all(10),
      child: Container(
        height: 1000,
        color: Colors.blue,
      )
    );

    // 2. SafeArea 적용X : Container 그냥 넣었을 때
    // appbar와 하단 모두 파랗게 변함
    // return Container(
    //   height: 1000,
    //   color: Colors.blue,
    // );
  }
}