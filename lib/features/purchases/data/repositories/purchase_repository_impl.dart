import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/database/local_database.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_remote_data_source.dart';
import '../models/purchase_model.dart';
import '../../../../core/services/firebase_database_service.dart';
import '../../../../core/config/app_config.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseRemoteDataSource remoteDataSource;
  final LocalDatabase localDatabase;
  final FirebaseDatabaseService firebaseDb;

  PurchaseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatabase,
    required this.firebaseDb,
  });

  @override
  Future<Result<List<PurchaseOrder>>> getRecentPurchases() async {
    try {
      if (kIsWeb) {
        if (AppConfig.useFirebase) {
          final snapshot = await firebaseDb.getData('purchases');
          if (!snapshot.exists || snapshot.value == null) return Result.success([]);
          
          final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          final List<PurchaseOrder> purchases = [];
          data.forEach((key, value) {
            purchases.add(PurchaseModel.fromJson(Map<String, dynamic>.from(value as Map)));
          });
          return Result.success(purchases);
        }
        final remote = await remoteDataSource.getRecentPurchases();
        return Result.success(remote);
      }
      
      // 1. Background refresh from Firebase if enabled
      if (AppConfig.useFirebase) {
        _refreshPurchasesFromFirebase();
      } else {
        _refreshPurchasesInBackground();
      }

      final db = await localDatabase.database;
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
      if (kIsWeb) {
        // Only Cloud Operations on Web
        try {
          final model = PurchaseModel(
            id: purchase.id,
            supplierId: purchase.supplierId,
            supplierName: purchase.supplierName,
            date: purchase.date,
            items: purchase.items,
            discount: purchase.discount,
            status: purchase.status,
            lastUpdated: DateTime.now().millisecondsSinceEpoch,
          );
          await firebaseDb.setData('purchases/${purchase.id}', model.toJson());
          await firebaseDb.pushData('activities', {
            'id': purchase.id,
            'title': 'New Purchase Recorded (Web)',
            'subtitle': '${purchase.supplierName} - ₹${purchase.grandTotal.toStringAsFixed(0)}',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'type': 'purchase',
          });
        } catch (_) {}
        return Result.success(true);
      }
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
          lastUpdated: DateTime.now().millisecondsSinceEpoch,
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

            final Map<String, dynamic> updateMap = {
              'stock': newStock,
              'costPrice': item.costPrice,
              'isLowStock': newStock < 10 ? 1 : 0,
            };
            if (item.hsnCode != null) {
              updateMap['hsnCode'] = item.hsnCode!;
            }

            await txn.update('inventory', updateMap, where: 'sku = ?', whereArgs: [item.sku]);
            await localDatabase.updateStockLevel(item.sku, 'main_yard', item.qty);

            // Record Movement Record
            await localDatabase.saveStockMovement({
              'id': 'PUR-${purchase.id}-${item.sku}',
              'productSku': item.sku,
              'productName': item.name,
              'warehouseId': 'main_yard',
              'quantity': item.qty,
              'reason': 'Purchase (GRN #${purchase.id})',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'performedBy': 'System',
            });
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
          await firebaseDb.setData('purchases/${purchase.id}', model.toJson());
          await firebaseDb.updateData('contacts/${purchase.supplierId}', {'balance': newBalance});
          
          // Sync Ledger to Firebase
          await firebaseDb.setData('ledgers/${purchase.supplierId}/${purchase.id}', {
            'date': purchase.date.toIso8601String(),
            'type': 'Purchase',
            'amount': purchase.grandTotal,
            'balance': newBalance,
            'isDebit': false,
          });

          await firebaseDb.pushData('activities', {
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
    if (kIsWeb) return;
    try {
      final remote = await remoteDataSource.getRecentPurchases();
      final db = await localDatabase.database;
      final batch = db.batch();
      for (var p in remote) {
        final model = PurchaseModel(
          id: p.id,
          supplierId: p.supplierId,
          supplierName: p.supplierName,
          date: p.date,
          items: p.items,
          discount: p.discount,
          status: p.status,
          lastUpdated: DateTime.now().millisecondsSinceEpoch,
        );
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

  Future<void> _refreshPurchasesFromFirebase() async {
    try {
      final snapshot = await firebaseDb.getData('purchases');
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        for (var value in data.values) {
          final Map<String, dynamic> purMap = Map<String, dynamic>.from(value as Map);
          final model = PurchaseModel.fromJson(purMap);
          await localDatabase.savePurchase({
            'id': model.id,
            'supplierId': model.supplierId,
            'supplierName': model.supplierName,
            'date': model.date.millisecondsSinceEpoch,
            'discount': model.discount,
            'totalAmount': model.grandTotal,
            'status': model.status,
            'items': jsonEncode(purMap['items']),
          });
        }
      }
    } catch (e) {
      Log.w('Could not refresh purchases from Firebase: $e', name: 'Purchases');
    }
  }
}
