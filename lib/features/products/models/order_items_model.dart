import 'dart:convert';

import 'package:agri_connect/core/enums/order_status_enum.dart';

class OrderItemModel {
  final String id;
  final String orderId;
  final String stockId;
  final String sellerId;
  final int quantity;
  final double price;
  final OrderStatus status;
  final DateTime? deliveredAt;
  final DateTime? confirmedAt;
  final DateTime createdAt;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.stockId,
    required this.sellerId,
    required this.quantity,
    required this.price,
    required this.status,
    this.deliveredAt,
    this.confirmedAt,
    required this.createdAt,
  });

  OrderItemModel copyWith({
    String? id,
    String? orderId,
    String? stockId,
    String? sellerId,
    int? quantity,
    double? price,
    OrderStatus? status,
    DateTime? deliveredAt,
    DateTime? confirmedAt,
    DateTime? createdAt,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      stockId: stockId ?? this.stockId,
      sellerId: sellerId ?? this.sellerId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'],
      orderId: map['order_id'],
      stockId: map['stock_id'],
      sellerId: map['seller_id'],
      quantity: map['quantity'],
      price: double.parse(map['price'].toString()),
      status: (map['status'] as String).toOrderStatusEnum(),
      deliveredAt: map['delivered_at'] != null ? DateTime.parse(map['delivered_at']) : null,
      confirmedAt: map['confirmed_at'] != null ? DateTime.parse(map['confirmed_at']) : null,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'order_id': orderId,
        'stock_id': stockId,
        'seller_id': sellerId,
        'quantity': quantity,
        'price': price,
        'status': status.value,
        'delivered_at': deliveredAt?.toIso8601String(),
        'confirmed_at': confirmedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory OrderItemModel.fromJson(String source) =>
      OrderItemModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
