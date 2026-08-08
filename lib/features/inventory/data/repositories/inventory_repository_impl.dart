import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/database/local_database.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_data_source.dart';
import '../models/product_model.dart';
import '../models/warehouse_model.dart';
import '../models/stock_audit_model.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/entities/stock_audit.dart';
import '../../domain/entities/stock_transfer.dart';
import '../../../../core/services/firebase_database_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/config/app_config.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final LocalDatabase localDb;
  final FirebaseDatabaseService firebaseDb;
  final NotificationService notificationService;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDb,
    required this.firebaseDb,
    required this.notificationService,
  });

  @override
  Future<Result<List<Product>>> getProducts({String? category}) async {
    try {
      if (kIsWeb) {
        if (AppConfig.useFirebase) {
          final snapshot = await firebaseDb.getData('inventory');
          if (!snapshot.exists || snapshot.value == null) return Result.success([]);

          final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          final List<Product> products = [];
          data.forEach((key, value) {
            final product = ProductModel.fromJson(Map<String, dynamic>.from(value as Map)).toEntity();
            if (category == null || category == 'All Items' || product.category == category) {
              products.add(product);
            }
          });
          return Result.success(products);
        } else {
          final products = await remoteDataSource.getProducts(category: category);
          return Result.success(products);
        }
      }

      if (AppConfig.useFirebase) {
        final snapshot = await firebaseDb.getData('inventory');
        if (!snapshot.exists || snapshot.value == null) return Result.success([]);
        
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        final List<Product> products = [];
        data.forEach((key, value) {
          final product = ProductModel.fromJson(Map<String, dynamic>.from(value as Map)).toEntity();
          if (category == null || category == 'All Items' || product.category == category) {
            products.add(product);
          }
        });
        return Result.success(products);
      }

      final db = await localDb.database;
      
      // 1. Background refresh from Cloud (Firebase) - Real-time Source
      try {
        final snapshot = await firebaseDb.getData('inventory');
        if (snapshot.exists && snapshot.value != null) {
          final Map<dynamic, dynamic> cloudData = snapshot.value as Map<dynamic, dynamic>;
          cloudData.forEach((key, value) async {
            final productMap = Map<String, dynamic>.from(value as Map);
            final product = ProductModel.fromJson(productMap).toEntity();
            await _mirrorToLocalProduct(product, productMap['stocks']);
          });
        }
      } catch (e) {
        Log.w('Could not refresh inventory from Firebase: $e', name: 'Inventory');
        // Fallback to legacy remote refresh
        try {
          final remoteProducts = await remoteDataSource.getProducts(category: category);
          await _mirrorToLocalProductList(remoteProducts);
        } catch (_) {}
      }

      // 2. Return from Local DB
      final List<Map<String, dynamic>> maps = await db.query('inventory');
      final products = maps.map((m) => Product(
        sku: m['sku'],
        name: m['name'],
        category: m['category'],
        price: m['price'],
        stock: m['stock'],
        unit: m['unit'],
        isLowStock: m['isLowStock'] == 1,
        hsnCode: m['hsnCode'],
        lastUpdated: m['lastUpdated'] ?? 0,
      )).toList();

      if (category != null && category != 'All Items') {
        return Result.success(products.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList());
      }
      return Result.success(products);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product>> getProductBySku(String sku) async {
    try {
      if (kIsWeb) {
        final productsResult = await getProducts();
        return productsResult.fold(
          (failure) => Result.error(failure),
          (products) {
            final product = products.firstWhere((p) => p.sku == sku);
            return Result.success(product);
          },
        );
      }

      final db = await localDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'inventory',
        where: 'sku = ?',
        whereArgs: [sku],
      );

      if (maps.isNotEmpty) {
        final m = maps.first;
        return Result.success(Product(
          sku: m['sku'],
          name: m['name'],
          category: m['category'],
          price: m['price'],
          stock: m['stock'],
          unit: m['unit'],
          isLowStock: m['isLowStock'] == 1,
          hsnCode: m['hsnCode'],
          lastUpdated: m['lastUpdated'] ?? 0,
        ));
      }
      return Result.error(ServerFailure('Product not found locally'));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> createProduct(Product product) async {
    try {
      final model = ProductModel(
        name: product.name,
        sku: product.sku,
        category: product.category,
        price: product.price,
        stock: product.stock,
        unit: product.unit,
        isLowStock: product.isLowStock,
      );
      
      if (!kIsWeb) {
        final db = await localDb.database;
        // 1. Save locally
        await db.insert('inventory', _productToMap(product), conflictAlgorithm: ConflictAlgorithm.replace);
        
        // Initialize stock in Main Yard if it's a new product with stock
        if (product.stock != 0) {
          await localDb.updateStockLevel(product.sku, 'main_yard', product.stock);
        }
      }
      
      // 2. Push to Cloud (Firebase)
      try {
        await firebaseDb.setData('inventory/${product.sku}', model.toJson());
        if (product.stock != 0) {
           await firebaseDb.setData('inventory/${product.sku}/stocks/main_yard', product.stock);
        }
        
        // Record Activity
        await firebaseDb.pushData('activities', {
          'id': 'PROD-${product.sku}',
          'title': 'New Product Added',
          'subtitle': '${product.name} (${product.sku})',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'type': 'stockAdjustment',
        });
      } catch (e) {
        Log.w('Firebase push failed: $e', name: 'Inventory');
      }

      // 3. Attempt legacy remote
      try {
        await remoteDataSource.createProduct(product);
      } catch (e) {
        // 3. Queue for sync
        await localDb.addToSyncQueue(
          method: 'POST',
          path: '/products',
          body: model.toJson(),
        );
      }
      
      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> updateProduct(Product product) async {
    try {
      final model = ProductModel(
        name: product.name,
        sku: product.sku,
        category: product.category,
        price: product.price,
        stock: product.stock,
        unit: product.unit,
        isLowStock: product.isLowStock,
      );
      
      if (!kIsWeb) {
        final db = await localDb.database;
        // 1. Save locally
        await db.update(
          'inventory', 
          _productToMap(product), 
          where: 'sku = ?', 
          whereArgs: [product.sku],
        );
      }
      
      // 2. Push to Cloud (Firebase)
      try {
        await firebaseDb.updateData('inventory/${product.sku}', model.toJson());
        
        // Record Activity
        await firebaseDb.pushData('activities', {
          'id': 'UPDT-${product.sku}',
          'title': 'Product Updated',
          'subtitle': '${product.name} specifications modified',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'type': 'stockAdjustment',
        });
      } catch (e) {
        Log.w('Firebase update failed: $e', name: 'Inventory');
      }

      // 3. Attempt legacy remote
      try {
        await remoteDataSource.updateProduct(product);
      } catch (e) {
        // 3. Queue for sync
        await localDb.addToSyncQueue(
          method: 'PUT',
          path: '/products/${product.sku}',
          body: model.toJson(),
        );
      }
      
      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> deleteProduct(String sku) async {
    try {
      if (!kIsWeb) {
        final db = await localDb.database;
        // 1. Delete locally
        await db.delete('inventory', where: 'sku = ?', whereArgs: [sku]);
      }
      
      // 2. Delete from Cloud
      try {
        await firebaseDb.deleteData('inventory/$sku');
      } catch (e) {
        Log.w('Firebase delete failed: $e', name: 'Inventory');
      }

      // 3. Attempt legacy remote
      try {
        await remoteDataSource.deleteProduct(sku);
      } catch (e) {
        // 3. Queue for sync
        await localDb.addToSyncQueue(
          method: 'DELETE',
          path: '/products/$sku',
        );
      }
      
      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> adjustStock(String sku, String warehouseId, double quantity, {String? reason, String? notes}) async {
    try {
      if (kIsWeb) {
        await firebaseDb.updateData('inventory/$sku', {
          'stock': quantity,
        });
        return Result.success(true);
      }

      final db = await localDb.database;
      return await _adjustStockInternal(db, sku, warehouseId, quantity, reason: reason, notes: notes);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  Future<Result<bool>> _adjustStockInternal(DatabaseExecutor executor, String sku, String warehouseId, double quantity, {String? reason, String? notes}) async {
    // 1. Get current TOTAL stock
    final List<Map<String, dynamic>> results = await executor.query('inventory', where: 'sku = ?', whereArgs: [sku]);
    if (results.isEmpty) return Result.error(ServerFailure('Product not found'));

    final product = results.first;
    final currentTotalStock = (product['stock'] as num).toDouble();
    final newTotalStock = currentTotalStock + quantity;

    // 2. Update Local Tables
    await localDb.updateStockLevel(sku, warehouseId, quantity, executor: executor);

    await executor.update(
      'inventory',
      {
        'stock': newTotalStock,
        'isLowStock': newTotalStock < 10 ? 1 : 0,
      },
      where: 'sku = ?',
      whereArgs: [sku],
    );

    // 3. Record Movement (Audit Trail)
    await localDb.saveStockMovement({
      'id': 'MV-${DateTime.now().millisecondsSinceEpoch}',
      'productSku': sku,
      'productName': product['name'],
      'warehouseId': warehouseId,
      'quantity': quantity,
      'reason': reason ?? (quantity > 0 ? 'Adjustment (+)' : 'Adjustment (-)'),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'performedBy': 'System/Admin',
      'notes': notes,
    }, executor: executor);

    // 4. Trigger Notification if Low Stock (Post-Transaction/Best Effort)
    if (newTotalStock < 10) {
      notificationService.showLocalAlert(
        title: 'LOW STOCK ALERT',
        body: '${results.first['name']} is running low (${newTotalStock.toStringAsFixed(0)} items remaining)',
        path: '/inventory/$sku',
      );
    }

    // 5. Update Cloud (Firebase) - Post-Transaction/Best Effort
    _updateCloudStock(sku, newTotalStock, warehouseId, quantity);

    return Result.success(true);
  }

  void _updateCloudStock(String sku, double newTotalStock, String warehouseId, double quantity) async {
    try {
      final breakdownResult = await getStockBreakdown(sku);
      final breakdown = breakdownResult.getOrElse((_) => {});

      await firebaseDb.updateData('inventory/$sku', {
        'stock': newTotalStock,
        'isLowStock': newTotalStock < 10,
        'stocks': breakdown,
      });

      await firebaseDb.pushData('activities', {
        'id': 'ADJ-$sku-${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Stock Adjusted',
        'subtitle': '$sku quantity changed by ${quantity > 0 ? "+" : ""}$quantity in $warehouseId',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'type': 'stockAdjustment',
      });
    } catch (e) {
      Log.w('Firebase stock adjustment sync deferred: $e', name: 'Inventory');
    }
  }

  @override
  Future<Result<List<Warehouse>>> getWarehouses() async {
    try {
      if (kIsWeb) {
        // Return dummy warehouse for web
        return Result.success([
          Warehouse(id: 'main_yard', name: 'Main Yard (Mock)', location: 'Cloud Storage', isDefault: true),
        ]);
      }
      final maps = await localDb.getWarehouses();
      return Result.success(maps.map((m) => WarehouseModel.fromJson(m)).toList());
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> createWarehouse(Warehouse warehouse) async {
    try {
      final model = WarehouseModel.fromEntity(warehouse);
      
      // 1. Save locally
      await localDb.saveWarehouse(model.toJson());
      
      // 2. Push to Firebase
      try {
        await firebaseDb.setData('warehouses/${warehouse.id}', model.toJson());
      } catch (e) {
        Log.w('Firebase warehouse sync failed: $e', name: 'Inventory');
      }
      
      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, double>>> getStockBreakdown(String sku) async {
    try {
      if (kIsWeb) return Result.success({'main_yard': 0.0});
      final maps = await localDb.getStockLevels(sku);
      final Map<String, double> breakdown = {};
      for (var m in maps) {
        breakdown[m['warehouseId']] = (m['quantity'] as num).toDouble();
      }
      return Result.success(breakdown);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> transferStock(StockTransfer transfer) async {
    try {
      if (kIsWeb) return Result.success(true);

      final db = await localDb.database;
      
      await db.transaction((txn) async {
        // 1. Subtract from source
        final res1 = await _adjustStockInternal(txn, transfer.productSku, transfer.fromWarehouseId, -transfer.quantity, reason: 'Transfer Out', notes: 'To: ${transfer.toWarehouseId}');
        if (res1.isError) throw Exception(res1.failure?.message);

        // 2. Add to destination
        final res2 = await _adjustStockInternal(txn, transfer.productSku, transfer.toWarehouseId, transfer.quantity, reason: 'Transfer In', notes: 'From: ${transfer.fromWarehouseId}');
        if (res2.isError) throw Exception(res2.failure?.message);

        // 3. Record Movement Record
        await localDb.saveStockMovement({
          'id': transfer.id,
          'productSku': transfer.productSku,
          'productName': transfer.productName,
          'warehouseId': transfer.fromWarehouseId,
          'toWarehouseId': transfer.toWarehouseId,
          'quantity': transfer.quantity,
          'reason': 'Inter-Yard Transfer',
          'timestamp': transfer.timestamp.millisecondsSinceEpoch,
          'performedBy': transfer.performedBy,
          'notes': transfer.notes,
        }, executor: txn);
      });

      // 4. Record Activity (Cloud)
      await firebaseDb.pushData('activities', {
        'id': transfer.id,
        'title': 'Stock Transferred',
        'subtitle': '${transfer.productName}: ${transfer.fromWarehouseId} ➡️ ${transfer.toWarehouseId}',
        'timestamp': transfer.timestamp.millisecondsSinceEpoch,
        'type': 'stockAdjustment',
      });
      
      return Result.success(true);
    } catch (e) {
      Log.e('Stock Transfer Failed', error: e, name: 'Inventory');
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> createStockAudit(StockAudit audit) async {
    try {
      final model = StockAuditModel(
        id: audit.id,
        warehouseId: audit.warehouseId,
        timestamp: audit.timestamp,
        performedBy: audit.performedBy,
        items: audit.items,
        status: audit.status,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      if (!kIsWeb) {
        final List<Map<String, dynamic>> itemsJson = audit.items.map((i) => StockAuditItemModel.fromEntity(i).toJson()).toList();
        await localDb.stockAudit.saveStockAudit(model.toJson(), itemsJson);
      }

      // Push to Cloud
      try {
        await firebaseDb.setData('stock_audits/${audit.id}', model.toJson());
      } catch (e) {
        Log.w('Firebase stock audit sync failed: $e', name: 'Inventory');
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<StockAudit>>> getStockAudits() async {
    try {
      if (kIsWeb) {
        final snapshot = await firebaseDb.getData('stock_audits');
        if (!snapshot.exists || snapshot.value == null) return Result.success([]);
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        final List<StockAudit> audits = [];
        data.forEach((key, value) {
          audits.add(StockAuditModel.fromJson(Map<String, dynamic>.from(value as Map)));
        });
        return Result.success(audits);
      }

      final maps = await localDb.stockAudit.getStockAudits();
      return Result.success(maps.map((m) => StockAuditModel.fromJson(m)).toList());
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  // --- Helpers ---

  Future<void> _mirrorToLocalProductList(List<Product> products) async {
    if (kIsWeb) return;
    final db = await localDb.database;
    final batch = db.batch();
    for (var p in products) {
      batch.insert('inventory', _productToMap(p), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _mirrorToLocalProduct(Product p, dynamic stocksMap) async {
    if (kIsWeb) return;
    final db = await localDb.database;
    await db.insert('inventory', _productToMap(p), conflictAlgorithm: ConflictAlgorithm.replace);
    
    if (stocksMap != null && stocksMap is Map) {
      final stocks = Map<String, dynamic>.from(stocksMap);
      for (var entry in stocks.entries) {
        final warehouseId = entry.key;
        final qty = (entry.value as num).toDouble();
        
        await db.insert('stock_levels', {
          'productSku': p.sku,
          'warehouseId': warehouseId,
          'quantity': qty,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Map<String, dynamic> _productToMap(Product p) {
    return {
      'sku': p.sku,
      'name': p.name,
      'category': p.category,
      'price': p.price,
      'stock': p.stock,
      'unit': p.unit,
      'isLowStock': p.isLowStock ? 1 : 0,
      'hsnCode': p.hsnCode,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
