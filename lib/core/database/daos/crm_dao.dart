import 'package:sqflite/sqflite.dart';

class CrmDao {
  final Database db;
  CrmDao(this.db);

  Future<void> saveContacts(List<Map<String, dynamic>> contacts) async {
    final batch = db.batch();
    for (var contact in contacts) {
      batch.insert('contacts', contact, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getContacts(String type) async {
    return await db.query('contacts', where: 'type = ?', whereArgs: [type], orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getLedgerByContactId(String contactId) async {
    return await db.query('ledgers', where: 'contactId = ?', whereArgs: [contactId], orderBy: 'date DESC');
  }
}
