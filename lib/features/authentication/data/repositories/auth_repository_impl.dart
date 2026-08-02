import 'package:flutter/foundation.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AppUser?> login(String email, String password) async {
    try {
      debugPrint('AuthRepo: login attempt with $email');
      final data = await _remoteDataSource.login(email, password);
      final response = AuthResponseModel.fromJson(data);
      return response.user;
    } catch (e) {
      debugPrint('AuthRepo Error: $e');
      return null;
    }
  }

  @override
  Future<AppUser?> getUserByToken(String token) async {
    try {
      debugPrint('AuthRepo: recovering session...');
      return await _remoteDataSource.getProfile();
    } catch (e) {
      debugPrint('AuthRepo Session Recovery Error: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    // Usually a backend call isn't mandatory for JWT logout, but we can add if needed
  }

  @override
  Future<void> resetPassword(String email) async {
    await _remoteDataSource.resetPassword(email);
  }
}
