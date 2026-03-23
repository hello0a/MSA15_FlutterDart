class Animal {
  String name;
  int age;

  // Animal();
  Animal(this.name, this.age);

  void eat() {
    print("$name is eating.");
  }
}

class Dog extends Animal {
  // 부모 클래스의 기본 생성자가 자동으로 호출
  // Dog(String name, int age);

  // 부모 생성자를 지정하여 호출
  Dog(String name, int age) : super(name, age);

  void bark() {
    print("$name is barking.");
  }
}

class Cat extends Animal {
  Cat(String name, int age) : super(name, age);

  void meow() {
    print("$name is meowing.");
  }
}

void main(List<String> args) {
  Dog dog = Dog("바둑이", 3);
  dog.eat();
  dog.bark();

  Cat cat = Cat("야옹이", 2);
  cat.eat();
  cat.meow();
}
