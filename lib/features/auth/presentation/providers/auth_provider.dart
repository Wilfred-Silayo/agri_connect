import 'dart:io';

import 'package:agri_connect/core/shared/providers/supabase_client_provider.dart';
import 'package:agri_connect/features/auth/datasources/auth_remote_data.dart';
import 'package:agri_connect/features/auth/models/user_model.dart';
import 'package:agri_connect/features/auth/repositories/auth_repository.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_state.dart'
    as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

final userDetailsProvider = StreamProvider.family<UserModel?, String>((
  ref,
  userId,
) {
  return ref.watch(authNotifierProvider.notifier).loadUserDetails(userId);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final remote = AuthRemoteDataSourceImpl(client);
  return AuthRepository(remote);
});

// for create, read,update, delete purposes
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, auth.AuthState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthNotifier(repository);
    });

class AuthNotifier extends StateNotifier<auth.AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(auth.AuthInitial());

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String type,
  }) async {
    state = auth.AuthLoading();
    final result = await _repository.signUpWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
      type: type,
    );

    result.fold((failure) => state = auth.AuthFailure(failure.message), (
      _,
    ) async {
      // supabase automatically signin after signup unless email comfirmation is required
      //we have to signout first before redirecting to signinpage
      await _repository.signOut();
      state = auth.AuthInitial();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = auth.AuthLoading();
    final result = await _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = auth.AuthFailure(failure.message),
      (_) => state = auth.AuthSuccess(),
    );
  }

  Future<void> signOut() async {
    state = auth.AuthLoading();
    final result = await _repository.signOut();

    result.fold(
      (failure) => state = auth.AuthFailure(failure.message),
      (_) => state = auth.AuthInitial(),
    );
  }

  Future<bool> checkUsernameAvailability(String username) async {
    return await _repository.checkUsernameAvailability(username);
  }

  Future<void> updateUserProfile(
    UserModel updatedUser,
    File? newProfileImage,
  ) async {
    state = auth.AuthLoading();

    String? newAvatarUrl;
    if (newProfileImage != null) {
      newAvatarUrl = await uploadProfileImage(updatedUser.id, newProfileImage);
      if (newAvatarUrl == null) {
        // Upload failed, state already set inside uploadProfileImage
        return;
      }
      updatedUser = updatedUser.copyWith(avatarUrl: newAvatarUrl);
    }

    final result = await _repository.updateUserProfile(updatedUser);
    result.fold(
      (failure) => state = auth.AuthFailure(failure.message),
      (_) => state = auth.AuthSuccess(),
    );
  }

  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    final result = await _repository.uploadProfileImage(userId, imageFile);
    String? imageUrl;
    result.fold(
      (failure) => state = auth.AuthFailure(failure.message),
      (url) => imageUrl = url,
    );
    return imageUrl;
  }

  Future<void> changeEmail({required String newEmail}) async {
    state = auth.AuthLoading();

    final result = await _repository.changeEmail(newEmail: newEmail);

    result.fold(
      (failure) => state = auth.AuthFailure(failure.message),
      (_) => state = auth.AuthSuccess(),
    );
  }

  Future<void> changePassword({required String newPassword}) async {
    state = auth.AuthLoading();

    final result = await _repository.changePassword(newPassword: newPassword);

    result.fold(
      (failure) => state = auth.AuthFailure(failure.message),
      (_) => state = auth.AuthSuccess(),
    );
  }

  Stream<UserModel?> loadUserDetails(String userId) {
    return _repository.currentUser(userId).map((either) {
      return either.fold(
        (failure) {
          // state = auth.AuthFailure(failure.message);
          throw Exception(failure.message);
        },
        (user) {
          // state = auth.AuthSuccess();
          return user;
        },
      );
    });
  }
}
