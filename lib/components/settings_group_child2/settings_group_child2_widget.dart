import '/components/settings_item/settings_item_widget.dart';
import '../../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingsGroupChild2Widget extends StatelessWidget {
  const SettingsGroupChild2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsItemWidget(
          hasSubtitle: true,
          icon: Icon(
            Icons.cloud_upload_rounded,
            color: context.colorScheme.primary,
            size: 22.0,
          ),
          label: 'Database Backup',
          subtitle: 'Last backup: Today, 02:30 AM',
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
            Icons.sync_rounded,
            color: context.colorScheme.primary,
            size: 22.0,
          ),
          label: 'Auto-Sync Settings',
          subtitle: 'Cloud synchronization frequency',
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
            Icons.security_rounded,
            color: context.colorScheme.primary,
            size: 22.0,
          ),
          label: 'User Permissions',
          subtitle: 'Manage roles and access control',
        ),
      ],
    );
  }
}
