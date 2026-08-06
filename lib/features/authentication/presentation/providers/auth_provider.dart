import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_mock_data_source.dart';
import '../../data/repositories/token_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  final useMocks = AppConfig.useMocks;

  final authDataSource = useMocks
      ? AuthMockDataSource()
      : AuthRemoteDataSourceImpl(client);

  return AuthRepositoryImpl(authDataSource);
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  FutureOr<AppUser?> build() async {
    final token = await ref.read(tokenRepositoryProvider).getToken();
    if (token != null) {
      debugPrint('🗝️ Found stored token, attempting session recovery...');
      try {
        final user = await ref.read(authRepositoryProvider).getUserByToken(token);
        if (user != null) {
          debugPrint('✅ Session recovered for: ${user.displayName}');
          return user;
        }
      } catch (e) {
        debugPrint('⚠️ Session recovery failed: $e');
        await ref.read(tokenRepositoryProvider).deleteToken();
      }
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    debugPrint('🔑 [AuthProvider] Login attempt: $email');

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(email, password);

      if (user == null) {
        throw Exception('Invalid credentials or authentication error');
      }

      // Save token (mock or real)
      await ref.read(tokenRepositoryProvider).saveToken('session_token_${DateTime.now().millisecondsSinceEpoch}');

      debugPrint('✅ [AuthProvider] Login successful: ${user.displayName}');
      return user;
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).logout();
    await ref.read(tokenRepositoryProvider).deleteToken();
    state = const AsyncData(null);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }
    
    await ref.read(authRepositoryProvider).resetPassword(email);
  }
}
