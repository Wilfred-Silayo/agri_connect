import 'package:agri_connect/core/shared/providers/supabase_client_provider.dart';
import 'package:agri_connect/core/utils/stock_query.dart';
import 'package:agri_connect/features/products/datasources/stock_remote_data.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:agri_connect/features/products/presentation/providers/stock_state.dart';
import 'package:agri_connect/features/products/repository/stock_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final stockNotifierProvider = StateNotifierProvider<StockNotifier, StockState>((
  ref,
) {
  final repository = ref.watch(stockRepositoryProvider);
  return StockNotifier(repository);
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final remoteDataSource = ref.watch(stockRemoteDataSourceProvider);
  return StockRepository(remoteDataSource);
});

final stockRemoteDataSourceProvider = Provider<StockRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StockRemoteDataSourceImpl(client);
});

final fetchStockProvider = StreamProvider.family<List<StockModel>?, StockQuery>(
  (ref, query) {
    final notifier = ref.watch(stockNotifierProvider.notifier);
    return notifier.fetchStock(query.id, query.query);
  },
);

class StockNotifier extends StateNotifier<StockState> {
  final StockRepository _repository;
  StockNotifier(this._repository) : super(StockInitial());

  Stream<List<StockModel>?> fetchStock(String? id, String? query) {
    return _repository.fetchStock(id, query).map((either) {
      return either.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (stocks) {
          return stocks;
        },
      );
    });
  }

  Future<void> createStock(StockModel stock, List<XFile> images) async {
    state = StockLoading("Creating stock...");

    final res = await _repository.uploadImages(images);

    res.fold(
      (failure) {
        state = StockFailure(failure.message);
      },
      (imageUrls) async {
        final updatedStock = stock.copyWith(images: imageUrls);

        final result = await _repository.createStock(updatedStock);

        result.fold(
          (failure) => state = StockFailure(failure.message),
          (_) => state = StockSuccess("Created Successfully"),
        );
      },
    );
  }

  // FETCH BY USER ID
  Future<void> fetchStockByUserId(String userId) async {
    state = StockLoading('Fetching stock...');
    final result = await _repository.fetchStockByUserId(userId);
    result.fold(
      (failure) => state = StockFailure(failure.message),
      (stocks) => state = StockSuccess('Fetched successfully'),
    );
  }

  Future<void> deleteStock(String id) async {
    state = StockLoading('Deleting stock...');
    final result = await _repository.deleteStock(id);
    result.fold(
      (failure) => state = StockFailure(failure.message),
      (_) => state = StockSuccess("Deleted Successfully"),
    );
  }

  Future<void> updateStock(
    String id,
    StockModel stock,
    List<XFile> images,
  ) async {
    state = StockLoading('Updating stock...');

    // Upload new images only if provided
    List<String> imageUrls = stock.images ?? [];

    if (images.isNotEmpty) {
      final res = await _repository.uploadImages(images);

      final uploadFailed = res.fold(
        (failure) {
          state = StockFailure(failure.message);
          return true;
        },
        (urls) {
          imageUrls = urls;
          return false;
        },
      );

      if (uploadFailed) return;
    }

    final updatedStock = stock.copyWith(images: imageUrls);

    final result = await _repository.updateStock(id, updatedStock);
    result.fold(
      (failure) => state = StockFailure(failure.message),
      (_) => state = StockSuccess("Updated Successfully"),
    );
  }
}
