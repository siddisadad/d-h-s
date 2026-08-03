import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportCategoryCardWidget extends StatelessWidget {
  const ReportCategoryCardWidget({
    super.key,
    this.bgLight,
    this.color,
    this.icon,
    this.subtitle = 'GSTR-1, GSTR-3B, and Tax Summary',
    this.title = 'GST Reports',
  });

  final Color? bgLight;
  final Color? color;
  final Widget? icon;
  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    final activeBgLight = bgLight ?? context.colorScheme.surface;

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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: activeBgLight,
                borderRadius: BorderRadius.circular(12.0),
                shape: BoxShape.rectangle,
              ),
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: icon,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium!.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontStyle: context.textTheme.titleMedium!.fontStyle,
                    ),
                    color: context.colorScheme.onSurface,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: context.textTheme.titleMedium!.fontStyle,
                    lineHeight: 1.5,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  style: context.textTheme.bodySmall!.override(
                    font: GoogleFonts.inter(
                      fontWeight: context.textTheme.bodySmall!.fontWeight,
                      fontStyle: context.textTheme.bodySmall!.fontStyle,
                    ),
                    color: context.textTheme.bodySmall!.color,
                    letterSpacing: 0.0,
                    fontWeight: context.textTheme.bodySmall!.fontWeight,
                    fontStyle: context.textTheme.bodySmall!.fontStyle,
                    lineHeight: 1.33,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ].divide(SizedBox(height: context.tokens.space4)),
            ),
          ].divide(SizedBox(height: context.tokens.space16)),
        ),
      ),
    );
  }
}
