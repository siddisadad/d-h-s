import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Widget? customIcon;
  final Color? color;
  final String? trend;
  final bool isAlert;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.customIcon,
    this.color,
    this.trend,
    this.isAlert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primaryColor = isAlert ? context.colorScheme.error : (color ?? context.colorScheme.primary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: Container(
        padding: EdgeInsets.all(tokens.space16),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(
            color: context.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.0,
          ),
          boxShadow: [tokens.shadowXs],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (customIcon != null || icon != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: customIcon ?? Icon(icon, color: primaryColor, size: 20),
                  ),
                if (trend != null && !isAlert)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(tokens.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_upward_rounded, color: context.colorScheme.primary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          trend!,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              label.toUpperCase(),
              maxLines: 1,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                letterSpacing: 1.2,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isAlert ? context.colorScheme.error : context.colorScheme.onSurface,
                letterSpacing: -0.5,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
