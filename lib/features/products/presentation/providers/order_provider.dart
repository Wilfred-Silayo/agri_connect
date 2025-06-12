import 'package:agri_connect/core/enums/order_status_enum.dart';
import 'package:agri_connect/core/shared/providers/supabase_client_provider.dart';
import 'package:agri_connect/core/utils/date_range.dart';
import 'package:agri_connect/core/utils/order_query.dart';
import 'package:agri_connect/features/account/presentation/providers/account_provider.dart';
import 'package:agri_connect/features/products/datasources/order_remote_data.dart';
import 'package:agri_connect/features/products/models/order_items_model.dart';
import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:agri_connect/features/products/presentation/providers/order_state.dart';
import 'package:agri_connect/features/products/presentation/providers/stock_provider.dart';
import 'package:agri_connect/features/products/repository/order_repository.dart';
import 'package:agri_connect/features/products/repository/stock_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  final stockRepository = ref.watch(stockRepositoryProvider);
  return OrderNotifier(
    repository: repository,
    stockRepository: stockRepository,
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final remote = OrderRemoteDataSourceImpl(client);
  return OrderRepository(remote);
});

final ordersByBuyerProvider =
    StreamProvider.family<List<OrderModel>, OrderQuery>((ref, query) {
      final notifier = ref.watch(orderNotifierProvider.notifier);
      return notifier.fetchOrdersByBuyerId(query.buyer, query.status);
    });

final ordersByDateRangeProvider =
    FutureProvider.family<List<OrderModel>?, DateRange>((ref, range) async {
      final notifier = ref.watch(orderNotifierProvider.notifier);
      return notifier.fetchOrdersByDateRange(range.start, range.end);
    });

final orderItemsProvider = FutureProvider.family<List<OrderItemModel>, String>((
  ref,
  orderId,
) async {
  final notifier = ref.watch(orderNotifierProvider.notifier);
  return notifier.fetchOrderItems(orderId);
});

final orderItemStatusProvider = StreamProvider.family<String, String>((
  ref,
  orderItemId,
) {
  final notifier = ref.watch(orderNotifierProvider.notifier);
  return notifier.checkOrderItemStatus(orderItemId);
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
    status: OrderStatus.pending,
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
  final StockRepository stockRepository;

  OrderNotifier({required this.repository, required this.stockRepository})
    : super(OrderInitial());

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
        final shortage = totalAmount - balance;
        state = OrderFailure(
          "Insufficient balance to complete the order. You need an additional ${shortage.toStringAsFixed(2)} TZS.",
        );
        return;
      }

      // Step 3: Generate order and items
      final order = generateOrder(buyerId, cart);
      final orderItems = generateOrderItems(order.id, cart);

      //step 4: Prepare stock updates map
      final stockUpdates = [
        for (var entry in cart.entries)
          {'id': entry.key.id, 'quantity': entry.value},
      ];

      // Step 5: Create order record
      final orderResult = await repository.createOrder(order);

      await orderResult.fold(
        (failure) async {
          state = OrderFailure(failure.message);
        },
        (savedOrder) async {
          // Step 6: Save order items
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
              final accountNotifier = ref.read(accountProvider.notifier);
              await accountNotifier.withdraw(buyerId, totalAmount);

              // Update stock quantities
              final stockResult = await stockRepository.updateMultipleStocks(
                stockUpdates,
              );
              await stockResult.fold(
                (failure) async {
                  state = OrderFailure(
                    "Failed to save order items: ${failure.message}",
                  );
                  return;
                },
                (items) async {
                  state = OrderSuccess();
                },
              );
            },
          );
        },
      );
    } catch (e) {
      state = OrderFailure("An error occurred: $e");
    }
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
  Stream<List<OrderModel>> fetchOrdersByBuyerId(String buyerId, String status) {
    return repository.fetchOrdersByBuyerId(buyerId, status).map((either) {
      return either.fold(
        (failure) => throw Exception(failure.message),
        (orders) => orders,
      );
    });
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

  Future<List<OrderItemModel>> fetchOrderItems(String orderId) async {
    final res = await repository.fetchOrderItems(orderId);
    return res.fold(
      (failure) => throw Exception(failure.message),
      (success) => success,
    );
  }

  Stream<String> checkOrderItemStatus(String orderItemId) {
    return repository.checkOrderItemStatus(orderItemId).map((res) {
      return res.fold(
        (failure) => throw Exception(failure.message),
        (status) => status,
      );
    });
  }

  Future<void> updateOrderItemStatus({
    required String orderId,
    required String itemId,
    required String newStatus,
    String? columnToUpdate,
  }) async {
    final result = await repository.updateOrderItemStatus(
      itemId: itemId,
      orderId: orderId,
      newStatus: newStatus,
    );
    result.fold(
      (failure) => state = OrderFailure(failure.message),
      (_) => state = OrderSuccess(),
    );
  }

  Future<void> cancelOrderItemAndMaybeOrder(
    String itemId,
    String orderId,
  ) async {
    state = OrderLoading();
    final result = await repository.cancelOrderItemAndMaybeOrder(
      itemId,
      orderId,
    );

    result.fold(
      (failure) => state = OrderFailure(failure.message),
      (_) => state = OrderSuccess(),
    );
  }
}
