import 'package:deshmukh_steel_e_r_p/components/base_list_item.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_text_field.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/features/purchases/presentation/providers/purchase_provider.dart';
import 'package:deshmukh_steel_e_r_p/components/stat_card.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_charts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:deshmukh_steel_e_r_p/features/purchases/presentation/screens/purchase_entry_screen.dart';
import 'package:deshmukh_steel_e_r_p/features/purchases/domain/entities/purchase_order.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:flutter/material.dart';
import 'package:deshmukh_steel_e_r_p/features/purchases/presentation/providers/purchase_stats_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/purchases/presentation/providers/purchase_history_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/purchases/presentation/screens/procurement_planner_screen.dart';


class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchaseNotifierProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'PURCHASE MANAGEMENT',
        actions: [
          IconButton(
            tooltip: 'Smart Procurement Planner',
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProcurementPlannerScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CustomButton(
            text: 'New Purchase',
            variant: CustomButtonVariant.primary,
            icon: Icons.add_rounded,
            onPressed: () => context.push('/purchases/new'),
          ),
        ],
      );
    });

    return purchasesAsync.when(
      data: (purchases) => RefreshIndicator(
        onRefresh: () => ref.read(purchaseNotifierProvider.notifier).refresh(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndFilters(context),
              const SizedBox(height: 24),
              _buildStats(context, ref),
              const SizedBox(height: 32),
              _buildPurchaseVolumeChart(context, ref),
              const SizedBox(height: 32),
              _buildRecentEntries(context, purchases),
            ],
          ).animate().fadeIn(duration: 500.ms),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: CustomTextField(
            label: 'Search Purchases',
            hint: 'Search by Supplier or SKU...',
            prefixIcon: Icons.search_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          margin: const EdgeInsets.only(top: 28),
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: IconButton(
            icon: Icon(Icons.tune_rounded, color: context.primaryColor),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(purchaseStatsProvider);

    return statsAsync.when(
      data: (stats) => Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Pending Orders',
              value: '${stats.pendingOrders}',
              icon: Icons.pending_actions_rounded,
              color: context.primaryColor,
            ),
          ),
          SizedBox(width: context.tokens.space16),
          Expanded(
            child: StatCard(
              label: 'Due Amount',
              value: _formatLargeValue(stats.dueAmount),
              icon: Icons.account_balance_wallet_rounded,
              isAlert: stats.dueAmount > 50000,
            ),
          ),
        ],
      ),
      loading: () => const Center(child: LinearProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatLargeValue(double value) {
    if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);
  }

  Widget _buildPurchaseVolumeChart(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(purchaseHistoryProvider);

    return historyAsync.when(
      data: (purchases) {
        final spots = _getDailySpots(purchases);
        return CustomCard(
          padding: EdgeInsets.all(context.tokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PURCHASE VOLUME (7 DAYS)',
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700, 
                  letterSpacing: 1.2, 
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 160,
                child: CustomLineChart(
                  spots: spots,
                  xLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                  color: context.successColor,
                  maxY: _getMaxY(spots),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  List<FlSpot> _getDailySpots(List<PurchaseOrder> purchases) {
    final now = DateTime.now();
    final Map<int, double> dailyTotals = {};

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dayKey = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
      dailyTotals[dayKey] = 0;
    }

    for (var p in purchases) {
      final dayKey = DateTime(p.date.year, p.date.month, p.date.day).millisecondsSinceEpoch;
      if (dailyTotals.containsKey(dayKey)) {
        dailyTotals[dayKey] = dailyTotals[dayKey]! + p.grandTotal;
      }
    }

    final sortedKeys = dailyTotals.keys.toList()..sort();
    return List.generate(sortedKeys.length, (i) => FlSpot(i.toDouble(), dailyTotals[sortedKeys[i]]!));
  }

  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 100;
    double max = 0;
    for (var s in spots) {
      if (s.y > max) max = s.y;
    }
    return max == 0 ? 100 : max * 1.2;
  }

  Widget _buildRecentEntries(BuildContext context, List<PurchaseOrder> purchases) {
    final dateFormat = DateFormat('dd MMM');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ENTRIES',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700, 
                letterSpacing: 1.2, 
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        SizedBox(height: context.tokens.space12),
        ...purchases.map((p) {
          final isReceived = p.status.toLowerCase() == 'received';
          return Padding(
            padding: EdgeInsets.only(bottom: context.tokens.space12),
            child: CustomCard(
              padding: EdgeInsets.zero,
              child: BaseListItem(
                title: p.supplierName,
                subtitle: 'SKU: ${p.id} • ${dateFormat.format(p.date)}',
                showDivider: false,
                leadingIcon: Icons.inventory_2_rounded,
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isReceived ? context.successColor : context.warningColor).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.status.toUpperCase(),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: isReceived ? context.successColor : context.warningColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${p.grandTotal.toStringAsFixed(0)}',
                      style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
