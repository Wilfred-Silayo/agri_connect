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
  Future<List<OrderModel>> ordersBySellerProvider(String seller, String status);
  Future<void> cancelOrderItem(String itemId);
  Future<void> cancelOrder(String orderId);
  Future<void> updateUserAccountBalance(String itemId);
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
  Future<void> deleteOrder(String orderId) async {
    try {
      await supabaseClient.from('order_items').delete().eq('order_id', orderId);
      await supabaseClient.from('orders').delete().eq('id', orderId);
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
    final response = await supabaseClient
        .from('order_items')
        .select('status')
        .eq('order_id', orderId);

    // Ensure the response is a list of maps
    final List<Map<String, dynamic>> statuses = List<Map<String, dynamic>>.from(
      response,
    );

    final allMatch =
        statuses.isNotEmpty &&
        statuses.every((row) => row['status'] == newStatus);

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
    try {
      // Step 1: Fetch current order item
      final response =
          await supabaseClient
              .from('order_items')
              .select('stock_id, quantity, status')
              .eq('id', itemId)
              .single();

      final item = response;

      final productId = item['stock_id'];
      final quantity = item['quantity'];
      final currentStatus = item['status'];

      // Step 2: If item is being cancelled (and wasn't already), update product stock
      if (currentStatus != 'cancelled' && newStatus == 'cancelled') {
        final productResponse =
            await supabaseClient
                .from('stocks')
                .select('quantity')
                .eq('id', productId)
                .single();

        final currentStock = productResponse['quantity'] ?? 0;

        await supabaseClient
            .from('stocks')
            .update({'quantity': currentStock + quantity})
            .eq('id', productId);
      }

      // Step 3: Update order item status
      final updateData = {
        'status': newStatus,
        if (columnToUpdate != null)
          columnToUpdate: DateTime.now().toIso8601String(),
      };

      await supabaseClient
          .from('order_items')
          .update(updateData)
          .eq('id', itemId);
    } catch (e) {
      rethrow;
    }
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

  @override
  Future<void> updateUserAccountBalance(String itemId) async {
    // Fetch order item details
    final itemRes =
        await supabaseClient
            .from('order_items')
            .select('seller_id, price')
            .eq('id', itemId)
            .maybeSingle();

    if (itemRes == null) {
      return;
    }

    final sellerId = itemRes['seller_id'];
    final itemPrice = (itemRes['price'] as num?)?.toDouble() ?? 0.0;

    // Check if account exists
    var accountRes =
        await supabaseClient
            .from('accounts')
            .select('balance')
            .eq('user_id', sellerId)
            .maybeSingle();

    double currentBalance;

    if (accountRes == null) {
      // Create new account with initial balance 0
      await supabaseClient.from('accounts').insert({
        'user_id': sellerId,
        'balance': 0.0,
      });

      currentBalance = 0.0;
    } else {
      currentBalance = (accountRes['balance'] as num?)?.toDouble() ?? 0.0;
    }

    final newBalance = currentBalance + itemPrice;

    // Update the balance
    await supabaseClient
        .from('accounts')
        .update({'balance': newBalance})
        .eq('user_id', sellerId);
  }

  @override
  Future<List<OrderModel>> ordersBySellerProvider(
    String seller,
    String status,
  ) async {
    // Step 1: Get order_items for this seller and status
    final itemRes = await supabaseClient
        .from('order_items')
        .select('*')
        .eq('seller_id', seller)
        .eq('status', status);

    final items =
        (itemRes as List).map((e) => OrderItemModel.fromMap(e)).toList();

    // Step 2: Group by order_id
    final orderIds = items.map((e) => e.orderId).toSet().toList();
    if (orderIds.isEmpty) return [];

    // Step 3: Fetch corresponding orders
    final orderRes = await supabaseClient
        .from('orders')
        .select('*')
        .filter('id', 'in', '(${orderIds.map((e) => '"$e"').join(",")})');

    final rawOrders =
        (orderRes as List).map((e) => OrderModel.fromMap(e)).toList();

    // Step 4: Attach only seller's items to each order
    final result =
        rawOrders.map((order) {
          final filteredItems =
              items.where((i) => i.orderId == order.id).toList();
          return order.copyWith(items: filteredItems);
        }).toList();

    return result;
  }
}
