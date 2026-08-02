import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/transaction_model.dart';

part 'finance_provider.g.dart';

@riverpod
class FinanceNotifier extends _$FinanceNotifier {
  @override
  Future<List<TransactionModel>> build() async {
    return _fetchFromApi();
  }

  Future<List<TransactionModel>> _fetchFromApi() async {
    try {
      debugPrint('🌐 [Finance] Fetching from API...');
      final repository = sl.financeRepository;
      final result = await repository.getTransactions();

      return result.fold(
        (failure) {
          debugPrint('❌ [Finance] API Fetch Failed: ${failure.message}');
          throw Exception(failure.message);
        },
        (transactions) {
          debugPrint('✅ [Finance] API Fetch Complete');
          return transactions;
        },
      );
    } catch (e) {
      debugPrint('⚠️ [Finance] Error: $e');
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

    final repository = sl.financeRepository;
    final result = await repository.createTransaction(model);

    result.fold(
      (failure) => debugPrint('❌ [Finance] Failed to create transaction: ${failure.message}'),
      (success) {
        ref.invalidateSelf();
      },
    );
  }
}
