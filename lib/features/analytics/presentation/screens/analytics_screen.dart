import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/services/excel_service.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/permission_wrapper.dart';
import 'package:deshmukh_steel_e_r_p/core/security/permissions.dart';

import '../../../sales/presentation/providers/sales_history_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../widgets/profit_loss_card.dart';
import '../widgets/performance_matrix_card.dart';
import '../widgets/category_profitability_card.dart';
import '../widgets/report_grid.dart';
import '../providers/cash_flow_provider.dart';
import 'package:fl_chart/fl_chart.dart';

enum TimeRange { week, month, quarter, year }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  TimeRange _selectedRange = TimeRange.week;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'BUSINESS ANALYTICS',
        actions: [
          PermissionWrapper(
            requiredPermissions: const [AppPermission.exportData],
            child: IconButton(
              icon: const Icon(Icons.file_download_outlined),
              onPressed: () {
                final sales = ref.read(salesHistoryProvider).value ?? [];
                ref.read(excelServiceProvider.notifier).exportSalesReport(sales);
              },
              tooltip: 'Export Report',
            ),
          ),
        ],
      );
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(context),
          const SizedBox(height: 24),
          const PerformanceMatrixCard(),
          const SizedBox(height: 32),
          Text('QUICK REPORTS',
              style: context.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          const ReportGrid(),
          const SizedBox(height: 32),
          const CategoryProfitabilityCard(),
          const SizedBox(height: 32),
          _buildInventoryInsights(context),
          const SizedBox(height: 32),
          _buildCashFlowTrend(context),
          const SizedBox(height: 32),
          const ProfitLossCard(),
          const SizedBox(height: 32),
          _buildPerformanceSummary(context),
        ],
      ),
    );
  }

  Widget _buildInventoryInsights(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final salesAsync = ref.watch(salesHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INVENTORY INSIGHTS',
            style: context.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        inventoryAsync.when(
          data: (products) => salesAsync.when(
            data: (sales) {
              // Calculate Dead Stock (No sales in last 90 days)
              final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
              final soldSkus = sales
                  .where((s) => s.date.isAfter(ninetyDaysAgo))
                  .expand((s) => s.items)
                  .map((i) => i.sku)
                  .toSet();

              final deadStockCount = products.where((p) => !soldSkus.contains(p.sku)).length;

              // Top Moving (by quantity in last 30 days)
              final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
              final salesMap = <String, double>{};
              for (final sale in sales.where((s) => s.date.isAfter(thirtyDaysAgo))) {
                for (final item in sale.items) {
                  salesMap[item.name] = (salesMap[item.name] ?? 0) + item.qty;
                }
              }
              final topMoving = salesMap.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final topItem = topMoving.isNotEmpty ? topMoving.first.key : 'N/A';

              return Row(
                children: [
                  Expanded(
                    child: CustomCard(
                      padding: const EdgeInsets.all(16),
                      color: context.colorScheme.errorContainer.withValues(alpha: 0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.inventory_2_outlined, color: context.colorScheme.error),
                          const SizedBox(height: 12),
                          Text('$deadStockCount Items',
                              style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text('DEAD STOCK (90D)',
                              style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: context.colorScheme.error)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomCard(
                      padding: const EdgeInsets.all(16),
                      color: context.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.trending_up_rounded, color: context.colorScheme.primary),
                          const SizedBox(height: 12),
                          Text(topItem,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text('TOP MOVING (30D)',
                              style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: context.colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, s) => const SizedBox.shrink(),
          ),
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: context.theme.dividerColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: TimeRange.values.map((range) {
          final isSelected = _selectedRange == range;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedRange = range),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  range.name.toUpperCase(),
                  style: TextStyle(
                    color:
                        isSelected ? Colors.white : context.tokens.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCashFlowTrend(BuildContext context) {
    final cashFlowAsync = ref.watch(cashFlowProvider);

    return cashFlowAsync.when(
      data: (data) => CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('FUNDS FLOW (LAST 30 DAYS)', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                _chartLegend(context),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  maxY: data.maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.inflowSpots,
                      isCurved: true,
                      color: context.tokens.success,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: data.outflowSpots,
                      isCurved: true,
                      color: context.colorScheme.error,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Scaling: Units in ₹1,000s', style: context.textTheme.labelSmall?.copyWith(color: context.tokens.textSecondary)),
          ],
        ),
      ),
      loading: () => const Center(child: LinearProgressIndicator()),
      error: (e, s) => Text('Error loading cash flow: $e'),
    );
  }

  Widget _chartLegend(BuildContext context) {
    return Row(
      children: [
        _legendItem('Inflow', context.tokens.success),
        const SizedBox(width: 12),
        _legendItem('Outflow', context.colorScheme.error),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPerformanceSummary(BuildContext context) {
    return CustomCard(
      color: context.colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MONTHLY NET MARGIN',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1)),
              const SizedBox(height: 4),
              Text('₹4,25,000',
                  style: context.textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white12, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.arrow_upward_rounded,
                    color: context.tokens.success, size: 16),
                const Text(' +18%',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
