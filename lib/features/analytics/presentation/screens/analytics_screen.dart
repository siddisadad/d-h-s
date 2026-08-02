import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BUSINESS ANALYTICS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {},
            tooltip: 'Export Report',
          ),
          SizedBox(width: context.tokens.space16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeRangeSelector(context),
            SizedBox(height: tokens.space24),
            _buildMainComparisonChart(context),
            SizedBox(height: tokens.space32),
            Text('QUICK REPORTS', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            SizedBox(height: tokens.space16),
            _buildReportGrid(context),
            SizedBox(height: tokens.space32),
            _buildProfitAndLossCard(context),
            SizedBox(height: tokens.space32),
            _buildPerformanceSummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitAndLossCard(BuildContext context) {
    final tokens = context.tokens;
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PROFIT & LOSS', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          SizedBox(height: tokens.space16),
          _plRow(context, 'Gross Sales', '₹12,45,000', isPositive: true),
          _plRow(context, 'Cost of Goods', '₹8,12,000', isPositive: false),
          _plRow(context, 'Operating Expenses', '₹1,05,000', isPositive: false),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NET PROFIT', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              Text('₹3,28,000', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.success)),
            ],
          ),
          SizedBox(height: tokens.space8),
          Text('Margin: 26.3%', style: context.textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _plRow(BuildContext context, String label, String value, {required bool isPositive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          Text(
            (isPositive ? '+' : '-') + ' ' + value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isPositive ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.border.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: TimeRange.values.map((range) {
          final isSelected = _selectedRange == range;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedRange = range),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  range.name.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
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
                  Text('Performance Matrix', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Text('Sales vs Purchases trend', style: context.textTheme.bodySmall),
                ],
              ),
              _chartLegend(),
            ],
          ),
          SizedBox(height: tokens.space32),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 45), FlSpot(1, 52), FlSpot(2, 48), FlSpot(3, 70), FlSpot(4, 61), FlSpot(5, 85), FlSpot(6, 92)],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 30), FlSpot(1, 40), FlSpot(2, 35), FlSpot(3, 50), FlSpot(4, 45), FlSpot(5, 60), FlSpot(6, 55)],
                    isCurved: true,
                    color: AppColors.error,
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
  }

  Widget _chartLegend() {
    return Row(
      children: [
        _legendItem('Sales', AppColors.primary),
        const SizedBox(width: 12),
        _legendItem('Purchases', AppColors.error),
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
      children: reports.map((r) => CustomCard(
        onTap: () {},
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(r['icon'] as IconData, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Text(r['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildPerformanceSummary(BuildContext context) {
    return CustomCard(
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MONTHLY NET MARGIN', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              const SizedBox(height: 4),
              Text('₹4,25,000', style: context.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.arrow_upward_rounded, color: AppColors.success, size: 16),
                Text(' +18%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
