import 'package:deshmukh_steel_e_r_p/core/error/failures.dart';
import 'package:deshmukh_steel_e_r_p/core/error/result.dart';
import 'package:deshmukh_steel_e_r_p/features/settings/domain/entities/app_settings.dart';
import 'package:deshmukh_steel_e_r_p/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<Result<AppSettings>> getSettings() async {
    try {
      return Result.success(AppSettings(darkMode: false, language: 'en', currency: 'INR'));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateSettings(AppSettings settings) async {
    return Result.success(null);
  }
}
