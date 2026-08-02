import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_remote_data_source.dart';
import '../models/transaction_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  FinanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<TransactionModel>>> getTransactions() async {
    try {
      final transactions = await remoteDataSource.getTransactions();
      return Result.success(transactions);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> createTransaction(TransactionModel transaction) async {
    try {
      final success = await remoteDataSource.createTransaction(transaction);
      return Result.success(success);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
