import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../providers/startup_provider.dart';

part 'router_notifier.g.dart';

@riverpod
class RouterNotifier extends _$RouterNotifier implements Listenable {
  VoidCallback? _listener;

  @override
  void build() {
    // Listen to changes in Auth and Startup states
    // When they change, we notify GoRouter via the listener
    ref.listen(authProvider, (_, __) {
      debugPrint('🔔 [RouterNotifier] Auth state changed -> Notifying GoRouter');
      _listener?.call();
    });

    ref.listen(startupProvider, (_, __) {
      debugPrint('🔔 [RouterNotifier] Startup state changed -> Notifying GoRouter');
      _listener?.call();
    });
  }

  @override
  void addListener(VoidCallback listener) {
    _listener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    _listener = null;
  }
}
