import 'package:agri_connect/core/enums/order_status_enum.dart';
import 'package:agri_connect/core/shared/providers/supabase_client_provider.dart';
import 'package:agri_connect/core/utils/date_range.dart';
import 'package:agri_connect/features/account/presentation/providers/account_provider.dart';
import 'package:agri_connect/features/products/datasources/order_remote_data.dart';
import 'package:agri_connect/features/products/models/order_items_model.dart';
import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:agri_connect/features/products/presentation/providers/order_state.dart';
import 'package:agri_connect/features/products/repository/order_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderNotifier(repository: repository);
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

OrderModel generateOrder(String buyerId, Map<StockModel, int> cart) {
  final orderId = uuid.v4();
  final now = DateTime.now();
  final totalAmount = cart.entries
      .map((e) => e.key.price * e.value)
      .fold(0.0, (sum, val) => sum + val);

  return OrderModel(
    id: orderId,
    buyerId: buyerId,
    totalAmount: totalAmount,
    createdAt: now,
  );
}

List<OrderItemModel> generateOrderItems(
  String orderId,
  Map<StockModel, int> cart,
) {
  final now = DateTime.now();
  return cart.entries.map((entry) {
    final item = entry.key;
    final quantity = entry.value;

    return OrderItemModel(
      id: uuid.v4(),
      orderId: orderId,
      stockId: item.id,
      sellerId: item.userId,
      quantity: quantity,
      price: item.price,
      status: OrderStatus.pending,
      deliveredAt: null,
      confirmedAt: null,
      createdAt: now,
    );
  }).toList();
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository repository;

  OrderNotifier({required this.repository}) : super(OrderInitial());

  // Main method for placing an order with balance check
  Future<void> placeOrderWithBalanceCheck({
    required String buyerId,
    required double balance,
    required Map<StockModel, int> cart,
    required WidgetRef ref,
  }) async {
    try {
      state = OrderLoading();

      // Step 1: Calculate total order amount
      final totalAmount = cart.entries
          .map((e) => e.key.price * e.value)
          .fold(0.0, (sum, val) => sum + val);

      // Step 2: Check if user has enough balance
      if (balance < totalAmount) {
        state = OrderFailure("Insufficient balance to complete the order.");
        return;
      }

      // Step 3: Generate order and items
      final order = generateOrder(buyerId, cart);
      final orderItems = generateOrderItems(order.id, cart);

      // Step 4: Create order record
      final orderResult = await repository.createOrder(order);

      await orderResult.fold(
        (failure) async {
          state = OrderFailure(failure.message);
        },
        (savedOrder) async {
          // Step 5: Save order items
          final orderItemResult = await repository.createOrderItems(orderItems);
          await orderItemResult.fold(
            (failure) async {
              state = OrderFailure(
                "Failed to save order items: ${failure.message}",
              );
              return;
            },
            (items) async {
              // Step 6: Deduct balance from buyer
              final accountNotifier = ref.read(
               accountProvider.notifier,
              );
              await accountNotifier.withdraw(buyerId, totalAmount);

              // Step 7: Deposit earnings to each seller (group by sellerId)
              final sellerEarnings = <String, double>{};

              for (var item in orderItems) {
                sellerEarnings[item.sellerId] =
                    (sellerEarnings[item.sellerId] ?? 0) +
                    (item.price * item.quantity);
              }

              for (final entry in sellerEarnings.entries) {
                await accountNotifier.deposit(entry.key, entry.value);
              }

              state = OrderSuccess();
            },
          );
        },
      );
    } catch (e) {
      state = OrderFailure("An error occurred: $e");
    }
  }

  // Fetch a stream of orders
  Stream<List<OrderModel>?> fetchOrder(String? id) {
    return repository.fetchOrder(id).map((either) {
      return either.fold(
        (failure) => throw Exception(failure.message),
        (orders) => orders,
      );
    });
  }

  // Fetch orders in a date range
  Future<List<OrderModel>> fetchOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final either = await repository.fetchOrdersByDateRange(start, end);
    return either.fold(
      (failure) => throw Exception(failure.message),
      (orders) => orders,
    );
  }

  //  Fetch orders by a buyer ID
  Future<List<OrderModel>?> fetchOrdersByBuyerId(String buyerId) async {
    final either = await repository.fetchOrdersByBuyerId(buyerId);
    return either.fold(
      (failure) => throw Exception(failure.message),
      (orders) => orders,
    );
  }

  //  Create order (manual, without balance check)
  Future<void> createOrder(OrderModel order) async {
    final either = await repository.createOrder(order);
    either.fold(
      (failure) => state = OrderFailure(failure.message),
      (order) => state = OrderSuccess(),
    );
  }

  //  Update existing order
  Future<void> updateOrder(String id, Map<String, dynamic> fields) async {
    final either = await repository.updateOrder(id, fields);
    either.fold(
      (failure) => state = OrderFailure(failure.message),
      (order) => state = OrderSuccess(),
    );
  }

  // Delete order
  Future<void> deleteOrder(String id) async {
    final either = await repository.deleteOrder(id);
    either.fold(
      (failure) => state = OrderFailure(failure.message),
      (order) => state = OrderSuccess(),
    );
  }
}
