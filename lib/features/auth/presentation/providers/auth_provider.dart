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

    result.fold(
      (failure) => state = auth.AuthFailure(failure.message),
      (_) => state = auth.AuthSuccess(),
    );
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

  Stream<UserModel?> loadUserDetails(String userId) {
    return _repository.currentUser(userId).map((either) {
      return either.fold(
        (failure) {
          // state = auth.AuthFailure(failure.message);
          return null;
        },
        (user) {
          // state = auth.AuthSuccess();
          return user;
        },
      );
    });
  }
}
