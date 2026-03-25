class Profile {
  final String id;
  final String name;
  final String? email;
  // final String email;

  // 1. 생성자 위치 매개변수
  // Profile( this.id, this.name, this.email );
  // 2. 생성자 이름 매개변수
  // required : null(=?) 없다면 필요(필수 매개변수)
  Profile({
    required this.id,
    required this.name,
    this.email,
  });
}