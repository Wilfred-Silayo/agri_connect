import 'package:agri_connect/core/exceptions/failures.dart';
import 'package:agri_connect/core/exceptions/server_exceptions.dart';
import 'package:agri_connect/features/products/datasources/stock_remote_data.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class StockRepository {
  final StockRemoteDataSource remoteDataSource;
  const StockRepository(this.remoteDataSource);

  Stream<Either<Failure, List<StockModel>>> fetchStock(
    String? id,
    String? query,
  ) async* {
    try {
      await for (final stocks in remoteDataSource.fetchStock(id, query)) {
        yield right(stocks);
      }
    } on sb.AuthException catch (e) {
      yield left(Failure(e.message));
    } on ServerException catch (e) {
      yield left(Failure(e.message));
    } catch (e) {
      yield left(Failure("Unexpected error: \${e.toString()}"));
    }
  }

  Future<Either<Failure, List<StockModel>?>> fetchStockByUserId(
    String userId,
  ) async {
    try {
      final stocks = await remoteDataSource.fetchStockByUserId(userId);
      return right(stocks);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: \${e.toString()}"));
    }
  }

  Future<Either<Failure, StockModel>> createStock(StockModel stock) async {
    try {
      final created = await remoteDataSource.createStock(stock);
      return right(created);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: \${e.toString()}"));
    }
  }

  Future<Either<Failure, List<String>>> uploadImages(List<XFile> images) async {
    try {
      final created = await remoteDataSource.uploadImages(images);
      return right(created);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: \${e.toString()}"));
    }
  }

  Future<Either<Failure, StockModel>> updateStock(
    String id,
    StockModel stock,
  ) async {
    try {
      final updated = await remoteDataSource.updateStock(id, stock);
      return right(updated);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: \${e.toString()}"));
    }
  }

  Future<Either<Failure, void>> deleteStock(String id) async {
    try {
      await remoteDataSource.deleteStock(id);
      return right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: \${e.toString()}"));
    }
  }
}
