import '/components/settings_group/settings_group_widget.dart';
import '/components/base_list_item.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/features/authentication/presentation/providers/auth_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/theme_provider.dart';
import '../providers/settings_provider.dart';

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
              trailing: ref.watch(settingsNotifierProvider).when(
                data: (s) => _buildLanguageDropdown(context, ref, s.language),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              leadingIcon: Icons.language_rounded,
            ),
          ],
        ),
        SettingsGroupWidget(
          title: 'Regional',
          children: [
            BaseListItem(
              title: 'Default Currency',
              subtitle: 'Local display currency',
              leadingIcon: Icons.payments_rounded,
              showDivider: false,
              trailing: ref.watch(settingsNotifierProvider).when(
                data: (s) => _buildCurrencyDropdown(context, ref, s.currency),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
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
          title: 'System Information',
          children: [
            BaseListItem(
              title: 'Application Version',
              trailing: Text('1.0.0+1', style: context.textTheme.labelMedium),
              leadingIcon: Icons.info_outline_rounded,
              showDivider: true,
            ),
            BaseListItem(
              title: 'Database Schema',
              trailing: Text('v8 (Optimized)', style: context.textTheme.labelMedium),
              leadingIcon: Icons.storage_rounded,
              showDivider: true,
            ),
            BaseListItem(
              title: 'Sync Status',
              trailing: Icon(Icons.check_circle_rounded, color: context.tokens.success, size: 20),
              leadingIcon: Icons.cloud_done_rounded,
              showDivider: false,
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

  Widget _buildLanguageDropdown(BuildContext context, WidgetRef ref, String current) {
    return PopupMenuButton<String>(
      initialValue: current,
      onSelected: (val) => ref.read(settingsNotifierProvider.notifier).setLanguage(val),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'en', child: Text('English')),
        const PopupMenuItem(value: 'hi', child: Text('Hindi')),
        const PopupMenuItem(value: 'mr', child: Text('Marathi')),
      ],
      child: _dropdownTrigger(context, current == 'en' ? 'English' : (current == 'hi' ? 'Hindi' : 'Marathi')),
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context, WidgetRef ref, String current) {
    return PopupMenuButton<String>(
      initialValue: current,
      onSelected: (val) => ref.read(settingsNotifierProvider.notifier).setCurrency(val),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'INR', child: Text('Indian Rupee (₹)')),
        const PopupMenuItem(value: 'USD', child: Text('US Dollar (\$)')),
      ],
      child: _dropdownTrigger(context, current),
    );
  }

  Widget _dropdownTrigger(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
