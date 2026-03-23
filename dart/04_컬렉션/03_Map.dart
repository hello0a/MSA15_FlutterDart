void main(List<String> args) {
  // Map 리터럴 생성
  Map<String, int> map = {"김조은": 20, "전주원": 27, "원장님": 40};

  // 요소 접근 및 수정
  print("김조은의 나이 : ${map['김조은']} ");
  map['김조은'] = 30;
  print("map : $map");

  // 요소 추가
  map['서성재'] = 33;
  print("map : $map");

  // 요소 제거
  map.remove('전주원');
  print("map : $map");

  // Map 반복
  map.forEach((key, value) {
    print("$key : $value");
  });
}
