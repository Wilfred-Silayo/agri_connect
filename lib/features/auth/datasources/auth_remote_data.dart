import 'package:agri_connect/core/exceptions/server_exceptions.dart';
import 'package:agri_connect/features/auth/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<void> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String type,
  });
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Stream<UserModel?> getUserDataStream(String userId);

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String name,
    required String password,
    required String type,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
      );

      final user = response.user;

      if (user == null) {
        throw ServerException('User is null!');
      }

      final insertResponse = await supabaseClient.from('users').insert({
        'id': user.id,
        'email': email,
        'full_name': name,
        'user_type': type,
      });

      if (insertResponse.error != null) {
        throw ServerException(insertResponse.error!.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw ServerException('User is null!');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<UserModel?> getUserDataStream(String userId) {
    return supabaseClient
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((rows) {
          if (rows.isEmpty) return null;
          return UserModel.fromMap(rows.first);
        });
  }
}
