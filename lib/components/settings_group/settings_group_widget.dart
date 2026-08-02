import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsGroupWidget extends StatelessWidget {
  const SettingsGroupWidget({
    super.key,
    this.title = 'GENERAL PROFILE',
    this.child,
  });

  final String title;
  final Widget Function()? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
            child: Text(
              title,
              style: context.textTheme.titleSmall!.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontStyle: context.textTheme.titleSmall!.fontStyle,
                ),
                color: context.colorScheme.primary,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                fontStyle: context.textTheme.titleSmall!.fontStyle,
                lineHeight: 1.43,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.0),
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: context.colorScheme.outline,
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (child != null) child!() else const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ].divide(SizedBox(height: context.tokens.space8)),
      ),
    );
  }
}
