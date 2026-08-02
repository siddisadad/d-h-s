import '/components/settings_item/settings_item_widget.dart';
import '../../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingsGroupChild4Widget extends StatelessWidget {
  const SettingsGroupChild4Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsItemWidget(
          hasSubtitle: false,
          icon: Icon(
            Icons.help_outline_rounded,
            color: context.colorScheme.primary,
            size: 22.0,
          ),
          label: 'Help & Support',
          subtitle: 'Name, Address, Contact info',
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
            Icons.info_outline_rounded,
            color: context.colorScheme.primary,
            size: 22.0,
          ),
          label: 'About Software',
          subtitle: 'Version 2.4.1-stable',
        ),
      ],
    );
  }
}
