import '../../../../core/error/result.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<Result<AppSettings>> getSettings();
  Future<Result<void>> updateSettings(AppSettings settings);
}
