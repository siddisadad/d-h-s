import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTabWidget extends StatelessWidget {
  const AuthTabWidget({
    super.key,
    this.active = 'true',
    this.label = 'Mobile Login',
  });

  final String active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Text(
            label,
            style: context.textTheme.bodyMedium!.override(
              font: GoogleFonts.inter(
                fontWeight: context.textTheme.bodyMedium!.fontWeight,
                fontStyle: context.textTheme.bodyMedium!.fontStyle,
              ),
              color: valueOrDefault<Color>(
                active == 'false'
                    ? context.textTheme.bodySmall!.color
                    : context.colorScheme.primary,
                context.colorScheme.primary,
              ),
              letterSpacing: 0.0,
              fontWeight: context.textTheme.bodyMedium!.fontWeight,
              fontStyle: context.textTheme.bodyMedium!.fontStyle,
              lineHeight: 1.43,
            ),
          ),
        ),
      ),
    );
  }
}
