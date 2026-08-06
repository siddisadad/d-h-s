import 'package:sqflite/sqflite.dart';

class FinanceDao {
  final Database db;
  FinanceDao(this.db);

  Future<void> saveFinanceEntry(Map<String, dynamic> entry) async {
    await db.insert('finance_entries', entry, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFinanceEntries() async {
    return await db.query('finance_entries', orderBy: 'date DESC');
  }
}
