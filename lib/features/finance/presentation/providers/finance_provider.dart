import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../data/repositories/finance_repository_impl.dart';
import '../../data/datasources/finance_remote_data_source.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/entities/cash_closing.dart';
import '../../../sales/presentation/providers/sales_history_provider.dart';
import '../../../purchases/presentation/providers/purchase_history_provider.dart';

part 'finance_provider.g.dart';

@riverpod
FinanceRepository financeRepository(FinanceRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  final firebaseDb = ref.watch(firebaseDatabaseServiceProvider);
  final localDb = ref.watch(localDatabaseProvider);

  return FinanceRepositoryImpl(
    remoteDataSource: FinanceRemoteDataSourceImpl(client),
    localDatabase: localDb,
    firebaseDb: firebaseDb,
  );
}

@riverpod
class FinanceNotifier extends _$FinanceNotifier {
  @override
  Future<List<TransactionModel>> build() async {
    // Watch other modules to trigger refreshes on cash flow changes
    ref.watch(salesHistoryProvider);
    ref.watch(purchaseHistoryProvider);
    
    return _fetchFromApi();
  }

  Future<List<TransactionModel>> _fetchFromApi() async {
    try {
      Log.d('Fetching finance transactions from API...', name: 'Finance');
      final repository = ref.read(financeRepositoryProvider);
      final result = await repository.getTransactions();

      return result.fold(
        (failure) {
          Log.e('Finance API Fetch Failed', error: failure.message, name: 'Finance');
          throw Exception(failure.message);
        },
        (transactions) {
          Log.d('Finance API Fetch Complete', name: 'Finance');
          return transactions;
        },
      );
    } catch (e, stack) {
      Log.e('Finance Provider Error', error: e, stackTrace: stack, name: 'Finance');
      rethrow;
    }
  }

  Future<void> addTransaction({
    required String title,
    required String category,
    required double amount,
    required String paymentMode,
  }) async {
    final model = TransactionModel(
      id: 'FIN-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      amount: amount,
      date: DateTime.now(),
      paymentMode: paymentMode,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );

    final repository = ref.read(financeRepositoryProvider);
    final result = await repository.createTransaction(model);

    result.fold(
      (failure) => Log.e('Failed to create transaction', error: failure.message, name: 'Finance'),
      (success) async {
        ref.invalidateSelf();
      },
    );
  }

  Future<bool> performClosing({
    required double openingBalance,
    required double totalCashSales,
    required double totalCashExpenses,
    required double physicalCashCount,
    String? notes,
  }) async {
    final closing = CashClosing(
      id: 'CLOSE-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      openingBalance: openingBalance,
      totalCashSales: totalCashSales,
      totalCashExpenses: totalCashExpenses,
      physicalCashCount: physicalCashCount,
      notes: notes,
      performedBy: 'Manager',
    );

    final repository = ref.read(financeRepositoryProvider);
    final result = await repository.saveCashClosing(closing);

    return result.isSuccess;
  }
}

@riverpod
Future<CashClosing?> lastCashClosing(ref) async {
  final repository = ref.read(financeRepositoryProvider);
  final result = await repository.getLastClosing();
  return result.fold((f) => null, (c) => c);
}
