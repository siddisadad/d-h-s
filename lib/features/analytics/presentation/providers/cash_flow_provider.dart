import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../sales/presentation/providers/sales_history_provider.dart';
import '../../../purchases/presentation/providers/purchase_history_provider.dart';
import '../../../finance/presentation/providers/finance_provider.dart';
import 'package:fl_chart/fl_chart.dart';

part 'cash_flow_provider.g.dart';

class CashFlowData {
  final List<FlSpot> inflowSpots;
  final List<FlSpot> outflowSpots;
  final List<String> xLabels;
  final double maxY;

  CashFlowData({
    required this.inflowSpots,
    required this.outflowSpots,
    required this.xLabels,
    required this.maxY,
  });
}

@riverpod
Future<CashFlowData> cashFlow(CashFlowRef ref) async {
  final sales = await ref.watch(salesHistoryProvider.future);
  final purchases = await ref.watch(purchaseHistoryProvider.future);
  final finance = await ref.watch(financeNotifierProvider.future);

  final now = DateTime.now();
  final last30Days = List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));

  final List<FlSpot> inflowSpots = [];
  final List<FlSpot> outflowSpots = [];
  double maxVal = 1000;

  for (int i = 0; i < 30; i++) {
    final day = last30Days[i];

    // Inflow: Sales + Income
    final daySales = sales.where((s) => _isSameDay(s.date, day)).fold(0.0, (sum, s) => sum + s.grandTotal);
    final dayIncome = finance.where((t) => t.category == 'Income' && _isSameDay(t.date, day)).fold(0.0, (sum, t) => sum + t.amount);
    final totalIn = daySales + dayIncome;

    // Outflow: Purchases + Expenses
    final dayPurchases = purchases.where((p) => _isSameDay(p.date, day)).fold(0.0, (sum, p) => sum + p.grandTotal);
    final dayExpense = finance.where((t) => t.category == 'Expense' && _isSameDay(t.date, day)).fold(0.0, (sum, t) => sum + t.amount);
    final totalOut = dayPurchases + dayExpense;

    inflowSpots.add(FlSpot(i.toDouble(), totalIn / 1000));
    outflowSpots.add(FlSpot(i.toDouble(), totalOut / 1000));

    if (totalIn / 1000 > maxVal) maxVal = totalIn / 1000;
    if (totalOut / 1000 > maxVal) maxVal = totalOut / 1000;
  }

  return CashFlowData(
    inflowSpots: inflowSpots,
    outflowSpots: outflowSpots,
    xLabels: last30Days.map((d) => d.day.toString()).toList(),
    maxY: maxVal * 1.2,
  );
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
