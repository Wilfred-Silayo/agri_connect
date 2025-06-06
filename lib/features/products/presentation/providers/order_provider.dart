import 'package:agri_connect/core/shared/providers/supabase_client_provider.dart';
import 'package:agri_connect/core/utils/date_range.dart';
import 'package:agri_connect/features/products/datasources/order_remote_data.dart';
import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:agri_connect/features/products/presentation/providers/order_state.dart';
import 'package:agri_connect/features/products/repository/order_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderNotifier(repository);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final remote = OrderRemoteDataSourceImpl(client);
  return OrderRepository(remote);
});

final ordersByDateRangeProvider =
    FutureProvider.family<List<OrderModel>?, DateRange>((ref, range) async {
      final notifier = ref.watch(orderNotifierProvider.notifier);
      return notifier.fetchOrdersByDateRange(range.start, range.end);
    });

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;
  OrderNotifier(this._repository) : super(OrderInitial());

  Stream<List<OrderModel>?> fetchOrder(String? id) {
    return _repository.fetchOrder(id).map((either) {
      return either.fold(
        (failure) => throw Exception(failure.message),
        (orders) => orders,
      );
    });
  }

  Future<List<OrderModel>> fetchOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final either = await _repository.fetchOrdersByDateRange(start, end);
    return either.fold(
      (failure) => throw Exception(failure.message),
      (orders) => orders,
    );
  }

  Future<List<OrderModel>?> fetchOrdersByBuyerId(String buyerId) async {
    final either = await _repository.fetchOrdersByBuyerId(buyerId);
    return either.fold(
      (failure) => throw Exception(failure.message),
      (orders) => orders,
    );
  }

  Future<void> createOrder(OrderModel order) async {
    final either = await _repository.createOrder(order);
    either.fold(
      (failure) => OrderFailure(failure.message),
      (order) => OrderSuccess(),
    );
  }

  Future<void> updateOrder(String id, Map<String, dynamic> fields) async {
    final either = await _repository.updateOrder(id, fields);
    either.fold(
      (failure) => OrderFailure(failure.message),
      (order) => OrderSuccess(),
    );
  }

  Future<void> deleteOrder(String id) async {
    final either = await _repository.deleteOrder(id);
    either.fold(
      (failure) => OrderFailure(failure.message),
      (order) => OrderSuccess(),
    );
  }
}
