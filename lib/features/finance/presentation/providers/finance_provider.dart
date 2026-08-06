import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../data/repositories/finance_repository_impl.dart';
import '../../data/datasources/finance_remote_data_source.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/transaction_model.dart';
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
      title: title,
      category: category,
      amount: amount,
      date: DateTime.now(),
      paymentMode: paymentMode,
    );

    final repository = ref.read(financeRepositoryProvider);
    final result = await repository.createTransaction(model);

    result.fold(
      (failure) => Log.e('Failed to create transaction', error: failure.message, name: 'Finance'),
      (success) async {
        // Sync to Firebase
        try {
           final firebaseDb = ref.read(firebaseDatabaseServiceProvider);
           await firebaseDb.pushData('finance', model.toJson());
           
           // Record Activity
           await firebaseDb.pushData('activities', {
             'id': 'FIN-${DateTime.now().millisecondsSinceEpoch}',
             'title': 'Finance Entry: $category',
             'subtitle': '$title - ₹$amount',
             'timestamp': DateTime.now().millisecondsSinceEpoch,
             'type': category == 'Income' ? 'sale' : 'purchase',
           });
        } catch (e) {
           Log.w('Firebase finance sync failed: $e', name: 'Finance');
        }
        ref.invalidateSelf();
      },
    );
  }
}
