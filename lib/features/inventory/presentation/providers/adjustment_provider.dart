import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/stock_adjustment.dart';
import 'inventory_provider.dart';

part 'adjustment_provider.g.dart';

@riverpod
class AdjustmentNotifier extends _$AdjustmentNotifier {
  @override
  List<StockAdjustment> build() {
    // Initial mock history
    return [
      StockAdjustment(
        id: 'adj_1',
        productSku: 'MS-BAR-12',
        productName: 'TMT Steel Bar 12mm',
        quantityChange: -15.0,
        warehouseId: 'main_yard',
        reason: AdjustmentReason.damaged,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        performedBy: 'Admin User',
        notes: 'Bent during unloading',
      ),
      StockAdjustment(
        id: 'adj_2',
        productSku: 'DRL-BOS-GSR',
        productName: 'Bosch Cordless Drill',
        quantityChange: 1.0,
        warehouseId: 'main_yard',
        reason: AdjustmentReason.found,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        performedBy: 'Inventory Manager',
        notes: 'Audit correction',
      ),
      StockAdjustment(
        id: 'adj_3',
        productSku: 'PLM-PIPE-PVC',
        productName: 'PVC Pipe 4-inch',
        quantityChange: -5.0,
        warehouseId: 'main_yard',
        reason: AdjustmentReason.lost,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        performedBy: 'Staff One',
      ),
    ];
  }

  Future<void> addAdjustment(StockAdjustment adjustment) async {
    // 1. Update the inventory stock level
    await ref.read(inventoryNotifierProvider.notifier).adjustStock(
      adjustment.productSku, 
      adjustment.warehouseId,
      adjustment.quantityChange,
    );

    // 2. Add to history state
    state = [adjustment, ...state];
  }
}

@riverpod
List<StockAdjustment> productHistory(ProductHistoryRef ref, String sku) {
  final allAdjustments = ref.watch(adjustmentNotifierProvider);
  return allAdjustments.where((adj) => adj.productSku == sku).toList();
}
