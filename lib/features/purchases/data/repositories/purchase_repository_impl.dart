import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/database/local_database.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_remote_data_source.dart';
import '../models/purchase_model.dart';
import '../../../../core/di/injection_container.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseRemoteDataSource remoteDataSource;
  final LocalDatabase localDatabase;

  PurchaseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatabase,
  });

  @override
  Future<Result<List<PurchaseOrder>>> getRecentPurchases() async {
    try {
      final db = await localDatabase.database;
      _refreshPurchasesInBackground();

      final List<Map<String, dynamic>> maps = await db.query('purchases', orderBy: 'date DESC');
      final purchases = maps.map((m) {
        final List<dynamic> itemsJson = jsonDecode(m['items']);
        return PurchaseOrder(
          id: m['id'],
          supplierId: m['supplierId'],
          supplierName: m['supplierName'],
          date: DateTime.fromMillisecondsSinceEpoch(m['date']),
          items: itemsJson.map((i) => PurchaseItemModel.fromJson(i)).toList(),
          discount: (m['discount'] as num).toDouble(),
          status: m['status'],
        );
      }).toList();

      return Result.success(purchases);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> createPurchase(PurchaseOrder purchase) async {
    try {
      final db = await localDatabase.database;
      return await db.transaction((txn) async {
        final model = PurchaseModel(
          id: purchase.id,
          supplierId: purchase.supplierId,
          supplierName: purchase.supplierName,
          date: purchase.date,
          items: purchase.items,
          discount: purchase.discount,
          status: purchase.status,
        );

        // 1. Save locally
        await txn.insert('purchases', {
          'id': model.id,
          'supplierId': model.supplierId,
          'supplierName': model.supplierName,
          'date': model.date.millisecondsSinceEpoch,
          'discount': model.discount,
          'totalAmount': model.grandTotal,
          'status': model.status,
          'items': jsonEncode(model.toJson()['items']),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // 2. Stock Increment
        for (var item in purchase.items) {
          final List<Map<String, dynamic>> results = await txn.query('inventory', where: 'sku = ?', whereArgs: [item.sku]);
          if (results.isNotEmpty) {
            final product = results.first;
            final currentStock = (product['stock'] as num).toDouble();
            final newStock = currentStock + item.qty;
            await txn.update('inventory', {'stock': newStock, 'isLowStock': newStock < 10 ? 1 : 0}, where: 'sku = ?', whereArgs: [item.sku]);
            await localDatabase.updateStockLevel(item.sku, 'main_yard', item.qty);
          }
        }

        // 3. Update Ledger & Balance
        final List<Map<String, dynamic>> supplierResults = await txn.query('contacts', where: 'id = ?', whereArgs: [purchase.supplierId]);
        double newBalance = purchase.grandTotal;
        if (supplierResults.isNotEmpty) {
          final supplier = supplierResults.first;
          final currentBalance = (supplier['balance'] as num).toDouble();
          newBalance = currentBalance - purchase.grandTotal;
          await txn.update('contacts', {'balance': newBalance}, where: 'id = ?', whereArgs: [purchase.supplierId]);
        }

        await txn.insert('ledgers', {
          'contactId': purchase.supplierId,
          'date': purchase.date.millisecondsSinceEpoch,
          'type': 'Purchase',
          'ref': purchase.id,
          'amount': purchase.grandTotal,
          'balanceAfter': newBalance,
          'isDebit': 0,
        });

        // 4. Push to Cloud (Firebase)
        try {
          await sl.firebaseDb.setData('purchases/${purchase.id}', model.toJson());
          await sl.firebaseDb.updateData('contacts/${purchase.supplierId}', {'balance': newBalance});
          await sl.firebaseDb.pushData('activities', {
            'id': purchase.id,
            'title': 'New Purchase Recorded',
            'subtitle': '${purchase.supplierName} - ₹${purchase.grandTotal.toStringAsFixed(0)}',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'type': 'purchase',
          });
        } catch (e) { Log.w('Firebase sync failed: $e', name: 'Purchases'); }

        return Result.success(true);
      });
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  Future<void> _refreshPurchasesInBackground() async {
    try {
      final remote = await remoteDataSource.getRecentPurchases();
      final db = await localDatabase.database;
      final batch = db.batch();
      for (var p in remote) {
        final model = PurchaseModel(id: p.id, supplierId: p.supplierId, supplierName: p.supplierName, date: p.date, items: p.items, discount: p.discount, status: p.status);
        batch.insert('purchases', {
          'id': model.id,
          'supplierId': model.supplierId,
          'supplierName': model.supplierName,
          'date': model.date.millisecondsSinceEpoch,
          'discount': model.discount,
          'totalAmount': model.grandTotal,
          'status': model.status,
          'items': jsonEncode(model.toJson()['items']),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (e) { Log.w('Purchase refresh failed: $e'); }
  }
}
