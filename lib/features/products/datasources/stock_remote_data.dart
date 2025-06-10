import 'dart:io';

import 'package:agri_connect/core/exceptions/server_exceptions.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract interface class StockRemoteDataSource {
  Stream<List<StockModel>> fetchStock(String? id, String? query);
  Future<List<StockModel>?> fetchStockByUserId(String userId);
  Future<StockModel> createStock(StockModel stock);
  Future<StockModel> updateStock(String id, StockModel stock);
  Future<void> deleteStock(String id);
  Future<List<String>> uploadImages(List<XFile> images);
}

class StockRemoteDataSourceImpl implements StockRemoteDataSource {
  final SupabaseClient supabaseClient;
  const StockRemoteDataSourceImpl(this.supabaseClient);

  @override
  Stream<List<StockModel>> fetchStock(String? id, String? query) {
    final stream =
        (id != null)
            ? supabaseClient
                .from('stocks')
                .stream(primaryKey: ['id'])
                .eq('category_id', id)
            : supabaseClient.from('stocks').stream(primaryKey: ['id']);

    return stream.map((data) {
      final models = data.map((e) => StockModel.fromMap(e)).toList();

      if (query != null && query.isNotEmpty) {
        return models
            .where(
              (item) => item.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }

      return models;
    });
  }

  @override
  Future<List<StockModel>?> fetchStockByUserId(String userId) async {
    try {
      final response = await supabaseClient
          .from('stocks')
          .select()
          .eq('user_id', userId);

      return (response as List)
          .map((item) => StockModel.fromMap(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StockModel> createStock(StockModel stock) async {
    try {
      final response =
          await supabaseClient
              .from('stocks')
              .insert(stock.toMap())
              .select()
              .single();

      return StockModel.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StockModel> updateStock(String id, StockModel stock) async {
    try {
      final response =
          await supabaseClient
              .from('stocks')
              .update(stock.toMap())
              .eq('id', id)
              .select()
              .single();

      return StockModel.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteStock(String id) async {
    try {
      await supabaseClient.from('stocks').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> uploadImages(List<XFile> images) async {
    try {
      final uuid = Uuid();
      final List<String> uploadedUrls = [];

      for (final image in images) {
        // Generate a unique filename using UUID
        final uniqueFileName = 'stocks/${uuid.v4()}_${image.name}';

        final file = File(image.path);

        await supabaseClient.storage
            .from('avatars')
            .upload(
              uniqueFileName,
              file,
              fileOptions: const FileOptions(upsert: true),
            );

        final publicUrl = supabaseClient.storage
            .from('avatars')
            .getPublicUrl(uniqueFileName);

        final cacheBustedUrl =
            '$publicUrl?updated_at=${DateTime.now().millisecondsSinceEpoch}';

        uploadedUrls.add(cacheBustedUrl);
      }

      return uploadedUrls;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
