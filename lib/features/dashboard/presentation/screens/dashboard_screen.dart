import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/dashboard_provider.dart';
import '../providers/activity_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/dashboard/domain/entities/activity.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/global_search_overlay.dart';
import '../../../../core/widgets/custom_charts.dart';
import '../../../../components/kpi_card/kpi_card_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsNotifierProvider);
    final activitiesAsync = ref.watch(activityNotifierProvider);
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DHS ERP DASHBOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearch(context),
          ),
          SizedBox(width: tokens.space8),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: tokens.space16),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(dashboardStatsNotifierProvider.notifier).refresh();
            ref.invalidate(activityNotifierProvider);
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(context),
                SizedBox(height: tokens.space24),
                _buildKpiGrid(context, stats),
                SizedBox(height: tokens.space32),
                _buildRevenueTrend(context),
                SizedBox(height: tokens.space32),
                _buildQuickActions(context),
                SizedBox(height: tokens.space32),
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
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, Admin',
          style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          'Here is what\'s happening with Deshmukh Hardware today.',
          style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
            KpiCardWidget(
              label: 'Today\'s Sales',
              value: stats?.sales ?? '₹0',
              icon: const Icon(Icons.payments_rounded),
              tone: AppColors.primary,
              trend: '+12%',
            ),
            KpiCardWidget(
              label: 'Today\'s Purchase',
              value: stats?.purchases ?? '₹0',
              icon: const Icon(Icons.shopping_cart_rounded),
              tone: AppColors.success,
              trend: '+5%',
            ),
            KpiCardWidget(
              label: 'Collections',
              value: stats?.collections ?? '₹0',
              icon: const Icon(Icons.account_balance_wallet_rounded),
              tone: AppColors.accent,
              trend: '+8%',
            ),
            KpiCardWidget(
              label: 'Low Stock',
              value: stats?.lowStock ?? '0 Items',
              icon: const Icon(Icons.inventory_2_rounded),
              tone: AppColors.error,
              isAlert: true,
            ),
          ],
        );
      }
    );
  }

  Widget _buildRevenueTrend(BuildContext context) {
    final tokens = context.tokens;
    return CustomCard(
      padding: EdgeInsets.all(tokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REVENUE TREND',
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
            ],
          ),
          SizedBox(height: tokens.space24),
          SizedBox(
            height: 200,
            child: CustomLineChart(
              spots: const [
                FlSpot(0, 45),
                FlSpot(1, 52),
                FlSpot(2, 48),
                FlSpot(3, 70),
                FlSpot(4, 61),
                FlSpot(5, 85),
                FlSpot(6, 92),
              ],
              xLabels: const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
              maxY: 100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: tokens.space16),
        Row(
          children: [
            Expanded(child: _buildActionItem(context, Icons.add_shopping_cart_rounded, 'New Sale', AppColors.primary, '/sales')),
            SizedBox(width: tokens.space16),
            Expanded(child: _buildActionItem(context, Icons.inventory_2_outlined, 'Inventory', AppColors.info, '/inventory')),
            SizedBox(width: tokens.space16),
            Expanded(child: _buildActionItem(context, Icons.people_outline_rounded, 'Customers', AppColors.accent, '/customers')),
            SizedBox(width: tokens.space16),
            Expanded(child: _buildActionItem(context, Icons.assessment_outlined, 'Reports', AppColors.secondary, '/analytics')),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, List<Activity> activities) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT ACTIVITY',
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: tokens.space16),
        CustomCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: context.theme.dividerColor),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: _buildActivityIcon(context, activity.type),
                title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(activity.subtitle, style: context.textTheme.bodySmall),
                trailing: Text(
                  timeago.format(activity.timestamp),
                  style: context.textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
              );
            },
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
        color = AppColors.primary;
        break;
      case ActivityType.purchase:
        icon = Icons.shopping_bag_outlined;
        color = AppColors.success;
        break;
      case ActivityType.stockAdjustment:
        icon = Icons.inventory_2_outlined;
        color = AppColors.accent;
        break;
      case ActivityType.userLogin:
        icon = Icons.login_rounded;
        color = AppColors.info;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color color, String path) {
    final tokens = context.tokens;
    return CustomCard(
      onTap: () => context.go(path),
      padding: EdgeInsets.symmetric(vertical: tokens.space20),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: tokens.space8),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
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
