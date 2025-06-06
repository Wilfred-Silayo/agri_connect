import 'dart:convert';

class StockModel {
  final String id;
  final String userId;
  final int? categoryId;
  final String name;
  final String? description;
  final double price;
  final int quantity;
  final List<String>? images;
  final DateTime createdAt;

  const StockModel({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    required this.quantity,
    this.images,
    required this.createdAt,
  });

  StockModel copyWith({
    String? id,
    String? userId,
    int? categoryId,
    String? name,
    String? description,
    double? price,
    int? quantity,
    List<String>? images,
    DateTime? createdAt,
  }) {
    return StockModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory StockModel.fromMap(Map<String, dynamic> map) {
    return StockModel(
      id: map['id'],
      userId: map['user_id'],
      categoryId: map['category_id'],
      name: map['name'],
      description: map['description'],
      price: double.parse(map['price'].toString()),
      quantity: map['quantity'],
      images: map['images'] != null ? List<String>.from(map['images']) : null,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'images': images,
        'created_at': createdAt.toIso8601String(),
      };

  factory StockModel.fromJson(String source) =>
      StockModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
