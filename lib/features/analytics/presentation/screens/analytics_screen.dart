import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/services/excel_service.dart';
import '../providers/analytics_provider.dart';
import '../../../sales/presentation/providers/sales_history_provider.dart';
import '../../../purchases/presentation/providers/purchase_history_provider.dart';
import '../../../employees/presentation/providers/employee_provider.dart';
import 'package:intl/intl.dart';

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
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              final sales = ref.read(salesHistoryProvider).value ?? [];
              ref.read(excelServiceProvider.notifier).exportSalesReport(sales);
            },
            tooltip: 'Export Report',
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
          _buildMainComparisonChart(context),
          const SizedBox(height: 32),
          Text('QUICK REPORTS',
              style: context.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildReportGrid(context),
          const SizedBox(height: 32),
          _buildProfitAndLossCard(context),
          const SizedBox(height: 32),
          _buildPerformanceSummary(context),
        ],
      ),
    );
  }

  Widget _buildProfitAndLossCard(BuildContext context) {
    final tokens = context.tokens;
    final salesAsync = ref.watch(salesHistoryProvider);
    final purchasesAsync = ref.watch(purchaseHistoryProvider);
    final employeesAsync = ref.watch(employeeNotifierProvider);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return salesAsync.when(
      data: (sales) => purchasesAsync.when(
        data: (purchases) => employeesAsync.when(
          data: (employees) {
            final grossSales = sales.fold(0.0, (sum, s) => sum + s.grandTotal);
            final cogs = purchases.fold(0.0, (sum, p) => sum + p.grandTotal);
            final salaries = employees.fold(0.0, (sum, e) => sum + (double.tryParse(e.salary.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0));
            final totalExpenses = cogs + salaries;
            final netProfit = grossSales - totalExpenses;
            final margin = grossSales > 0 ? (netProfit / grossSales) * 100 : 0.0;

            return CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PROFIT & LOSS (YTD)', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  _plRow(context, 'Gross Sales', currency.format(grossSales), isPositive: true),
                  _plRow(context, 'Cost of Goods', currency.format(cogs), isPositive: false),
                  _plRow(context, 'Payroll / Salaries', currency.format(salaries), isPositive: false),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('NET PROFIT', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      Text(currency.format(netProfit), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: netProfit >= 0 ? context.tokens.success : context.colorScheme.error)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Margin: ${margin.toStringAsFixed(1)}%', style: context.textTheme.labelSmall),
                ],
              ),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, s) => Text('Error loading employees: $e'),
        ),
        loading: () => const LinearProgressIndicator(),
        error: (e, s) => Text('Error loading purchases: $e'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading sales: $e'),
    );
  }

  Widget _plRow(BuildContext context, String label, String value,
      {required bool isPositive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          Text(
            '${isPositive ? '+' : '-'} $value',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isPositive
                  ? context.colorScheme.primary
                  : context.colorScheme.error,
            ),
          ),
        ],
      ),
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

  Widget _buildMainComparisonChart(BuildContext context) {
    final tokens = context.tokens;
    final salesAsync = ref.watch(salesHistoryProvider);
    final purchasesAsync = ref.watch(purchaseHistoryProvider);

    return salesAsync.when(
      data: (sales) => purchasesAsync.when(
        data: (purchases) {
          final salesSpots = _getDailySpots(
              sales.map((e) => _DataPoint(e.date, e.grandTotal)).toList());
          final purchaseSpots = _getDailySpots(
              purchases.map((e) => _DataPoint(e.date, e.grandTotal)).toList());

          return CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Performance Matrix',
                            style: context.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text('Sales vs Purchases (Last 7 Days)',
                            style: context.textTheme.bodySmall),
                      ],
                    ),
                    _chartLegend(context),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: salesSpots,
                          isCurved: true,
                          color: context.colorScheme.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                              show: true,
                              color: context.colorScheme.primary
                                  .withValues(alpha: 0.1)),
                        ),
                        LineChartBarData(
                          spots: purchaseSpots,
                          isCurved: true,
                          color: context.colorScheme.error,
                          barWidth: 2,
                          dashArray: [5, 5],
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox(
            height: 220, child: Center(child: CircularProgressIndicator())),
        error: (e, s) => Text('Error: $e'),
      ),
      loading: () => const SizedBox(
          height: 220, child: Center(child: CircularProgressIndicator())),
      error: (e, s) => Text('Error: $e'),
    );
  }

  List<FlSpot> _getDailySpots(List<_DataPoint> data) {
    final now = DateTime.now();
    final Map<int, double> dailyTotals = {};

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dayKey =
          DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
      dailyTotals[dayKey] = 0;
    }

    for (var p in data) {
      final dayKey =
          DateTime(p.date.year, p.date.month, p.date.day).millisecondsSinceEpoch;
      if (dailyTotals.containsKey(dayKey)) {
        dailyTotals[dayKey] = dailyTotals[dayKey]! + p.value;
      }
    }

    final sortedKeys = dailyTotals.keys.toList()..sort();
    return List.generate(sortedKeys.length,
        (i) => FlSpot(i.toDouble(), dailyTotals[sortedKeys[i]]!));
  }

  Widget _chartLegend(BuildContext context) {
    return Row(
      children: [
        _legendItem('Sales', context.colorScheme.primary),
        const SizedBox(width: 12),
        _legendItem('Purchases', context.colorScheme.error),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildReportGrid(BuildContext context) {
    final reports = [
      {'icon': Icons.trending_up, 'label': 'Sales Register'},
      {'icon': Icons.inventory_2, 'label': 'Stock Ledger'},
      {'icon': Icons.account_balance, 'label': 'Profit & Loss'},
      {'icon': Icons.pie_chart, 'label': 'GST Reports'},
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: reports
          .map((r) => CustomCard(
                onTap: () {},
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(r['icon'] as IconData,
                        color: context.colorScheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(r['label'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ))
          .toList(),
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

class _DataPoint {
  final DateTime date;
  final double value;
  _DataPoint(this.date, this.value);
}
