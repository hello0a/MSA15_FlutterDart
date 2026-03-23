// 익명 함수
// - 변수로 할당
// - 매개변수로 전달
// - Dart 의 함수 타입 : Function

void test(String msg, Function(int) callback) {
  print("메시지 : $msg");
  callback(100);
}

void main(List<String> args) {
  // 익명함수
  var callback = (int data) {
    print("콜백함수 - data : $data");
  };

  test("안녕하세요", callback);

  test("반갑습니다", (int data) {
    print("콜백함수2 - data : ${data}");
  });

  // 순서: test(안녕하세요) -> test(callback) 호출 -> callback 100 -> 콜백함수 100 출력
}
