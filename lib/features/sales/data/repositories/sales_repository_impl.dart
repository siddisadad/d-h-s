import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/sales_invoice.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_data_source.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;

  SalesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<bool>> createInvoice(SalesInvoice invoice) async {
    try {
      final success = await remoteDataSource.createInvoice(invoice);
      return Result.success(success);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SalesInvoice>>> getRecentInvoices() async {
    try {
      final invoices = await remoteDataSource.getRecentInvoices();
      return Result.success(invoices);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
