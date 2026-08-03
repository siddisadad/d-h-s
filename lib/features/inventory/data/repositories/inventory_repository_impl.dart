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
import '../../domain/entities/warehouse.dart';
import '../../domain/entities/stock_transfer.dart';
import '../../../../core/di/injection_container.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final LocalDatabase localDb;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDb,
  });

  @override
  Future<Result<List<Product>>> getProducts({String? category}) async {
    try {
      final db = await localDb.database;
      
      // 1. Background refresh from Cloud (Firebase) - Real-time Source
      try {
        final snapshot = await sl.firebaseDb.getData('inventory');
        if (snapshot.exists && snapshot.value != null) {
          final Map<dynamic, dynamic> cloudData = snapshot.value as Map<dynamic, dynamic>;
          final List<Product> cloudProducts = [];
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
      final db = await localDb.database;
      final model = ProductModel(
        name: product.name,
        sku: product.sku,
        category: product.category,
        price: product.price,
        stock: product.stock,
        unit: product.unit,
        isLowStock: product.isLowStock,
      );
      
      // 1. Save locally
      await db.insert('inventory', _productToMap(product), conflictAlgorithm: ConflictAlgorithm.replace);
      
      // Initialize stock in Main Yard if it's a new product with stock
      if (product.stock != 0) {
        await localDb.updateStockLevel(product.sku, 'main_yard', product.stock);
      }
      
      // 2. Push to Cloud (Firebase)
      try {
        await sl.firebaseDb.setData('inventory/${product.sku}', model.toJson());
        if (product.stock != 0) {
           await sl.firebaseDb.setData('inventory/${product.sku}/stocks/main_yard', product.stock);
        }
        
        // Record Activity
        await sl.firebaseDb.pushData('activities', {
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
      final db = await localDb.database;
      final model = ProductModel(
        name: product.name,
        sku: product.sku,
        category: product.category,
        price: product.price,
        stock: product.stock,
        unit: product.unit,
        isLowStock: product.isLowStock,
      );
      
      // 1. Save locally
      await db.update(
        'inventory', 
        _productToMap(product), 
        where: 'sku = ?', 
        whereArgs: [product.sku],
      );
      
      // 2. Push to Cloud (Firebase)
      try {
        await sl.firebaseDb.updateData('inventory/${product.sku}', model.toJson());
        
        // Record Activity
        await sl.firebaseDb.pushData('activities', {
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
      final db = await localDb.database;
      
      // 1. Delete locally
      await db.delete('inventory', where: 'sku = ?', whereArgs: [sku]);
      
      // 2. Delete from Cloud
      try {
        await sl.firebaseDb.deleteData('inventory/$sku');
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
  Future<Result<bool>> adjustStock(String sku, String warehouseId, double quantity) async {
    try {
      final db = await localDb.database;
      
      // 1. Get current TOTAL stock
      final List<Map<String, dynamic>> results = await db.query('inventory', where: 'sku = ?', whereArgs: [sku]);
      if (results.isEmpty) return Result.error(ServerFailure('Product not found'));
      
      final currentTotalStock = (results.first['stock'] as num).toDouble();
      final newTotalStock = currentTotalStock + quantity;
      
      // 2. Update Local Tables (Transactional via localDb helpers or direct)
      await localDb.updateStockLevel(sku, warehouseId, quantity);
      
      await db.update(
        'inventory',
        {
          'stock': newTotalStock,
          'isLowStock': newTotalStock < 10 ? 1 : 0,
        },
        where: 'sku = ?',
        whereArgs: [sku],
      );

      // 3. Update Cloud (Firebase)
      try {
        // Fetch current per-warehouse stock from Firebase to be safe, or just update delta if using increments
        // For simplicity with setData/updateData, we'll try to get latest from DB and set
        final breakdownResult = await getStockBreakdown(sku);
        final breakdown = breakdownResult.getOrElse((_) => {});

        await sl.firebaseDb.updateData('inventory/$sku', {
          'stock': newTotalStock,
          'isLowStock': newTotalStock < 10,
          'stocks': breakdown,
        });

        // Record Activity
        await sl.firebaseDb.pushData('activities', {
          'id': 'ADJ-$sku-${DateTime.now().millisecondsSinceEpoch}',
          'title': 'Stock Adjusted',
          'subtitle': '$sku quantity changed by ${quantity > 0 ? "+" : ""}$quantity in $warehouseId',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'type': 'stockAdjustment',
        });
      } catch (e) {
        Log.w('Firebase stock adjustment failed: $e', name: 'Inventory');
      }
      
      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Warehouse>>> getWarehouses() async {
    try {
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
        await sl.firebaseDb.setData('warehouses/${warehouse.id}', model.toJson());
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
      // 1. Subtract from source
      await adjustStock(transfer.productSku, transfer.fromWarehouseId, -transfer.quantity);
      // 2. Add to destination
      await adjustStock(transfer.productSku, transfer.toWarehouseId, transfer.quantity);
      
      // 3. Record Activity
      await sl.firebaseDb.pushData('activities', {
        'id': transfer.id,
        'title': 'Stock Transferred',
        'subtitle': '${transfer.productName}: ${transfer.fromWarehouseId} ➡️ ${transfer.toWarehouseId}',
        'timestamp': transfer.timestamp.millisecondsSinceEpoch,
        'type': 'stockAdjustment',
      });
      
      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  // --- Helpers ---

  Future<void> _mirrorToLocalProductList(List<Product> products) async {
    final db = await localDb.database;
    final batch = db.batch();
    for (var p in products) {
      batch.insert('inventory', _productToMap(p), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _mirrorToLocalProduct(Product p, dynamic stocksMap) async {
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
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
