import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'inventory_provider.dart';

part 'inventory_stats_provider.g.dart';

class InventoryStats {
  final int totalItems;
  final int lowStockItems;
  final double totalValue;

  InventoryStats({
    required this.totalItems,
    required this.lowStockItems,
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
      
      return InventoryStats(
        totalItems: totalItems,
        lowStockItems: lowStockItems,
        totalValue: totalValue,
      );
    },
    orElse: () => InventoryStats(
      totalItems: 0,
      lowStockItems: 0,
      totalValue: 0,
    ),
  );
}
