import 'package:agri_connect/core/enums/order_status_enum.dart';
import 'package:agri_connect/core/exceptions/failures.dart';
import 'package:agri_connect/core/exceptions/server_exceptions.dart';
import 'package:agri_connect/features/products/datasources/order_remote_data.dart';
import 'package:agri_connect/features/products/models/order_items_model.dart';
import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  const OrderRepository(this.remoteDataSource);

  Future<Either<Failure, List<OrderModel>>> fetchOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final orders = await remoteDataSource.fetchOrdersByDateRange(start, end);
      return right(orders);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Stream<Either<Failure, List<OrderModel>>> fetchOrdersByBuyerId(
    String buyerId,
    String status,
  ) async* {
    try {
      await for (final orders in remoteDataSource.fetchOrdersByBuyerId(
        buyerId,
        status,
      )) {
        yield right(orders);
      }
    } on sb.AuthException catch (e) {
      yield left(Failure(e.message));
    } on ServerException catch (e) {
      yield left(Failure(e.message));
    } catch (e) {
      yield left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Stream<Either<Failure, String>> checkOrderItemStatus(
    String orderItemId,
  ) async* {
    try {
      await for (final status in remoteDataSource.checkOrderItemStatus(
        orderItemId,
      )) {
        yield right(status);
      }
    } on sb.AuthException catch (e) {
      yield left(Failure(e.message));
    } on ServerException catch (e) {
      yield left(Failure(e.message));
    } catch (e) {
      yield left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, OrderModel>> createOrder(OrderModel order) async {
    try {
      final created = await remoteDataSource.createOrder(order);
      return right(created);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, OrderModel>> updateOrder(
    String id,
    Map<String, dynamic> updatedFields,
  ) async {
    try {
      final updated = await remoteDataSource.updateOrder(id, updatedFields);
      return right(updated);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, void>> deleteOrderAndItems(String id) async {
    try {
      await remoteDataSource.deleteOrder(id);
      return right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, void>> createOrderItems(
    List<OrderItemModel> items,
  ) async {
    try {
      await remoteDataSource.createOrderItems(items);
      return right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, List<OrderItemModel>>> fetchOrderItems(
    String orderId,
  ) async {
    try {
      final orders = await remoteDataSource.fetchOrderItems(orderId);
      return right(orders);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, void>> updateOrderItemStatus({
    required String orderId,
    required String itemId,
    required String newStatus,
    String? columnToUpdate,
  }) async {
    try {
      await remoteDataSource.updateOrderItemStatus(
        itemId,
        newStatus,
        columnToUpdate,
      );
      if (newStatus == OrderStatus.confirmed.value) {
        await remoteDataSource.updateUserAccountBalance(
          itemId,
        );
      }
      await remoteDataSource.updateOrderIfAllMatchStatus(orderId, newStatus);
      return right(null);
    } catch (e) {
      return left(Failure('Failed to update status.'));
    }
  }

  Future<Either<Failure, List<OrderModel>>> ordersBySellerProvider(
    String seller,
    String status,
  ) async {
    try {
      final orders = await remoteDataSource.ordersBySellerProvider(
        seller,
        status,
      );

      return right(orders);
    } catch (e) {
      return left(Failure('Failed to update status.'));
    }
  }
}
