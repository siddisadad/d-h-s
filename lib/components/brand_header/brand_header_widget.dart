import '../../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BrandHeaderWidget extends StatelessWidget {
  const BrandHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: BorderRadius.circular(28.0),
            boxShadow: [tokens.shadowMd],
          ),
          alignment: const AlignmentDirectional(0.0, 0.0),
          child: Icon(
            Icons.domain_rounded,
            color: context.colorScheme.onPrimary,
            size: 52.0,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DESHMUKH STEEL',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w900,
                color: context.colorScheme.primary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ENTERPRISE RESOURCE PLANNING',
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textTheme.bodySmall!.color,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
