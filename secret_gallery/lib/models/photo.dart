class Photo {
  final int? id;
  final int albumId;
  final String path;
  final String? title;
  final String? memo;
  final String createdAt;
  final int sortOrder;
  Photo({
    this.id,
    required this.albumId,
    required this.path,
    this.title,
    this.memo,
    required this.createdAt,
    this.sortOrder = 0,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'album_id': albumId,
      'path': path,
      'title': title,
      'memo': memo,
      'created_at': createdAt,
      'sort_order': sortOrder,
    };
  }
  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'] as int?,
      albumId: map['album_id'] as int,
      path: map['path'] as String,
      title: map['title'] as String?,
      memo: map['memo'] as String?,
      createdAt: map['created_at'] as String,
      sortOrder: (map['sort_order'] as int?) ?? 0,
    );
  }
  Photo copyWith({
    int? id,
    int? albumId,
    String? path,
    String? title,
    String? memo,
    String? createdAt,
    int? sortOrder,
  }) {
    return Photo(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      path: path ?? this.path,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}