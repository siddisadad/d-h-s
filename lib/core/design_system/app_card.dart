import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tokens = context.tokens;

    return Container(
      padding: padding ?? EdgeInsets.all(tokens.spaceMd),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? tokens.radiusLg),
        border: border ?? Border.all(color: theme.dividerColor, width: 1),
        boxShadow: [tokens.shadowSm],
      ),
      child: child,
    );
  }
}
