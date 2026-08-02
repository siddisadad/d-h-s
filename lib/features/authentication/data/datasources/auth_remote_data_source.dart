import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<AppUser> getProfile();
  Future<void> resetPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('⚠️ [API] Login Request Failed: $e');
      if (kDebugMode) {
        debugPrint('🛠️ [Debug Fallback] Simulating successful login for: $email');
        return {
          'token': 'mock_debug_jwt_token',
          'user': {
            'id': 'debug-1',
            'email': email,
            'displayName': 'Debug Administrator',
            'role': 'Admin',
          }
        };
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> getProfile() async {
    try {
      final response = await _client.dio.get('/auth/profile');

      if (response.statusCode == 200) {
        return AppUser.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch profile');
      }
    } catch (e) {
      debugPrint('⚠️ [API] Get Profile Failed: $e');
      if (kDebugMode) {
        debugPrint('🛠️ [Debug Fallback] Simulating profile recovery...');
        return AppUser(
          id: 'debug-1',
          email: 'admin@dhs.com',
          displayName: 'Debug Administrator',
          role: 'Admin',
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _client.dio.post('/auth/reset-password', data: {'email': email});
    } catch (e) {
      debugPrint('⚠️ [API] Reset Password Failed: $e');
      if (kDebugMode) {
        debugPrint('🛠️ [Debug Fallback] Simulating success for Reset Password...');
        return;
      }
      rethrow;
    }
  }
}
