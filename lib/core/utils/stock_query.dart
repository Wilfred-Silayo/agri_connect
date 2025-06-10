import 'package:equatable/equatable.dart';

class StockQuery extends Equatable {
  final String? id;
  final String? query;

  const StockQuery({this.id, this.query});

  @override
  List<Object?> get props => [id, query];
}
