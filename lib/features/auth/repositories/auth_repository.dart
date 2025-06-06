import 'dart:io';

import 'package:agri_connect/core/exceptions/failures.dart';
import 'package:agri_connect/core/exceptions/server_exceptions.dart';
import 'package:agri_connect/features/auth/datasources/auth_remote_data.dart';
import 'package:agri_connect/features/auth/models/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepository(this.remoteDataSource);

  Future<Either<Failure, void>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, void>> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String type,
  }) async {
    try {
      await remoteDataSource.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
        type: type,
      );
      return Right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Sign out failed: ${e.toString()}"));
    }
  }

  Future<bool> checkUsernameAvailability(String username) async {
    return await remoteDataSource.isUsernameAvailable(username);
  }

  Future<Either<Failure, void>> updateUserProfile(UserModel updatedUser) async {
    try {
      await remoteDataSource.updateUser(updatedUser);
      return Right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, String>> uploadProfileImage(
    String userId,
    File imageFile,
  ) async {
    try {
      final imageUrl = await remoteDataSource.uploadProfileImage(
        userId,
        imageFile,
      );
      return Right(imageUrl);
    } on sb.AuthException catch (e) {
      return Left(Failure(e.message));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, void>> changeEmail({required String newEmail}) async {
    try {
      await remoteDataSource.changeEmail(newEmail: newEmail);
      return right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Future<Either<Failure, void>> changePassword({
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(newPassword: newPassword);
      return right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Unexpected error: ${e.toString()}"));
    }
  }

  Stream<Either<Failure, UserModel>> currentUser(String userId) async* {
    try {
      yield* remoteDataSource.getUserDataStream(userId).map((user) {
        if (user == null) {
          return left(Failure('User not logged in!'));
        } else {
          return right(user);
        }
      });
    } on ServerException catch (e) {
      yield left(Failure(e.message));
    } catch (e) {
      yield left(Failure('Unexpected error: $e'));
    }
  }
}
