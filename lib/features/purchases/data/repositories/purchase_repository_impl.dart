import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_remote_data_source.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseRemoteDataSource remoteDataSource;

  PurchaseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<PurchaseOrder>>> getRecentPurchases() async {
    try {
      final purchases = await remoteDataSource.getRecentPurchases();
      return Result.success(purchases);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
