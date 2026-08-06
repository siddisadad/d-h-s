import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

part 'settings_provider.g.dart';

@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return SettingsRepositoryImpl();
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final repository = ref.read(settingsRepositoryProvider);
    final result = await repository.getSettings();
    return result.fold(
      (failure) => AppSettings(darkMode: false, language: 'en', currency: 'INR'),
      (settings) => settings,
    );
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    state = AsyncData(newSettings);
    final repository = ref.read(settingsRepositoryProvider);
    await repository.updateSettings(newSettings);
  }

  Future<void> toggleDarkMode(bool val) async {
    final current = state.value;
    if (current != null) {
      final updated = AppSettings(
        darkMode: val,
        language: current.language,
        currency: current.currency,
      );
      await updateSettings(updated);
    }
  }

  Future<void> setLanguage(String lang) async {
    final current = state.value;
    if (current != null) {
      final updated = AppSettings(
        darkMode: current.darkMode,
        language: lang,
        currency: current.currency,
      );
      await updateSettings(updated);
    }
  }

  Future<void> setCurrency(String curr) async {
    final current = state.value;
    if (current != null) {
      final updated = AppSettings(
        darkMode: current.darkMode,
        language: current.language,
        currency: curr,
      );
      await updateSettings(updated);
    }
  }
}
