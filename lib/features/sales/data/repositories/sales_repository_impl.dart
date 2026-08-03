import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/database/local_database.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/sales_invoice.dart';
import '../../domain/entities/sales_quotation.dart';
import '../../domain/entities/sales_return.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_data_source.dart';
import '../models/invoice_model.dart';
import '../models/quotation_model.dart';
import '../models/return_model.dart';
import '../../../../core/di/injection_container.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;
  final LocalDatabase localDatabase;

  SalesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatabase,
  });

  @override
  Future<Result<bool>> createInvoice(SalesInvoice invoice) async {
    final db = await localDatabase.database;
    
    try {
      return await db.transaction((txn) async {
        final model = InvoiceModel(
          id: invoice.id,
          customerId: invoice.customerId,
          customerName: invoice.customerName,
          date: invoice.date,
          items: invoice.items,
          discount: invoice.discount,
        );

        // 1. Save invoice locally
        await txn.insert('sales', {
          'id': model.id,
          'customerId': model.customerId,
          'customerName': model.customerName,
          'date': model.date.millisecondsSinceEpoch,
          'discount': model.discount,
          'grandTotal': model.grandTotal,
          'items': jsonEncode(model.toJson()['items']),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // 2. Update Stock levels
        for (var item in invoice.items) {
          final List<Map<String, dynamic>> results = await txn.query(
            'inventory',
            where: 'sku = ?',
            whereArgs: [item.sku],
          );

          if (results.isNotEmpty) {
            final product = results.first;
            final currentStock = (product['stock'] as num).toDouble();
            final newStock = currentStock - item.qty;
            
            await txn.update(
              'inventory',
              {
                'stock': newStock,
                'isLowStock': newStock < 10 ? 1 : 0,
              },
              where: 'sku = ?',
              whereArgs: [product['sku']],
            );

            // Update Per-Warehouse Stock Level (Default to Main Yard)
            await localDatabase.updateStockLevel(item.sku, 'main_yard', -item.qty);
          }
        }

        // 3. Update Customer Balance & Ledger
        final List<Map<String, dynamic>> contactResults = await txn.query(
          'contacts',
          where: 'id = ?',
          whereArgs: [invoice.customerId],
        );

        double newBalance = invoice.grandTotal;
        if (contactResults.isNotEmpty) {
          final contact = contactResults.first;
          final currentBalance = (contact['balance'] as num).toDouble();
          newBalance = currentBalance + invoice.grandTotal;

          await txn.update(
            'contacts',
            {'balance': newBalance},
            where: 'id = ?',
            whereArgs: [invoice.customerId],
          );
        }

        await txn.insert('ledgers', {
          'contactId': invoice.customerId,
          'date': invoice.date.millisecondsSinceEpoch,
          'type': 'Invoice',
          'ref': invoice.id,
          'amount': invoice.grandTotal,
          'balanceAfter': newBalance,
          'isDebit': 1,
        });

        // 4. Cloud Sync
        try {
          await sl.firebaseDb.setData('sales/${invoice.id}', model.toJson());
          for (var item in invoice.items) {
             final List<Map<String, dynamic>> updatedProd = await txn.query('inventory', where: 'sku = ?', whereArgs: [item.sku]);
             if (updatedProd.isNotEmpty) {
                await sl.firebaseDb.updateData('inventory/${item.sku}', {
                  'stock': updatedProd.first['stock'],
                  'isLowStock': updatedProd.first['isLowStock'] == 1,
                });
             }
          }
          await sl.firebaseDb.updateData('contacts/${invoice.customerId}', {'balance': newBalance});
          await sl.firebaseDb.pushData('activities', {
            'id': invoice.id,
            'title': 'New Sale Created',
            'subtitle': '${invoice.customerName} - ₹${invoice.grandTotal.toStringAsFixed(0)}',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'type': 'sale',
          });
        } catch (_) {}

        return Result.success(true);
      });
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SalesInvoice>>> getRecentInvoices() async {
    try {
      final db = await localDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query('sales', orderBy: 'date DESC');
      final invoices = maps.map((m) {
        final List<dynamic> itemsJson = jsonDecode(m['items']);
        return SalesInvoice(
          id: m['id'],
          customerId: m['customerId'],
          customerName: m['customerName'],
          date: DateTime.fromMillisecondsSinceEpoch(m['date']),
          items: itemsJson.map((i) => InvoiceItemModel.fromJson(i)).toList(),
          discount: (m['discount'] as num).toDouble(),
        );
      }).toList();
      return Result.success(invoices);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> createQuotation(SalesQuotation quotation) async {
    try {
      final db = await localDatabase.database;
      final model = QuotationModel(
        id: quotation.id,
        customerId: quotation.customerId,
        customerName: quotation.customerName,
        date: quotation.date,
        expiryDate: quotation.expiryDate,
        items: quotation.items,
        discount: quotation.discount,
        status: quotation.status,
      );
      
      await db.insert('quotations', model.toJson()..['items'] = jsonEncode(model.toJson()['items']), conflictAlgorithm: ConflictAlgorithm.replace);

      try {
        await sl.firebaseDb.setData('quotations/${quotation.id}', model.toJson());
        await sl.firebaseDb.pushData('activities', {
          'id': quotation.id,
          'title': 'New Quotation Generated',
          'subtitle': '${quotation.customerName} - ₹${quotation.grandTotal.toStringAsFixed(0)}',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'type': 'sale',
        });
      } catch (_) {}

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SalesQuotation>>> getQuotations() async {
    try {
      final db = await localDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query('quotations', orderBy: 'date DESC');
      return Result.success(maps.map((m) {
        final List<dynamic> itemsJson = jsonDecode(m['items']);
        return SalesQuotation(
          id: m['id'],
          customerId: m['customerId'],
          customerName: m['customerName'],
          date: DateTime.fromMillisecondsSinceEpoch(m['date']),
          expiryDate: DateTime.fromMillisecondsSinceEpoch(m['expiryDate']),
          items: itemsJson.map((i) => InvoiceItemModel.fromJson(i)).toList(),
          discount: (m['discount'] as num).toDouble(),
          status: QuotationStatus.values.firstWhere((e) => e.name == m['status'], orElse: () => QuotationStatus.pending),
        );
      }).toList());
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> convertQuotationToInvoice(String quotationId) async {
    try {
      final db = await localDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query('quotations', where: 'id = ?', whereArgs: [quotationId]);
      if (maps.isEmpty) return Result.error(ServerFailure('Quotation not found'));
      
      final qMap = maps.first;
      final List<dynamic> itemsJson = jsonDecode(qMap['items']);
      final items = itemsJson.map((i) => InvoiceItemModel.fromJson(i)).toList();
      
      final invoice = SalesInvoice(
        id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        customerId: qMap['customerId'],
        customerName: qMap['customerName'],
        date: DateTime.now(),
        items: items,
        discount: (qMap['discount'] as num).toDouble(),
      );

      final result = await createInvoice(invoice);
      if (result.isSuccess) {
        await db.update('quotations', {'status': QuotationStatus.converted.name}, where: 'id = ?', whereArgs: [quotationId]);
        try {
          await sl.firebaseDb.updateData('quotations/$quotationId', {'status': QuotationStatus.converted.name});
        } catch (_) {}
      }
      return result;
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> processReturn(SalesReturn salesReturn) async {
    final db = await localDatabase.database;
    try {
      return await db.transaction((txn) async {
        final model = ReturnModel(
          id: salesReturn.id,
          originalInvoiceId: salesReturn.originalInvoiceId,
          customerId: salesReturn.customerId,
          customerName: salesReturn.customerName,
          date: salesReturn.date,
          items: salesReturn.items,
          reason: salesReturn.reason,
          grandTotal: salesReturn.grandTotal,
        );

        await txn.insert('returns', model.toJson()..['items'] = jsonEncode(model.toJson()['items']));

        for (var item in salesReturn.items) {
          final List<Map<String, dynamic>> results = await txn.query('inventory', where: 'sku = ?', whereArgs: [item.sku]);
          if (results.isNotEmpty) {
            final currentStock = (results.first['stock'] as num).toDouble();
            final newStock = currentStock + item.qty;
            await txn.update('inventory', {'stock': newStock, 'isLowStock': newStock < 10 ? 1 : 0}, where: 'sku = ?', whereArgs: [item.sku]);
            try {
              await sl.firebaseDb.updateData('inventory/${item.sku}', {'stock': newStock, 'isLowStock': newStock < 10});
            } catch (_) {}
          }
        }

        final List<Map<String, dynamic>> contactResults = await txn.query('contacts', where: 'id = ?', whereArgs: [salesReturn.customerId]);
        if (contactResults.isNotEmpty) {
          final currentBalance = (contactResults.first['balance'] as num).toDouble();
          final newBalance = currentBalance - salesReturn.grandTotal;
          await txn.update('contacts', {'balance': newBalance}, where: 'id = ?', whereArgs: [salesReturn.customerId]);
          try {
            await sl.firebaseDb.updateData('contacts/${salesReturn.customerId}', {'balance': newBalance});
          } catch (_) {}
        }

        try {
          await sl.firebaseDb.setData('returns/${salesReturn.id}', model.toJson());
          await sl.firebaseDb.pushData('activities', {
            'id': salesReturn.id,
            'title': 'Sales Return Processed',
            'subtitle': '${salesReturn.customerName} - Credit ₹${salesReturn.grandTotal.toStringAsFixed(0)}',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'type': 'stockAdjustment',
          });
        } catch (_) {}

        return Result.success(true);
      });
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SalesReturn>>> getReturns() async {
    try {
      final db = await localDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query('returns', orderBy: 'date DESC');
      return Result.success(maps.map((m) {
        final List<dynamic> itemsJson = jsonDecode(m['items']);
        return SalesReturn(
          id: m['id'],
          originalInvoiceId: m['originalInvoiceId'],
          customerId: m['customerId'],
          customerName: m['customerName'],
          date: DateTime.fromMillisecondsSinceEpoch(m['date']),
          items: itemsJson.map((i) => InvoiceItemModel.fromJson(i)).toList(),
          reason: m['reason'],
          grandTotal: (m['grandTotal'] as num).toDouble(),
        );
      }).toList());
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
