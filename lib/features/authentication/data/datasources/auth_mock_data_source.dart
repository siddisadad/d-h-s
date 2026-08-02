import 'dart:async';
import '../../domain/entities/app_user.dart';
import 'auth_remote_data_source.dart';

class AuthMockDataSource implements AuthRemoteDataSource {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Artificial delay for realism
    await Future.delayed(const Duration(milliseconds: 800));
    
    return {
      'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'mock-user-123',
        'email': email,
        'displayName': 'Admin User (Mock)',
        'role': 'Admin',
      }
    };
  }

  @override
  Future<AppUser> getProfile() async {
    return AppUser(
      id: 'mock-user-123',
      email: 'admin@dhs.com',
      displayName: 'Admin User (Mock)',
      role: 'Admin',
    );
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
