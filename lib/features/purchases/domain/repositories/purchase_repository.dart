import '../../../../core/error/result.dart';
import '../entities/purchase_order.dart';

abstract class PurchaseRepository {
  Future<Result<List<PurchaseOrder>>> getRecentPurchases();
  Future<Result<bool>> createPurchase(PurchaseOrder purchase);
}
