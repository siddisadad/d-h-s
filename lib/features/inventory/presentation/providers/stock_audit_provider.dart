import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/stock_audit.dart';
import 'inventory_provider.dart';

part 'stock_audit_provider.g.dart';

@riverpod
class StockAuditNotifier extends _$StockAuditNotifier {
  @override
  Future<List<StockAudit>> build() async {
    final repository = ref.read(inventoryRepositoryProvider);
    final result = await repository.getStockAudits();
    return result.fold((f) => [], (a) => a);
  }

  Future<void> createAudit(StockAudit audit) async {
    final repository = ref.read(inventoryRepositoryProvider);
    final result = await repository.createStockAudit(audit);
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
  }
}
