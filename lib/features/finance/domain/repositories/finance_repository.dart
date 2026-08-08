import '../../../../core/error/result.dart';
import '../../data/models/transaction_model.dart';

import '../entities/cash_closing.dart';

abstract class FinanceRepository {
  Future<Result<List<TransactionModel>>> getTransactions();
  Future<Result<bool>> createTransaction(TransactionModel transaction);

  // Daily Closing
  Future<Result<bool>> saveCashClosing(CashClosing closing);
  Future<Result<CashClosing?>> getLastClosing();
}
