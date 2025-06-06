import 'package:flutter/foundation.dart';

@immutable
sealed class StockState {
  const StockState();
}

class StockInitial extends StockState {}

class StockLoading extends StockState {
  final String message;
  const StockLoading(this.message);
}

class StockSuccess extends StockState {
  final String message;
  const StockSuccess(this.message);
}

class StockFailure extends StockState {
  final String message;
  const StockFailure(this.message);
}
