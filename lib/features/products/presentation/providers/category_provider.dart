import 'package:agri_connect/features/products/models/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final categoryProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final response = await Supabase.instance.client.from('categories').select();

  final data = response as List;
  return data.map((e) => CategoryModel.fromMap(e)).toList();
});
