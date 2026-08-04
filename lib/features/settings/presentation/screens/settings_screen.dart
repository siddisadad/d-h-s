import '/components/settings_group/settings_group_widget.dart';
import '/components/base_list_item.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/features/authentication/presentation/providers/auth_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/theme_provider.dart';
import 'package:deshmukh_steel_e_r_p/.artifacts/a552a74c-7194-45c7-885b-c3ead5813cab/scratch/seed_firebase.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final themeMode = ref.watch(themeNotifierProvider);

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'SETTINGS',
      );
    });

    return ListView(
      padding: EdgeInsets.all(tokens.space24),
      children: [
        SettingsGroupWidget(
          title: 'General',
          children: [
            BaseListItem(
              title: 'Theme Mode',
              subtitle: _getThemeModeLabel(themeMode),
              showDivider: true,
              trailing: PopupMenuButton<ThemeMode>(
                initialValue: themeMode,
                onSelected: (mode) {
                  ref.read(themeNotifierProvider.notifier).setThemeMode(mode);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Default'),
                  ),
                  const PopupMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  const PopupMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getThemeModeLabel(themeMode),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: context.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              leadingIcon: Icons.palette_rounded,
            ),
            BaseListItem(
              title: 'Language',
              showDivider: false,
              trailing: Text('English (US)', style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
              leadingIcon: Icons.language_rounded,
              onTap: () {},
            ),
          ],
        ),
        SettingsGroupWidget(
          title: 'Inventory & Logistics',
          children: [
            BaseListItem(
              title: 'Yards & Warehouses',
              subtitle: 'Manage physical stock locations',
              leadingIcon: Icons.warehouse_rounded,
              showDivider: true,
              onTap: () => context.push('/inventory/warehouses'),
            ),
            BaseListItem(
              title: 'Stock Transfer',
              subtitle: 'Move material between yards',
              leadingIcon: Icons.move_up_rounded,
              showDivider: false,
              onTap: () => context.push('/inventory/transfer'),
            ),
          ],
        ),
        SettingsGroupWidget(
          title: 'Account',
          children: [
            BaseListItem(
              title: 'Sign Out',
              showDivider: false,
              leadingIcon: Icons.logout_rounded,
              leadingIconColor: context.colorScheme.error,
              leadingBackgroundColor: context.colorScheme.error.withValues(alpha: 0.1),
              onTap: () => ref.read(authProvider.notifier).logout(),
            ),
          ],
        ),
        SettingsGroupWidget(
          title: 'Developer Tools',
          children: [
            BaseListItem(
              title: 'Seed Firebase Database',
              subtitle: 'Populate cloud DB with dummy data',
              leadingIcon: Icons.cloud_upload_rounded,
              showDivider: false,
              onTap: () async {
                 try {
                   await FirebaseSeeder.seed();
                   if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database Seeded Successfully')));
                 } catch (e) {
                   if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seeding Failed: $e'), backgroundColor: Colors.red));
                 }
              },
            ),
          ],
        ),
        SizedBox(height: tokens.space32),
        Center(
          child: Text(
            'v1.0.0 • Deshmukh Hardware & Steel',
            style: context.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
