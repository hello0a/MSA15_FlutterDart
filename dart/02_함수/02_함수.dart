// 함수 정의
// 반환타입 함수명( 매개변수 ) { }

int sum(int a, int b, int c) {
  return a + b + c;
}

void main(List<String> args) {
  print("기본 함수 정의");
  int result = sum(10, 20, 30);
  print("result = $result");
}
