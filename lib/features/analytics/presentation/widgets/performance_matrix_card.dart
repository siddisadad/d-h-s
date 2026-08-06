import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../sales/presentation/providers/sales_history_provider.dart';
import '../../../purchases/presentation/providers/purchase_history_provider.dart';

class PerformanceMatrixCard extends ConsumerWidget {
  const PerformanceMatrixCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}

class _DataPoint {
  final DateTime date;
  final double value;
  _DataPoint(this.date, this.value);
}
