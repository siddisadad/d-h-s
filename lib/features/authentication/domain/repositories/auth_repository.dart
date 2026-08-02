import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> login(String email, String password);
  Future<AppUser?> getUserByToken(String token);
  Future<void> logout();
  Future<void> resetPassword(String email);
}
