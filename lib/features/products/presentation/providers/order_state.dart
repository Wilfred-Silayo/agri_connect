import 'package:flutter/foundation.dart';

@immutable
sealed class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {}

class OrderFailure extends OrderState {
  final String message;
  const OrderFailure(this.message);
}
