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
    PurchaseOrder(
      id: 'TSL-2024-01', 
      supplierId: 'S001', 
      supplierName: 'Tata Steel Ltd.', 
      date: DateTime(2024, 10, 24), 
      items: [], 
      status: 'Received',
    ),
  ];
}

class PurchaseMockDataSourceImpl implements PurchaseRemoteDataSource {
  @override
  Future<List<PurchaseOrder>> getRecentPurchases() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }
}
