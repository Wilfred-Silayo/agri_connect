import 'package:agri_connect/features/products/models/order_items_model.dart';
import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class OrderRemoteDataSource {
  Future<List<OrderModel>> fetchOrdersByDateRange(DateTime start, DateTime end);
  Stream<List<OrderModel>> fetchOrdersByBuyerId(String buyerId, String status);
  Stream<String> checkOrderItemStatus(String orderItemId);
  Future<OrderModel> createOrder(OrderModel order);
  Future<List<OrderItemModel>> fetchOrderItems(String orderId);
  Future<OrderModel> updateOrder(String id, Map<String, dynamic> updatedFields);
  Future<void> deleteOrder(String id);
  Future<void> createOrderItems(List<OrderItemModel> items);
  Future<void> updateOrderIfAllMatchStatus(String orderId, String newStatus);
  Future<void> updateOrderItemStatus(
    String itemId,
    String newStatus,
    String? columnToUpdate,
  );
  Future<void> cancelOrderItem(String itemId);
  Future<void> cancelOrder(String orderId);
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
  Stream<String> checkOrderItemStatus(String orderItemId) {
    try {
      final stream = supabaseClient
          .from('order_items')
          .stream(primaryKey: ['id'])
          .eq('id', orderItemId)
          .limit(1)
          .map((items) {
            if (items.isNotEmpty) {
              final status = items.first['status'] as String?;
              if (status != null) {
                return status;
              }
            }
            return '';
          });

      return stream;
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

  @override
  Future<List<OrderItemModel>> fetchOrderItems(String orderId) async {
    try {
      final response = await supabaseClient
          .from('order_items')
          .select('*, stock:stocks(name)')
          .eq('order_id', orderId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateOrderIfAllMatchStatus(
    String orderId,
    String newStatus,
  ) async {
    final statuses = await supabaseClient
        .from('order_items')
        .select('status')
        .eq('order_id', orderId);

    final allMatch = (statuses as List).every(
      (row) => row['status'] == newStatus,
    );

    if (allMatch) {
      await supabaseClient
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);
    }
  }

  @override
  Future<void> updateOrderItemStatus(
    String itemId,
    String newStatus,
    String? columnToUpdate,
  ) async {
    final updateData = {
      'status': newStatus,
      if (columnToUpdate != null)
        columnToUpdate: DateTime.now().toIso8601String(),
    };

    await supabaseClient
        .from('order_items')
        .update(updateData)
        .eq('id', itemId);
  }

  @override
  Future<void> cancelOrderItem(String itemId) async {
    await supabaseClient
        .from('order_items')
        .update({'status': 'cancelled'})
        .eq('id', itemId);
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await supabaseClient
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id', orderId);
  }
}
