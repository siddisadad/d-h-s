import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/theme/app_theme.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';

class SideNavWidget extends ConsumerWidget {
  final bool isPermanent;
  const SideNavWidget({super.key, this.isPermanent = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final user = ref.watch(authProvider);

    final content = Column(
      children: [
        _buildHeader(context, user),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildNavItem(context, icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/dashboard'),
              _buildNavItem(context, icon: Icons.inventory_2_rounded, label: 'Inventory', path: '/inventory'),
              _buildNavItem(context, icon: Icons.receipt_long_rounded, label: 'Sales Invoices', path: '/sales'),
              _buildNavItem(context, icon: Icons.shopping_cart_rounded, label: 'Purchases', path: '/purchases'),
              _buildNavItem(context, icon: Icons.groups_rounded, label: 'Customer Ledger', path: '/customers'),
              _buildNavItem(context, icon: Icons.local_shipping_rounded, label: 'Supplier Directory', path: '/suppliers'),
              _buildNavItem(context, icon: Icons.people_outline_rounded, label: 'Employees', path: '/employees'),
              _buildNavItem(context, icon: Icons.assessment_rounded, label: 'Reports & Analytics', path: '/analytics'),
              const Divider(),
              _buildNavItem(context, icon: Icons.settings_rounded, label: 'Settings', path: '/settings'),
            ],
          ),
        ),
        _buildLogoutButton(context, ref),
      ],
    );

    if (isPermanent) {
      return Container(
        width: 280,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(right: BorderSide(color: theme.dividerColor, width: 0.5)),
        ),
        child: content,
      );
    }

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: content,
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    final tokens = context.tokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(tokens.space24, 64, tokens.space24, tokens.space24),
      color: context.colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 32),
          ),
          SizedBox(height: tokens.space16),
          Text(
            user?.displayName ?? 'Admin User',
            style: context.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'admin@dhserp.com',
            style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required String path}) {
    final location = GoRouterState.of(context).uri.path;
    final isSelected = location == path;
    final colorScheme = context.colorScheme;

    return ListTile(
      leading: Icon(icon, color: isSelected ? colorScheme.primary : AppColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: () {
        if (!isPermanent) Navigator.pop(context);
        context.go(path);
      },
      selected: isSelected,
      selectedTileColor: colorScheme.primary.withValues(alpha: 0.05),
      contentPadding: EdgeInsets.symmetric(horizontal: context.tokens.space24),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(context.tokens.space24),
      child: InkWell(
        onTap: () => ref.read(authProvider.notifier).logout(),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error),
            SizedBox(width: 16),
            Text('Logout Session', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
