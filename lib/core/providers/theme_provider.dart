import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

const String _themeKey = 'theme_mode';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  late SharedPreferences _prefs;

  @override
  ThemeMode build() {
    // We can't use async in build directly if we want a synchronous initial value.
    // However, we can handle the persistence initialization.
    _init();
    return ThemeMode.system;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      state = _themeModeFromString(savedTheme);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  ThemeMode _themeModeFromString(String themeString) {
    return ThemeMode.values.firstWhere(
      (e) => e.name == themeString,
      orElse: () => ThemeMode.system,
    );
  }
}
