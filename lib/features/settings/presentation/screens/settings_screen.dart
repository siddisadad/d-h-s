import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.space24),
        children: [
          _buildSectionHeader(context, 'General'),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (val) {},
                  activeThumbColor: AppColors.primary,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Language'),
                  trailing: const Text('English (US)', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space32),
          _buildSectionHeader(context, 'Account'),
          CustomCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () => ref.read(authProvider.notifier).logout(),
            ),
          ),
          SizedBox(height: tokens.space32),
          Center(
            child: Text(
              'v1.0.0 • Deshmukh Hardware & Steel',
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
      ),
    );
  }
}
