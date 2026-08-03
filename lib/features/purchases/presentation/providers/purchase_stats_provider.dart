import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'purchase_history_provider.dart';

part 'purchase_stats_provider.g.dart';

class PurchaseStats {
  final int pendingOrders;
  final double dueAmount;
  final double todayPurchases;

  PurchaseStats({
    required this.pendingOrders,
    required this.dueAmount,
    required this.todayPurchases,
  });
}

@riverpod
Future<PurchaseStats> purchaseStats(PurchaseStatsRef ref) async {
  final purchases = await ref.watch(purchaseHistoryProvider.future);
  
  final now = DateTime.now();
  final todayPurchases = purchases
      .where((p) => p.date.year == now.year && p.date.month == now.month && p.date.day == now.day)
      .fold(0.0, (sum, p) => sum + p.grandTotal);

  final pendingOrders = purchases.where((p) => p.status.toLowerCase() != 'received' && p.status.toLowerCase() != 'completed').length;
  
  // For demo, due amount is sum of non-completed orders or a fixed portion
  final dueAmount = purchases
      .where((p) => p.status.toLowerCase() != 'completed')
      .fold(0.0, (sum, p) => sum + p.grandTotal);

  return PurchaseStats(
    pendingOrders: pendingOrders,
    dueAmount: dueAmount,
    todayPurchases: todayPurchases,
  );
}
