import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';

class PermissionWrapper extends ConsumerWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const PermissionWrapper({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return authState.maybeWhen(
      data: (user) {
        if (user != null && allowedRoles.contains(user.role)) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
      orElse: () => fallback ?? const SizedBox.shrink(),
    );
  }
}
