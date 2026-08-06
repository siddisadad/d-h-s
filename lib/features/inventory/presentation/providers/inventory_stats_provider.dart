import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'inventory_provider.dart';

part 'inventory_stats_provider.g.dart';

class InventoryStats {
  final int totalItems;
  final int lowStockItems;
  final int deadStockItems;
  final double totalValue;

  InventoryStats({
    required this.totalItems,
    required this.lowStockItems,
    required this.deadStockItems,
    required this.totalValue,
  });
}

@riverpod
InventoryStats inventoryStats(InventoryStatsRef ref) {
  final productsAsync = ref.watch(inventoryNotifierProvider);
  
  return productsAsync.maybeWhen(
    data: (products) {
      final totalItems = products.length;
      final lowStockItems = products.where((p) => p.isLowStock).length;
      final totalValue = products.fold(0.0, (sum, p) => sum + (p.price * p.stock));
      
      // Dead Stock: No sales in 60 days (or no update in 60 days as proxy)
      final sixtyDaysAgo = DateTime.now().subtract(const Duration(days: 60)).millisecondsSinceEpoch;
      final deadStockItems = products.where((p) => p.stock > 0 && p.lastUpdated < sixtyDaysAgo).length;

      return InventoryStats(
        totalItems: totalItems,
        lowStockItems: lowStockItems,
        deadStockItems: deadStockItems,
        totalValue: totalValue,
      );
    },
    orElse: () => InventoryStats(
      totalItems: 0,
      lowStockItems: 0,
      deadStockItems: 0,
      totalValue: 0,
    ),
  );
}
