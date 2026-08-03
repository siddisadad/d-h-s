import '../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? trend;
  final bool isAlert;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.trend,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primaryColor = isAlert ? context.colorScheme.error : (color ?? context.colorScheme.primary);

    return Container(
      padding: EdgeInsets.all(tokens.space16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: context.colorScheme.outline.withValues(alpha: 0.5)),
        boxShadow: [tokens.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: primaryColor),
                SizedBox(width: tokens.space8),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trend != null)
                Text(
                  trend!,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          SizedBox(height: tokens.space8),
          Text(
            value,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: primaryColor,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
