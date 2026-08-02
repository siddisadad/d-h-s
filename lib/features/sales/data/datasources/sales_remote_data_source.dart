import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/sales_invoice.dart';
import '../models/invoice_model.dart';

abstract class SalesRemoteDataSource {
  Future<bool> createInvoice(SalesInvoice invoice);
  Future<List<SalesInvoice>> getRecentInvoices();
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final ApiClient _client;

  SalesRemoteDataSourceImpl(this._client);

  @override
  Future<bool> createInvoice(SalesInvoice invoice) async {
    try {
      final model = InvoiceModel(
        id: invoice.id,
        customerName: invoice.customerName,
        date: invoice.date,
        items: invoice.items,
        discount: invoice.discount,
      );

      final response = await _client.dio.post(
        '/invoices',
        data: model.toJson(),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [Sales API] Invoice Create Failed: $e');
      if (kDebugMode) return true;
      rethrow;
    }
  }

  @override
  Future<List<SalesInvoice>> getRecentInvoices() async {
    try {
      final response = await _client.dio.get('/invoices/recent');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InvoiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recent invoices');
      }
    } catch (e) {
      debugPrint('⚠️ [Sales API] Fetch Failed: $e');
      if (kDebugMode) return [];
      rethrow;
    }
  }
}

class SalesMockDataSourceImpl implements SalesRemoteDataSource {
  @override
  Future<bool> createInvoice(SalesInvoice invoice) async => true;
  @override
  Future<List<SalesInvoice>> getRecentInvoices() async => [];
}
