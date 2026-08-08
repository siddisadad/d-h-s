import 'package:sqflite/sqflite.dart';
import '../../../features/inventory/data/models/stock_audit_model.dart';

class StockAuditDao {
  final Database db;
  StockAuditDao(this.db);

  Future<void> saveStockAudit(Map<String, dynamic> audit, List<Map<String, dynamic>> items) async {
    await db.transaction((txn) async {
      await txn.insert('stock_audits', audit, conflictAlgorithm: ConflictAlgorithm.replace);

      // Delete old items if updating
      await txn.delete('stock_audit_items', where: 'auditId = ?', whereArgs: [audit['id']]);

      for (var item in items) {
        await txn.insert('stock_audit_items', {
          ...item,
          'auditId': audit['id'],
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> getStockAudits() async {
    final List<Map<String, dynamic>> audits = await db.query('stock_audits', orderBy: 'timestamp DESC');
    final List<Map<String, dynamic>> results = [];

    for (var audit in audits) {
      final List<Map<String, dynamic>> items = await db.query(
        'stock_audit_items',
        where: 'auditId = ?',
        whereArgs: [audit['id']],
      );
      results.add({
        ...audit,
        'items': items,
      });
    }
    return results;
  }
}
