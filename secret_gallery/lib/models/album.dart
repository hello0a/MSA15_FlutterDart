class Album {
  final int? id;
  final String name;
  final String type; // 'normal' | 'secret'
  final String? password;
  final int sortOrder;

  Album({
    this.id,
    required this.name,
    required this.type,
    this.password,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'password': password,
      'sort_order': sortOrder,
    };
  }
  
  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      password: map['password'] as String?,
      sortOrder: (map['sort_order'] as int?) ?? 0,
    );
  }
}