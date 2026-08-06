import 'package:sqflite/sqflite.dart';

class EmployeeDao {
  final Database db;
  EmployeeDao(this.db);

  Future<void> saveEmployees(List<Map<String, dynamic>> employees) async {
    final batch = db.batch();
    for (var emp in employees) {
      batch.insert('employees', emp, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getEmployees() async {
    return await db.query('employees', orderBy: 'name ASC');
  }

  Future<void> updateEmployeeAttendance(String id, String status) async {
    await db.update('employees', {'attendanceStatus': status}, where: 'id = ?', whereArgs: [id]);
  }
}
