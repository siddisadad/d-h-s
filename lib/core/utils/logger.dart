import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class Log {
  static void d(String message, {String? name}) {
    _log(LogLevel.debug, message, name: name);
  }

  static void i(String message, {String? name}) {
    _log(LogLevel.info, message, name: name);
  }

  static void w(String message, {String? name}) {
    _log(LogLevel.warning, message, name: name);
  }

  static void e(String message, {dynamic error, StackTrace? stackTrace, String? name}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace, name: name);
  }

  static void _log(LogLevel level, String message, {dynamic error, StackTrace? stackTrace, String? name}) {
    if (!kDebugMode && level == LogLevel.debug) return;

    final String label = level.name.toUpperCase();
    final String time = DateTime.now().toIso8601String().split('T').last.substring(0, 8);
    
    dev.log(
      message,
      time: DateTime.now(),
      level: _levelToValue(level),
      name: name ?? 'APP',
      error: error,
      stackTrace: stackTrace,
    );

    debugPrint('[$time] [$label] ${name != null ? "[$name] " : ""}$message');
    if (error != null) debugPrint('   ↳ Error: $error');
  }

  static int _levelToValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return 500;
      case LogLevel.info: return 800;
      case LogLevel.warning: return 900;
      case LogLevel.error: return 1000;
    }
  }

  static void init({Function(Object, StackTrace)? onGlobalError}) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      Log.e('Flutter Error', error: details.exception, stackTrace: details.stack, name: 'FLUTTER');
      onGlobalError?.call(details.exception, details.stack ?? StackTrace.empty);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      Log.e('Uncaught Platform Error', error: error, stackTrace: stack, name: 'PLATFORM');
      onGlobalError?.call(error, stack);
      return true;
    };
  }
}
