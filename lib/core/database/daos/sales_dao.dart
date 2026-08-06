import 'package:sqflite/sqflite.dart';

class SalesDao {
  final Database db;
  SalesDao(this.db);

  Future<void> saveInvoice(Map<String, dynamic> invoice) async {
    await db.insert('sales', invoice, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    return await db.query('sales', orderBy: 'date DESC');
  }

  Future<void> saveQuotation(Map<String, dynamic> quotation) async {
    await db.insert('quotations', quotation, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getQuotations() async {
    return await db.query('quotations', orderBy: 'date DESC');
  }

  Future<void> saveReturn(Map<String, dynamic> salesReturn) async {
    await db.insert('returns', salesReturn, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getReturns() async {
    return await db.query('returns', orderBy: 'date DESC');
  }
}
