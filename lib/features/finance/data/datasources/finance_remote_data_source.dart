import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../models/transaction_model.dart';

abstract class FinanceRemoteDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<bool> createTransaction(TransactionModel transaction);
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final ApiClient _client;

  FinanceRemoteDataSourceImpl(this._client);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _client.dio.get('/finance/transactions');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      debugPrint('⚠️ [Finance API] Fetch Failed: $e');
      if (kDebugMode) return _mockTransactions;
      rethrow;
    }
  }

  @override
  Future<bool> createTransaction(TransactionModel transaction) async {
    try {
      final response = await _client.dio.post('/finance/transactions', data: transaction.toJson());
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [Finance API] Transaction Create Failed: $e');
      if (kDebugMode) return true;
      rethrow;
    }
  }

  final List<TransactionModel> _mockTransactions = [
    TransactionModel(id: 1, title: 'Sale - INV001', category: 'Income', amount: 45000, date: DateTime.now(), paymentMode: 'Cash'),
    TransactionModel(id: 2, title: 'Salary Payment', category: 'Expense', amount: 12000, date: DateTime.now(), paymentMode: 'Bank'),
  ];
}

class FinanceMockDataSourceImpl implements FinanceRemoteDataSource {
  @override
  Future<List<TransactionModel>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  @override
  Future<bool> createTransaction(TransactionModel transaction) async => true;
}
