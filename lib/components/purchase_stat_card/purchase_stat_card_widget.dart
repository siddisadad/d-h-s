import '../../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PurchaseStatCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const PurchaseStatCardWidget({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primaryColor = color ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.all(tokens.space16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.dividerColor),
        boxShadow: [tokens.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: primaryColor),
                SizedBox(width: tokens.space8),
              ],
              Text(
                label.toUpperCase(),
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
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
