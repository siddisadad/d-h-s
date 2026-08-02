import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepIndicatorWidget extends StatelessWidget {
  const StepIndicatorWidget({
    super.key,
    this.label = 'Customer',
    this.number = '1',
    this.active = true,
  });

  final String label;
  final String number;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: active
                ? context.colorScheme.primary
                : context.colorScheme.surface,
            borderRadius: BorderRadius.circular(9999.0),
            shape: BoxShape.rectangle,
            border: Border.all(
              color: active
                  ? context.colorScheme.primary
                  : context.colorScheme.outline,
              width: 1.0,
            ),
          ),
          alignment: const AlignmentDirectional(0.0, 0.0),
          child: Text(
            number,
            style: context.textTheme.labelSmall!.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontStyle: context.textTheme.labelSmall!.fontStyle,
              ),
              color: active
                  ? context.colorScheme.onPrimary
                  : context.textTheme.bodySmall!.color,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
              fontStyle: context.textTheme.labelSmall!.fontStyle,
              lineHeight: 1.45,
            ),
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall!.override(
            font: GoogleFonts.inter(
              fontWeight: context.textTheme.labelSmall!.fontWeight,
              fontStyle: context.textTheme.labelSmall!.fontStyle,
            ),
            color: active
                ? context.colorScheme.onSurface
                : context.textTheme.bodySmall!.color,
            letterSpacing: 0.0,
            fontWeight: context.textTheme.labelSmall!.fontWeight,
            fontStyle: context.textTheme.labelSmall!.fontStyle,
            lineHeight: 1.45,
          ),
        ),
      ].divide(SizedBox(width: context.tokens.space8)),
    );
  }
}
