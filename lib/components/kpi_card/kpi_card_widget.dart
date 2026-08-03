import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class KpiCardWidget extends StatelessWidget {
  final Widget? icon;
  final String label;
  final Color? tone;
  final String trend;
  final String value;
  final bool isAlert;

  const KpiCardWidget({
    super.key,
    required this.label,
    this.icon,
    this.trend = '+12%',
    this.value = '₹1,45,200',
    this.isAlert = false,
    this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tokens = context.tokens;
    final activeTone = tone ?? theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: [tokens.shadowXs],
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: activeTone.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: icon ?? Icon(Icons.show_chart_rounded, color: activeTone, size: 22),
                ),
                if (trend.isNotEmpty && !isAlert)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          trend,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.w800,
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
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isAlert ? theme.colorScheme.error : theme.colorScheme.onSurface,
                letterSpacing: -1.0,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
