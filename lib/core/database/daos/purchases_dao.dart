import 'package:sqflite/sqflite.dart';

class PurchasesDao {
  final Database db;
  PurchasesDao(this.db);

  Future<void> savePurchase(Map<String, dynamic> purchase) async {
    await db.insert('purchases', purchase, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getPurchases() async {
    return await db.query('purchases', orderBy: 'date DESC');
  }
}
