import 'package:sqflite/sqflite.dart';

class ClosingDao {
  final Database db;
  ClosingDao(this.db);

  Future<void> saveClosing(Map<String, dynamic> closing) async {
    await db.insert('daily_closings', closing, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getClosings() async {
    return await db.query('daily_closings', orderBy: 'date DESC');
  }

  Future<Map<String, dynamic>?> getLastClosing() async {
    final results = await db.query('daily_closings', orderBy: 'date DESC', limit: 1);
    return results.isNotEmpty ? results.first : null;
  }
}
