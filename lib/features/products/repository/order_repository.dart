import 'package:agri_connect/core/exceptions/failures.dart';
import 'package:agri_connect/core/exceptions/server_exceptions.dart';
import 'package:agri_connect/features/products/datasources/order_remote_data.dart';
import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  const OrderRepository(this.remoteDataSource);

  Stream<Either<Failure, List<OrderModel>>> fetchOrder(String? id) async* {
    try {
      await for (final orders in remoteDataSource.fetchOrder(id)) {
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

  Future<Either<Failure, List<OrderModel>>> fetchOrdersByBuyerId(
    String buyerId,
  ) async {
    try {
      final orders = await remoteDataSource.fetchOrdersByBuyerId(buyerId);
      return right(orders);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
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

  Future<Either<Failure, void>> deleteOrder(String id) async {
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
}
