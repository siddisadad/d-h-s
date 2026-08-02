import 'package:flutter/material.dart';
import '../design_system/theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;
  final bool showShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? context.colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          border: Border.all(color: context.theme.dividerColor, width: 1),
          boxShadow: showShadow ? [tokens.shadowSm] : null,
        ),
        child: child,
      ),
    );
  }
}
