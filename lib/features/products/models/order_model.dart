import 'dart:convert';
import 'package:agri_connect/core/enums/order_status_enum.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  OrderModel copyWith({
    String? id,
    String? buyerId,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      buyerId: map['buyer_id'],
      totalAmount: double.parse(map['total_amount'].toString()),
      status: (map['status'] as String).toOrderStatusEnum(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'buyer_id': buyerId,
    'total_amount': totalAmount,
    'status': status.value,
    'created_at': createdAt.toIso8601String(),
  };

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
