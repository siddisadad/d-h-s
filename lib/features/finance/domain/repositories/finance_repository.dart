import '../../../../core/error/result.dart';
import '../../data/models/transaction_model.dart';

abstract class FinanceRepository {
  Future<Result<List<TransactionModel>>> getTransactions();
  Future<Result<bool>> createTransaction(TransactionModel transaction);
}
