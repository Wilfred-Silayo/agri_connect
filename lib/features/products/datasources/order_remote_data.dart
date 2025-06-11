import 'package:agri_connect/features/products/models/order_items_model.dart';
import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class OrderRemoteDataSource {
  Future<List<OrderModel>> fetchOrdersByDateRange(DateTime start, DateTime end);
  Stream<List<OrderModel>> fetchOrdersByBuyerId(String buyerId, String status);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrder(String id, Map<String, dynamic> updatedFields);
  Future<void> deleteOrder(String id);
  Future<void> createOrderItems(List<OrderItemModel> items);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient supabaseClient;
  const OrderRemoteDataSourceImpl(this.supabaseClient);

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
  Stream<List<OrderModel>> fetchOrdersByBuyerId(String buyerId, String status) {
    try {
      final stream = supabaseClient
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('buyer_id', buyerId)
          .order('created_at', ascending: false);

      //filter by status here
      return stream.map((data) {
        final filtered =
            data
                .where((order) => order['status'] == status)
                .map((e) => OrderModel.fromMap(e))
                .toList();
        return filtered;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createOrderItems(List<OrderItemModel> items) async {
    try {
      if (items.isEmpty) {
        throw Exception('No order items provided');
      }
      await supabaseClient
          .from('order_items')
          .insert(items.map((e) => e.toMap()).toList());
    } catch (e) {
      rethrow;
    }
  }
}
