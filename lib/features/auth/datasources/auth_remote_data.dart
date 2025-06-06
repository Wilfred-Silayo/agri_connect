import 'dart:io';

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

  Future<bool> isUsernameAvailable(String username);

  Future<void> updateUser(UserModel user);

  Future<String> uploadProfileImage(String userId, File imageFile);

  Future<void> changeEmail({required String newEmail});

  Future<void> changePassword({required String newPassword});

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

      await supabaseClient.from('users').insert({
        'id': user.id,
        'email': email,
        'full_name': name,
        'user_type': type,
      });
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

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await supabaseClient
          .from('users')
          .update({
            'username': user.username,
            'full_name': user.fullName,
            'bio': user.bio,
            'avatar_url': user.avatarUrl,
            'phone': user.phone,
            'address': user.address,
            // 'user_type': user.userType.type,
          })
          .eq('id', user.id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final path = 'profile_images/$userId.jpg';

      await supabaseClient.storage
          .from('avatars')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = supabaseClient.storage
          .from('avatars')
          .getPublicUrl(path);

      // Add a timestamp or unique param to bust cache
      final cacheBustedUrl =
          '$imageUrl?updated_at=${DateTime.now().millisecondsSinceEpoch}';

      return cacheBustedUrl;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> changeEmail({required String newEmail}) async {
    try {
      final session = supabaseClient.auth.currentSession;

      if (session == null) {
        throw ServerException('No active session found');
      }

      final response = await supabaseClient.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      if (response.user == null) {
        throw ServerException('Failed to update email');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword({required String newPassword}) async {
    try {
      final session = supabaseClient.auth.currentSession;

      if (session == null) {
        throw ServerException('No active session found');
      }

      final response = await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw ServerException('Failed to update password');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response =
          await supabaseClient
              .from('users')
              .select('id')
              .eq('username', username)
              .maybeSingle();

      return response == null;
    } catch (e) {
      return false;
    }
  }
}
