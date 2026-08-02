import '/components/settings_item/settings_item_widget.dart';
import '/components/switch_component/switch_component_widget.dart';
import '../../core/design_system/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsGroupChild3Widget extends StatelessWidget {
  const SettingsGroupChild3Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
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
                    child: Icon(
                      Icons.dark_mode_rounded,
                      color: context.colorScheme.onPrimary,
                      size: 22.0,
                    ),
                  ),
                  Text(
                    'Dark Mode',
                    style: context.textTheme.bodyMedium!.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontStyle: context.textTheme.bodyMedium!.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: context.textTheme.bodyMedium!.fontStyle,
                      lineHeight: 1.43,
                    ),
                  ),
                ].divide(SizedBox(width: context.tokens.space16)),
              ),
              const SwitchComponentWidget(
                label: '',
                labelPresent: false,
                variant: 'Android',
                active: false,
              ),
            ],
          ),
        ),
        Divider(
          height: 16.0,
          thickness: 1.0,
          indent: 56.0,
          endIndent: 0.0,
          color: context.colorScheme.outline,
        ),
        SettingsItemWidget(
          hasSubtitle: true,
          icon: Icon(
            Icons.language_rounded,
            color: context.colorScheme.primary,
            size: 22.0,
          ),
          label: 'Language',
          subtitle: 'English (India)',
        ),
      ],
    );
  }
}
