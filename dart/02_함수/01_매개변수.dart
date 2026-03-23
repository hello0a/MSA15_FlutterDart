void main(List<String> args) {
  // 1. 위치 필수 매개변수
  void greet(String name) {
    print("Hello, $name!");
  }

  greet("Alice"); // ✅ Hello, Alice!
  // greet(); // ❌ 오류 발생 (name 값 필요)

  // 2. 위치 선택 매개변수 - 선언한 순서대로 값 지정
  void greetOptional([String name = "Guest"]) {
    print("Hello, $name!");
  }

  greetOptional(); // ✅ Hello, Guest!
  greetOptional("Bob"); // ✅ Hello, Bob!

  // 3. 이름 필수 매개변수
  void greetRequired({required String name, required int age}) {
    print("Hello, $name!");
    print("You are $age years old.");
  }

  // greetRequired(); // ❌ 오류 발생 (name 값 필요)
  // greetRequired(name: "Charlie"); - 3번에 required 때문 / {} 묶으면서 이름을 지정하였기 때문에 순서 상관X (위치 선택과 차이) 
  greetRequired(age: 20, name: "Charlie");

  // 4. 이름 선택 매개변수
  void greetNamed({String name = "Guest"}) {
    print("Hello, $name!");
  }

  greetNamed(); // ✅ Hello, Guest!
  greetNamed(name: "David"); // ✅ Hello, David!
}
