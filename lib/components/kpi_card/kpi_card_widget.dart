import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class KpiCardWidget extends StatelessWidget {
  final Widget? icon;
  final String label;
  final Color tone;
  final String trend;
  final String value;
  final bool isAlert;

  const KpiCardWidget({
    super.key,
    this.icon,
    this.label = 'Sales',
    this.tone = AppColors.primary,
    this.trend = '+12%',
    this.value = '₹1,45,200',
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [tokens.shadowSm],
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                  child: icon ?? Icon(Icons.show_chart_rounded, color: tone, size: 20),
                ),
                if (trend.isNotEmpty && !isAlert)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(tokens.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up_rounded, color: theme.colorScheme.primary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          trend,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2),
              ],
            ),
            const Spacer(),
            Text(
              label.toUpperCase(),
              maxLines: 1,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: isAlert ? theme.colorScheme.error : theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
