import 'package:flutter/material.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository repository;

  SettingsProvider({required this.repository});

  AppSettings? _settings;
  AppSettings? get settings => _settings;

  Future<void> loadSettings() async {
    final result = await repository.getSettings();
    result.fold((f) => null, (s) => _settings = s);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool val) async {
    if (_settings != null) {
      _settings = AppSettings(darkMode: val, language: _settings!.language, currency: _settings!.currency);
      await repository.updateSettings(_settings!);
      notifyListeners();
    }
  }
}
