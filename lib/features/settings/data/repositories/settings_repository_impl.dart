import 'package:shared_preferences/shared_preferences.dart';
import 'package:deshmukh_steel_e_r_p/core/error/failures.dart';
import 'package:deshmukh_steel_e_r_p/core/error/result.dart';
import 'package:deshmukh_steel_e_r_p/features/settings/domain/entities/app_settings.dart';
import 'package:deshmukh_steel_e_r_p/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _keyDarkMode = 'settings_dark_mode';
  static const String _keyLanguage = 'settings_language';
  static const String _keyCurrency = 'settings_currency';

  @override
  Future<Result<AppSettings>> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Result.success(AppSettings(
        darkMode: prefs.getBool(_keyDarkMode) ?? false,
        language: prefs.getString(_keyLanguage) ?? 'en',
        currency: prefs.getString(_keyCurrency) ?? 'INR',
      ));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, settings.darkMode);
      await prefs.setString(_keyLanguage, settings.language);
      await prefs.setString(_keyCurrency, settings.currency);
      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
