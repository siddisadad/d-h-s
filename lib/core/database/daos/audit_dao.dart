import 'package:sqflite/sqflite.dart';

class AuditDao {
  final Database db;
  AuditDao(this.db);

  Future<void> logActivity({
    required String id,
    required String title,
    required String subtitle,
    required int timestamp,
    required String type,
    String? metadata,
  }) async {
    await db.insert(
      'audit_logs',
      {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'timestamp': timestamp,
        'type': type,
        'metadata': metadata,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50}) async {
    return await db.query(
      'audit_logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }
}
