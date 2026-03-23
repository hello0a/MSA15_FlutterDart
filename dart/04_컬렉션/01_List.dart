void main(List<String> args) {
  List<int> list = [1, 2, 3, 4, 5];
  print("list : $list");

  // 리스트 요소 접근 및 수정
  list[0] = 100;
  print("list[0] : ${list[0]}");

  // 리스트 길이
  print("list.length : ${list.length}");

  // 리스트 요소 추가
  list.add(55);
  print("list : $list");

  // 리스트 요소 제거 - 값으로 제거
  list.remove(55);
  print("list : $list");

  // 리스트 요소 제거 - index 로 제거
  list.removeAt(3);
  print("list : $list");

  // 리스트 반복
  list.forEach((item) {
    print(item);
  });

  // 첫번째 요소, 마지막 요소
  print("list.first : ${list.first}");
  print("list.last : ${list.last}");

  List<String> wordList = ["A", "B", "C", "D", "E"];
  print("wordList : $wordList");

  // 역방향 정렬
  List reversedWordList = wordList.reversed.toList();
  print("reversedWordList : $reversedWordList");

  // 정방향 정렬
  List<int> numberList = [10, 6, 5, 7, 2];
  numberList.sort();
  print("numberList : $numberList");
}
