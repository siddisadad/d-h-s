import '../../../../core/constants/app_strings.dart';
import '../../../../components/base_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/dashboard/presentation/providers/activity_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/sales/presentation/providers/sales_history_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/dashboard/domain/entities/activity.dart';
import 'package:deshmukh_steel_e_r_p/features/authentication/presentation/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/global_search_overlay.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_charts.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/stat_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/security/permissions.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/permission_wrapper.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsNotifierProvider);
    final activitiesAsync = ref.watch(activityStreamProvider);
    final salesAsync = ref.watch(salesHistoryProvider);
    final authUser = ref.watch(authProvider).value;
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: AppStrings.dashboardTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearch(context),
          ),
        ],
      );
    });

    return statsAsync.when(
      data: (stats) => RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardStatsNotifierProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickActions(context),
              const SizedBox(height: 32),
              _buildWelcomeHeader(context, authUser?.displayName ?? 'User'),
              const SizedBox(height: 24),
              _buildKpiGrid(context, stats),
              const SizedBox(height: 32),
              PermissionWrapper(
                requiredPermissions: const [AppPermission.viewAnalytics],
                child: salesAsync.when(
                  data: (sales) => _buildRevenueTrend(context, sales),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 32),
              activitiesAsync.when(
                data: (activities) => _buildRecentActivity(context, activities),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error loading activities: $e'),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.welcomeBack}, $name 👋',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.dashboardSubtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, dynamic stats) {
    final tokens = context.tokens;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 600 ? 2 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: tokens.space16,
          mainAxisSpacing: tokens.space16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            StatCard(
              label: AppStrings.todaySales,
              value: stats?.sales ?? '₹0',
              customIcon: const Icon(Icons.payments_rounded),
              color: context.colorScheme.primary,
              trend: stats?.salesTrend,
            ),
            StatCard(
              label: AppStrings.todayPurchase,
              value: stats?.purchases ?? '₹0',
              customIcon: const Icon(Icons.shopping_cart_rounded),
              color: context.colorScheme.secondary,
              trend: stats?.purchasesTrend,
            ),
            PermissionWrapper(
              requiredPermissions: const [AppPermission.viewFinance],
              child: StatCard(
                label: AppStrings.collections,
                value: stats?.collections ?? '₹0',
                customIcon: const Icon(Icons.account_balance_wallet_rounded),
                color: context.colorScheme.tertiary,
                trend: stats?.collectionsTrend,
              ),
            ),
            StatCard(
              label: AppStrings.lowStock,
              value: stats?.lowStock ?? '0 Items',
              customIcon: const Icon(Icons.inventory_2_rounded),
              color: context.colorScheme.error,
              isAlert: true,
            ),
          ],
        );
      }
    );
  }

  Widget _buildRevenueTrend(BuildContext context, List<dynamic> sales) {
    // Generate last 7 days revenue
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    
    final spots = List.generate(7, (i) {
      final day = last7Days[i];
      final daySales = sales.where((s) => 
        s.date.year == day.year && 
        s.date.month == day.month && 
        s.date.day == day.day
      ).fold(0.0, (sum, s) => sum + s.grandTotal);
      
      return FlSpot(i.toDouble(), daySales / 1000); // Scale to 'k' for better chart display
    });

    final xLabels = last7Days.map((d) => DateFormat('E').format(d).toUpperCase()).toList();

    return CustomCard(
      padding: EdgeInsets.all(context.tokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.revenueTrend,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Icon(Icons.trending_up_rounded, color: context.tokens.success),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: CustomLineChart(
              spots: spots,
              xLabels: xLabels,
              maxY: spots.fold(0.0, (max, spot) => spot.y > max ? spot.y : max) * 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.quickActions,
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            PermissionWrapper(
              requiredPermissions: const [AppPermission.createInvoice],
              child: Expanded(child: _buildActionItem(context, Icons.add_shopping_cart_rounded, AppStrings.newSale, context.colorScheme.primary, '/sales')),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildActionItem(context, Icons.inventory_2_outlined, 'Inventory', context.colorScheme.secondary, '/inventory')),
            const SizedBox(width: 16),
            Expanded(child: _buildActionItem(context, Icons.people_outline_rounded, AppStrings.customers, context.colorScheme.tertiary, '/customers')),
            const SizedBox(width: 16),
            PermissionWrapper(
              requiredPermissions: const [AppPermission.viewAnalytics],
              child: Expanded(child: _buildActionItem(context, Icons.assessment_outlined, AppStrings.reports, context.colorScheme.primaryContainer, '/analytics')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, List<Activity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recentActivity,
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(
              activities.length > 5 ? 5 : activities.length,
              (index) {
                final activity = activities[index];
                return BaseListItem(
                  title: activity.title,
                  subtitle: activity.subtitle,
                  leading: _buildActivityIcon(context, activity.type),
                  showDivider: index < (activities.length > 5 ? 4 : activities.length - 1),
                  trailing: Text(
                    timeago.format(activity.timestamp),
                    style: context.textTheme.labelSmall?.copyWith(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityIcon(BuildContext context, ActivityType type) {
    IconData icon;
    Color color;
    switch (type) {
      case ActivityType.sale:
        icon = Icons.shopping_cart_checkout_rounded;
        color = context.colorScheme.primary;
        break;
      case ActivityType.purchase:
        icon = Icons.shopping_bag_outlined;
        color = context.tokens.success;
        break;
      case ActivityType.stockAdjustment:
        icon = Icons.inventory_2_outlined;
        color = context.colorScheme.tertiary;
        break;
      case ActivityType.userLogin:
        icon = Icons.login_rounded;
        color = context.tokens.info;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color color, String path) {
    return CustomCard(
      onTap: () => context.go(path),
      padding: EdgeInsets.symmetric(vertical: context.tokens.space24),
      showShadow: false,
      color: context.colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GlobalSearchOverlay(),
    );
  }
}
