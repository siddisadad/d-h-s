import 'dart:convert';
import 'package:sqflite/sqflite.dart';

class SyncDao {
  final Database db;
  SyncDao(this.db);

  Future<void> addToSyncQueue({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    await db.insert('sync_queue', {
      'method': method,
      'path': path,
      'body': body != null ? jsonEncode(body) : null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    return await db.query('sync_queue', orderBy: 'timestamp ASC');
  }

  Future<void> removeFromSyncQueue(int id) async {
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }
}
