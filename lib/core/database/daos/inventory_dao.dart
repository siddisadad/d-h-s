import 'package:sqflite/sqflite.dart';

class InventoryDao {
  final Database db;
  InventoryDao(this.db);

  Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    final batch = db.batch();
    for (var product in products) {
      batch.insert('inventory', product, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    return await db.query('inventory', orderBy: 'name ASC');
  }

  Future<void> deleteProduct(String sku) async {
    await db.delete('inventory', where: 'sku = ?', whereArgs: [sku]);
  }

  Future<List<Map<String, dynamic>>> getStockLevels(String sku) async {
    return await db.query('stock_levels', where: 'productSku = ?', whereArgs: [sku]);
  }

  Future<void> updateStockLevel(String sku, String warehouseId, double delta) async {
    await db.transaction((txn) async {
      final results = await txn.query(
        'stock_levels',
        where: 'productSku = ? AND warehouseId = ?',
        whereArgs: [sku, warehouseId],
      );

      if (results.isEmpty) {
        await txn.insert('stock_levels', {
          'productSku': sku,
          'warehouseId': warehouseId,
          'quantity': delta,
        });
      } else {
        final current = (results.first['quantity'] as num).toDouble();
        await txn.update(
          'stock_levels',
          {'quantity': current + delta},
          where: 'productSku = ? AND warehouseId = ?',
          whereArgs: [sku, warehouseId],
        );
      }
    });
  }

  Future<void> saveStockMovement(Map<String, dynamic> movement) async {
    await db.insert('stock_movements', movement, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getStockMovements(String sku) async {
    return await db.query('stock_movements', where: 'productSku = ?', whereArgs: [sku], orderBy: 'timestamp DESC');
  }

  Future<List<Map<String, dynamic>>> getAllStockMovements() async {
    return await db.query('stock_movements', orderBy: 'timestamp DESC');
  }
}
