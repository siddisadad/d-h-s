import 'package:flutter/foundation.dart';
import 'package:deshmukh_steel_e_r_p/core/network/api_client.dart';
import 'package:deshmukh_steel_e_r_p/features/sales/domain/entities/sales_invoice.dart';
import 'package:deshmukh_steel_e_r_p/features/sales/domain/entities/sales_quotation.dart';
import 'package:deshmukh_steel_e_r_p/features/sales/domain/entities/sales_return.dart';
import 'package:deshmukh_steel_e_r_p/features/sales/data/models/invoice_model.dart';
import 'package:deshmukh_steel_e_r_p/features/sales/data/models/quotation_model.dart';
import 'package:deshmukh_steel_e_r_p/features/sales/data/models/return_model.dart';

abstract class SalesRemoteDataSource {
  Future<bool> createInvoice(SalesInvoice invoice);
  Future<List<SalesInvoice>> getRecentInvoices();

  Future<bool> createQuotation(SalesQuotation quotation);
  Future<List<SalesQuotation>> getQuotations();

  Future<bool> processReturn(SalesReturn salesReturn);
  Future<List<SalesReturn>> getReturns();
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final ApiClient _client;

  SalesRemoteDataSourceImpl(this._client);

  @override
  Future<bool> createInvoice(SalesInvoice invoice) async {
    try {
      final model = InvoiceModel(
        id: invoice.id,
        customerId: invoice.customerId,
        customerName: invoice.customerName,
        date: invoice.date,
        items: invoice.items,
        discount: invoice.discount,
        lastUpdated: invoice.lastUpdated,
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

  @override
  Future<bool> createQuotation(SalesQuotation quotation) async {
    try {
      final model = QuotationModel(
        id: quotation.id,
        customerId: quotation.customerId,
        customerName: quotation.customerName,
        date: quotation.date,
        expiryDate: quotation.expiryDate,
        items: quotation.items,
        discount: quotation.discount,
        status: quotation.status,
        lastUpdated: quotation.lastUpdated,
      );
      final response = await _client.dio.post('/quotations', data: model.toJson());
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) return true;
      rethrow;
    }
  }

  @override
  Future<List<SalesQuotation>> getQuotations() async {
    try {
      final response = await _client.dio.get('/quotations');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => QuotationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) return _mockQuotes;
      rethrow;
    }
  }

  @override
  Future<bool> processReturn(SalesReturn salesReturn) async {
    try {
      final model = ReturnModel(
        id: salesReturn.id,
        originalInvoiceId: salesReturn.originalInvoiceId,
        customerId: salesReturn.customerId,
        customerName: salesReturn.customerName,
        date: salesReturn.date,
        items: salesReturn.items,
        reason: salesReturn.reason,
        grandTotal: salesReturn.grandTotal,
        lastUpdated: salesReturn.lastUpdated,
      );
      final response = await _client.dio.post('/returns', data: model.toJson());
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) return true;
      rethrow;
    }
  }

  @override
  Future<List<SalesReturn>> getReturns() async {
    try {
      final response = await _client.dio.get('/returns');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ReturnModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) return _mockReturns;
      rethrow;
    }
  }

  final List<SalesQuotation> _mockQuotes = [];
  final List<SalesReturn> _mockReturns = [];
}

class SalesMockDataSourceImpl implements SalesRemoteDataSource {
  @override
  Future<bool> createInvoice(SalesInvoice invoice) async => true;
  @override
  Future<List<SalesInvoice>> getRecentInvoices() async => [];
  @override
  Future<bool> createQuotation(SalesQuotation quotation) async => true;
  @override
  Future<List<SalesQuotation>> getQuotations() async => [];
  @override
  Future<bool> processReturn(SalesReturn salesReturn) async => true;
  @override
  Future<List<SalesReturn>> getReturns() async => [];
}
