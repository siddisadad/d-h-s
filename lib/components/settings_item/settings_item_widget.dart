import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsItemWidget extends StatelessWidget {
  const SettingsItemWidget({
    super.key,
    this.hasSubtitle = true,
    this.icon,
    this.label = 'Business Details',
    this.subtitle = 'Name, Address, Contact info',
  });

  final bool hasSubtitle;
  final Widget? icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        shape: BoxShape.rectangle,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
                shape: BoxShape.rectangle,
              ),
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: icon,
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.bodyMedium!.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontStyle: context.textTheme.bodyMedium!.fontStyle,
                      ),
                      color: context.colorScheme.onSurface,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: context.textTheme.bodyMedium!.fontStyle,
                      lineHeight: 1.43,
                    ),
                  ),
                  if (hasSubtitle)
                    Text(
                      subtitle,
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
                ].divide(SizedBox(height: context.tokens.space4)),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colorScheme.outline,
              size: 20.0,
            ),
          ].divide(SizedBox(width: context.tokens.space16)),
        ),
      ),
    );
  }
}
