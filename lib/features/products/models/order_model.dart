import 'dart:convert';

class OrderModel {
  final String id;
  final String? buyerId;
  final double totalAmount;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    this.buyerId,
    required this.totalAmount,
    required this.createdAt,
  });

  OrderModel copyWith({
    String? id,
    String? buyerId,
    double? totalAmount,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      buyerId: map['buyer_id'],
      totalAmount: double.parse(map['total_amount'].toString()),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'buyer_id': buyerId,
        'total_amount': totalAmount,
        'created_at': createdAt.toIso8601String(),
      };

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
