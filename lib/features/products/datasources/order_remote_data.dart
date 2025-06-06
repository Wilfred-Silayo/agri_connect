import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class OrderRemoteDataSource {
  Stream<List<OrderModel>> fetchOrder(String? id);
  Future<List<OrderModel>> fetchOrdersByDateRange(DateTime start, DateTime end);
  Future<List<OrderModel>> fetchOrdersByBuyerId(String buyerId);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrder(String id, Map<String, dynamic> updatedFields);
  Future<void> deleteOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient supabaseClient;
  const OrderRemoteDataSourceImpl(this.supabaseClient);

  @override
  Stream<List<OrderModel>> fetchOrder(String? id) {
    final stream =
        (id != null)
            ? supabaseClient
                .from('orders')
                .stream(primaryKey: ['id'])
                .eq('id', id)
            : supabaseClient.from('orders').stream(primaryKey: ['id']);

    return stream.map((data) {
      final models = data.map((e) => OrderModel.fromMap(e)).toList();
      return models;
    });
  }

  @override
  Future<List<OrderModel>> fetchOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final response = await supabaseClient
          .from('orders')
          .select()
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String())
          .order('created_at', ascending: true);

      return response
          .map<OrderModel>((data) => OrderModel.fromMap(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response =
          await supabaseClient
              .from('orders')
              .insert(order.toMap())
              .select()
              .single();

      return OrderModel.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderModel> updateOrder(
    String id,
    Map<String, dynamic> updatedFields,
  ) async {
    try {
      final response =
          await supabaseClient
              .from('orders')
              .update(updatedFields)
              .eq('id', id)
              .select()
              .single();

      return OrderModel.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    try {
      await supabaseClient.from('orders').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> fetchOrdersByBuyerId(String buyerId) async {
    try {
      final response = await supabaseClient
          .from('orders')
          .select()
          .eq('buyer_id', buyerId)
          .order('created_at', ascending: false);

      return response
          .map<OrderModel>((data) => OrderModel.fromMap(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
