import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/side_nav_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/security/permissions.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/permission_wrapper.dart';
import 'package:deshmukh_steel_e_r_p/features/authentication/domain/entities/app_user.dart';
import 'package:deshmukh_steel_e_r_p/features/authentication/presentation/providers/auth_provider.dart';

class SideNavWidget extends ConsumerWidget {
  final bool isPermanent;
  const SideNavWidget({super.key, this.isPermanent = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final userAsync = ref.watch(authProvider);
    final isExpanded = ref.watch(sideNavNotifierProvider);

    final authUser = userAsync.value;
    final role = authUser?.role ?? 'Employee';

    bool hasP(AppPermission p) => RolePermissions.hasPermission(role, p);

    final content = Column(
      children: [
        _buildHeader(context, authUser, isExpanded),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: context.tokens.space16),
            children: [
              _buildSectionHeader(context, 'GENERAL', isExpanded),
              _buildNavItem(context, icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/dashboard', isExpanded: isExpanded),
              
              if (hasP(AppPermission.viewInventory) || hasP(AppPermission.viewSales) || hasP(AppPermission.viewPurchases))
                _buildSectionHeader(context, 'OPERATIONS', isExpanded),
              
              if (hasP(AppPermission.viewInventory))
                _buildModuleTile(
                  context, 
                  icon: Icons.inventory_2_rounded, 
                  label: 'Inventory', 
                  isExpanded: isExpanded,
                  rootPath: '/inventory',
                  children: [
                    _buildSubNavItem(context, label: 'Products & Stock', path: '/inventory'),
                  if (hasP(AppPermission.adjustStock)) ...[
                    _buildSubNavItem(context, label: 'Adjustments', path: '/inventory/adjustments'),
                    _buildSubNavItem(context, label: 'Stock Transfers', path: '/inventory/transfer'),
                  ],
                  _buildSubNavItem(context, label: 'Categories', path: '/inventory/categories'),
                ],
              ),
              
              if (hasP(AppPermission.viewSales))
                _buildModuleTile(
                  context, 
                  icon: Icons.receipt_long_rounded, 
                  label: 'Sales', 
                  isExpanded: isExpanded,
                  rootPath: '/sales',
                  children: [
                    _buildSubNavItem(context, label: 'Invoices', path: '/sales'),
                    _buildSubNavItem(context, label: 'Quotations', path: '/sales/quotes'),
                    _buildSubNavItem(context, label: 'Returns', path: '/sales/returns'),
                  ],
                ),
              
              if (hasP(AppPermission.viewPurchases))
                _buildNavItem(context, icon: Icons.shopping_cart_rounded, label: 'Purchases', path: '/purchases', isExpanded: isExpanded),
              
              if (hasP(AppPermission.viewContacts) || hasP(AppPermission.viewFinance))
                _buildSectionHeader(context, 'CRM & FINANCE', isExpanded),
              
              if (hasP(AppPermission.viewContacts)) ...[
                _buildNavItem(context, icon: Icons.groups_rounded, label: 'Customers', path: '/customers', isExpanded: isExpanded),
                _buildNavItem(context, icon: Icons.business_rounded, label: 'Suppliers', path: '/suppliers', isExpanded: isExpanded),
              ],
              
              if (hasP(AppPermission.viewFinance))
                _buildNavItem(context, icon: Icons.account_balance_wallet_rounded, label: 'Finance', path: '/finance', isExpanded: isExpanded),
              
              if (hasP(AppPermission.viewEmployees) || hasP(AppPermission.viewAnalytics))
                _buildSectionHeader(context, 'ADMIN', isExpanded),
              
              if (hasP(AppPermission.viewEmployees))
                _buildModuleTile(
                  context, 
                  icon: Icons.people_outline_rounded, 
                  label: 'Human Resources', 
                  isExpanded: isExpanded,
                  rootPath: '/employees',
                  children: [
                    _buildSubNavItem(context, label: 'Employees', path: '/employees'),
                    _buildSubNavItem(context, label: 'Attendance', path: '/employees/attendance'),
                    _buildSubNavItem(
                      context,
                      label: 'Payroll',
                      path: '/employees/payroll',
                      permissions: [AppPermission.viewSalaries],
                    ),
                  ],
                ),
              
              if (hasP(AppPermission.viewAnalytics))
                _buildNavItem(context, icon: Icons.assessment_rounded, label: 'Reports', path: '/analytics', isExpanded: isExpanded),
              
              _buildSectionHeader(context, 'SYSTEM', isExpanded),
              _buildNavItem(context, icon: Icons.settings_rounded, label: 'Settings', path: '/settings', isExpanded: isExpanded),
            ],
          ),
        ),
        _buildLogoutButton(context, ref, isExpanded),
      ],
    );

    if (isPermanent) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isExpanded ? 280 : 80,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(right: BorderSide(color: theme.dividerColor, width: 0.5)),
        ),
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: content,
        ),
      );
    }

    return Drawer(
      backgroundColor: colorScheme.surface,
      width: 280,
      child: content,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isExpanded) {
    if (!isExpanded) return const Divider(height: 32, indent: 20, endIndent: 20);

    return Padding(
      padding: EdgeInsets.fromLTRB(context.tokens.space24, 24, context.tokens.space24, 8),
      child: Text(
        title,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.onSurfaceVariantColor,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppUser? user, bool isExpanded) {
    final tokens = context.tokens;
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      height: 180,
      padding: EdgeInsets.all(tokens.space24),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1581094794329-c8112a89af12?q=80&w=2070&auto=format&fit=crop'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(colorScheme.primary.withValues(alpha: 0.8), BlendMode.multiply),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: isExpanded ? 32 : 16,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white, size: isExpanded ? 32 : 16),
          ),
          if (isExpanded) ...[
            SizedBox(height: tokens.space16),
            Text(
              user?.displayName ?? 'Admin User',
              style: context.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              user?.email ?? 'admin@dhserp.com',
              style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {
    required IconData icon, 
    required String label, 
    required String path, 
    required bool isExpanded,
    List<AppPermission> permissions = const [],
  }) {
    final location = GoRouterState.of(context).uri.path;
    final isSelected = location == path;
    final colorScheme = context.colorScheme;
    final tokens = context.tokens;

    final navItem = isExpanded ? ListTile(
      leading: Icon(icon, color: isSelected ? colorScheme.primary : context.onSurfaceVariantColor),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : context.onSurfaceColor,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: () {
        if (!isPermanent) Navigator.pop(context);
        context.go(path);
      },
      selected: isSelected,
      selectedTileColor: colorScheme.primary.withValues(alpha: 0.05),
      contentPadding: EdgeInsets.symmetric(horizontal: tokens.space24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radiusMd)),
    ) : Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Tooltip(
            message: label,
            child: InkWell(
              onTap: () => context.go(path),
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                ),
                child: Icon(icon, color: isSelected ? colorScheme.primary : context.onSurfaceVariantColor),
              ),
            ),
          ),
        ),
      );

    if (permissions.isEmpty) return navItem;

    return PermissionWrapper(
      requiredPermissions: permissions,
      child: navItem,
    );
  }

  Widget _buildModuleTile(BuildContext context, {
    required IconData icon,
    required String label,
    required bool isExpanded,
    required List<Widget> children,
    required String rootPath,
    List<AppPermission> permissions = const [],
  }) {
    final location = GoRouterState.of(context).uri.path;
    final isAnyChildActive = location.startsWith(rootPath);

    if (!isExpanded) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Tooltip(
            message: label,
            child: Icon(
              icon, 
              color: isAnyChildActive ? context.colorScheme.primary : context.tokens.textSecondary,
            ),
          ),
        ),
      );
    }

    final moduleTile = ExpansionTile(
      leading: Icon(
        icon, 
        color: isAnyChildActive ? context.colorScheme.primary : context.onSurfaceVariantColor,
      ),
      title: Text(
        label, 
        style: TextStyle(
          fontWeight: isAnyChildActive ? FontWeight.w700 : FontWeight.w600, 
          fontSize: 14,
          color: isAnyChildActive ? context.colorScheme.primary : context.onSurfaceColor,
        ),
      ),
      initiallyExpanded: isAnyChildActive,
      children: children,
    );

    if (permissions.isEmpty) return moduleTile;

    return PermissionWrapper(
      requiredPermissions: permissions,
      child: moduleTile,
    );
  }

  Widget _buildSubNavItem(BuildContext context, {
    required String label,
    required String path,
    List<AppPermission> permissions = const [],
  }) {
    final location = GoRouterState.of(context).uri.path;
    final isSelected = location == path;
    final colorScheme = context.colorScheme;

    final subNavItem = ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : context.onSurfaceVariantColor,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      contentPadding: const EdgeInsets.only(left: 64, right: 24),
      dense: true,
      onTap: () {
        if (!isPermanent) Navigator.pop(context);
        context.go(path);
      },
    );

    if (permissions.isEmpty) return subNavItem;

    return PermissionWrapper(
      requiredPermissions: permissions,
      child: subNavItem,
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, bool isExpanded) {
    final tokens = context.tokens;
    
    if (!isExpanded) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space24),
        child: IconButton(
          icon: Icon(Icons.logout_rounded, color: context.colorScheme.error),
          onPressed: () => ref.read(authProvider.notifier).logout(),
          tooltip: 'Logout',
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(tokens.space24),
      child: InkWell(
        onTap: () => ref.read(authProvider.notifier).logout(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: context.colorScheme.error),
              const SizedBox(width: 16),
              Text(
                'Logout Session',
                style: TextStyle(color: context.colorScheme.error, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
