import 'dart:convert';

class CategoryModel {
  final int id;
  final String name;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  CategoryModel copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'created_at': createdAt.toIso8601String(),
      };

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
