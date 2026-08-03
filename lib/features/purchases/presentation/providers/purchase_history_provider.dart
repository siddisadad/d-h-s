import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/purchase_order.dart';
import 'purchase_provider.dart';

part 'purchase_history_provider.g.dart';

@riverpod
Future<List<PurchaseOrder>> purchaseHistory(PurchaseHistoryRef ref) async {
  final repository = ref.watch(purchaseRepositoryProvider);
  final result = await repository.getRecentPurchases();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (purchases) => purchases,
  );
}
