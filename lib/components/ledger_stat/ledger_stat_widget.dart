import '../../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LedgerStatWidget extends StatelessWidget {
  const LedgerStatWidget({
    super.key,
    this.label = 'Outstanding',
    this.tone = const Color(0x00000000),
    this.value = '₹45,820',
  });

  final String label;
  final Color tone;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: context.colorScheme.outline,
          width: 1.0,
        ),
        boxShadow: [tokens.shadowSm],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall!.copyWith(
                color: context.textTheme.bodySmall!.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: tone != const Color(0x00000000) ? tone : context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
