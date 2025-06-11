import 'package:equatable/equatable.dart';

class OrderQuery extends Equatable {
  final String buyer;
  final String status;

  const OrderQuery({required this.buyer,required this.status});

  @override
  List<Object?> get props => [buyer, status];
}
