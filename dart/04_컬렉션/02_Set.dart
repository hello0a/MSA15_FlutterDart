void main(List<String> args) {
  Set<String> sets = {"우동사리", "치즈떡", "중국당면"};
  print("sets : $sets");

  // 요소 추가
  sets.add("라면");
  print("sets : $sets");

  // 중복 요소 추가 해보기
  var result = sets.add("라면");
  print("중복 여부 : ${!result}");
  print("sets : $sets");

  // Set 반복
  sets.forEach((item) {
    print(item);
  });

  // 첫번째 요소, 마지막 요소
  print("첫번째 요소 : ${sets.first}");
  print("마지막 요소 : ${sets.last}");

  // 전체 삭제
  sets.clear();
  print("sets : $sets");

  // 비어 있는지 확인
  if (sets.isEmpty) {
    print("sets 가 비어 있습니다.");
  }

  // Set 객체 생성
  Set<String> test = Set();
  test.add("아이템1");
  test.add("아이템2");
  test.add("아이템3");
  print("test : $test");

  // {} 기호로 리터럴 방식으로 생성
  Set<int> data = {};
  print("data : $data");
}
