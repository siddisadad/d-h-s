import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/database/local_database.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_data_source.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;
  final LocalDatabase localDatabase;

  EmployeeRepositoryImpl({
    required this.remoteDataSource, 
    required this.localDatabase,
  });

  @override
  Future<Result<List<Employee>>> getEmployees() async {
    try {
      // 1. Background refresh
      _refreshEmployeesInBackground();

      // 2. Return from Local DB
      final maps = await localDatabase.getEmployees();
      final employees = maps.map((m) => Employee.fromMap(m)).toList();

      return Result.success(employees);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> updateAttendance(String id, String status) async {
    try {
      // 1. Update locally
      await localDatabase.updateEmployeeAttendance(id, status);

      // 2. Attempt remote
      try {
        await remoteDataSource.updateAttendance(id, status);
      } catch (e) {
        // 3. Queue for sync
        await localDatabase.addToSyncQueue(
          method: 'PATCH',
          path: '/employees/$id/attendance',
          body: {'status': status},
        );
        Log.w('OFFLINE: Attendance update queued for sync', name: 'Employees');
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> addEmployee(Employee employee) async {
    try {
      // 1. Save locally
      await localDatabase.saveEmployees([{
        ...employee.toMap(),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      }]);

      // 2. Attempt remote
      try {
        await remoteDataSource.addEmployee(employee);
      } catch (e) {
        // 3. Queue for sync
        await localDatabase.addToSyncQueue(
          method: 'POST',
          path: '/employees',
          body: employee.toMap(),
        );
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  Future<void> _refreshEmployeesInBackground() async {
    try {
      final remoteEmployees = await remoteDataSource.getEmployees();
      final maps = remoteEmployees.map((e) => {
        ...e.toMap(),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      }).toList();
      await localDatabase.saveEmployees(maps);
    } catch (e) {
      Log.w('Could not refresh employees: $e', name: 'Employees');
    }
  }
}
