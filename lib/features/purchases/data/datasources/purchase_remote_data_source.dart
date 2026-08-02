import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/purchase_order.dart';
import '../models/purchase_model.dart';

abstract class PurchaseRemoteDataSource {
  Future<List<PurchaseOrder>> getRecentPurchases();
}

class PurchaseRemoteDataSourceImpl implements PurchaseRemoteDataSource {
  final ApiClient _client;

  PurchaseRemoteDataSourceImpl(this._client);

  @override
  Future<List<PurchaseOrder>> getRecentPurchases() async {
    try {
      final response = await _client.dio.get('/purchases');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PurchaseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load purchases');
      }
    } catch (e) {
      debugPrint('⚠️ [Purchases API] Fetch Failed: $e');
      if (kDebugMode) return _mockPurchases;
      rethrow;
    }
  }

  final List<PurchaseOrder> _mockPurchases = [
    PurchaseOrder(id: 'TSL-2024-01', supplierName: 'Tata Steel Ltd.', date: '24 Oct', amount: '₹1,25,000', status: 'received'),
    PurchaseOrder(id: 'JSW-HRD-88', supplierName: 'JSW Steel Corp', date: '23 Oct', amount: '₹84,200', status: 'Pending'),
  ];
}

class PurchaseMockDataSourceImpl implements PurchaseRemoteDataSource {
  @override
  Future<List<PurchaseOrder>> getRecentPurchases() async {
    return [];
  }
}
