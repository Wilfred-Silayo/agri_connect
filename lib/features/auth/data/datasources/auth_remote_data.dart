import 'package:agri_connect/core/exceptions/server_exceptions.dart';
import 'package:agri_connect/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;

  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String type,
  });
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel?> getCurrentUserData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> signUpWithEmailAndPassword({
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
        'name': name,
        'type': type,
      });

      if (insertResponse.error != null) {
        throw ServerException(insertResponse.error!.message);
      }

      return UserModel.fromMap(user.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
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
      return UserModel.fromMap(response.user!.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient
            .from('users')
            .select()
            .eq('id', currentUserSession!.user.id);
        return UserModel.fromMap(userData.first);
      }

      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}


