void main(List<String> args) {
  // for, for in
  for (var i = 0; i < 5; i++) {
    print("count : $i");
  }

  // while
  int count = 0;
  while (count < 5) {
    print("count : $count");
    count++;
  }

  // do-while
  int number = 5;
  do {
    print("number : $number");
    number--;
  } while (number > 0);

  // 리스트 반복
  List<int> numberList = [1, 2, 3, 4, 5]; // List 자바 / [ ] 자바스크립트 -> Dart 섞임
  for (var item in numberList) {
    print("item : $item");
  }

  // forEach
  numberList.forEach((item) {
    print("item : $item");
  });
}
