import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SummaryStatWidget extends StatelessWidget {
  const SummaryStatWidget({
    super.key,
    this.color = const Color(0x00000000),
    this.label = 'Total Income',
    this.value = '₹ 4.2L',
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: context.colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall!.override(
                font: GoogleFonts.inter(
                  fontWeight: context.textTheme.labelSmall!.fontWeight,
                  fontStyle: context.textTheme.labelSmall!.fontStyle,
                ),
                color: context.textTheme.bodySmall!.color,
                letterSpacing: 0.0,
                fontWeight: context.textTheme.labelSmall!.fontWeight,
                fontStyle: context.textTheme.labelSmall!.fontStyle,
                lineHeight: 1.45,
              ),
            ),
            Text(
              value,
              style: context.textTheme.titleMedium!.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontStyle: context.textTheme.titleMedium!.fontStyle,
                ),
                color: color == const Color(0x00000000)
                    ? AppColors.success
                    : color,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                fontStyle: context.textTheme.titleMedium!.fontStyle,
                lineHeight: 1.5,
              ),
            ),
          ].divide(SizedBox(height: context.tokens.space4)),
        ),
      ),
    );
  }
}
