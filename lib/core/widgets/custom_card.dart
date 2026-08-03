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
    
    return Container(
      decoration: BoxDecoration(
        color: color ?? context.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? tokens.radiusLg),
        border: Border.all(color: context.colorScheme.outline.withValues(alpha: 0.5), width: 1),
        boxShadow: showShadow ? [tokens.shadowSm] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? tokens.radiusLg),
          child: Padding(
            padding: padding ?? EdgeInsets.all(tokens.space16),
            child: child,
          ),
        ),
      ),
    );
  }
}
