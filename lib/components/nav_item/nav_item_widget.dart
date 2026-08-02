import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavItemWidget extends StatelessWidget {
  const NavItemWidget({
    super.key,
    this.label = 'Home',
    this.icon,
    this.target = 'MainDashboard',
    this.selected = true,
  });

  final String label;
  final Widget? icon;
  final String target;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) icon!,
          Text(
            label,
            style: context.textTheme.bodyMedium!.override(
              font: GoogleFonts.inter(
                fontWeight: context.textTheme.bodyMedium!.fontWeight,
                fontStyle: context.textTheme.bodyMedium!.fontStyle,
              ),
              color: selected
                  ? context.colorScheme.primary
                  : context.textTheme.bodySmall!.color,
              letterSpacing: 0.0,
              fontWeight: context.textTheme.bodyMedium!.fontWeight,
              fontStyle: context.textTheme.bodyMedium!.fontStyle,
              lineHeight: 1.43,
            ),
          ),
        ].divide(const SizedBox(height: 2.0)),
      ),
    );
  }
}
