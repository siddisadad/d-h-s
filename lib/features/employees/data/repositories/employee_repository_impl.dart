import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/database/local_database.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_data_source.dart';
import '../models/employee_model.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/firebase_database_service.dart';
import 'package:flutter/foundation.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;
  final LocalDatabase localDatabase;
  final FirebaseDatabaseService firebaseDb;

  EmployeeRepositoryImpl({
    required this.remoteDataSource, 
    required this.localDatabase,
    required this.firebaseDb,
  });

  @override
  Future<Result<List<Employee>>> getEmployees() async {
    try {
      if (kIsWeb) {
        if (AppConfig.useFirebase) {
          final snapshot = await firebaseDb.getData('employees');
          if (!snapshot.exists || snapshot.value == null) return Result.success([]);
          
          final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          final List<Employee> employees = [];
          data.forEach((key, value) {
            employees.add(EmployeeModel.fromJson(Map<String, dynamic>.from(value as Map)));
          });
          return Result.success(employees);
        }
        final remoteEmployees = await remoteDataSource.getEmployees();
        return Result.success(remoteEmployees);
      }

      // 1. Background refresh from Firebase if enabled
      if (AppConfig.useFirebase) {
        _refreshEmployeesFromFirebase();
      } else {
        _refreshEmployeesInBackground();
      }

      // 2. Return from Local DB
      final maps = await localDatabase.getEmployees();
      final employees = maps.map((m) => Employee.fromMap(m)).toList();

      return Result.success(employees);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  Future<void> _refreshEmployeesFromFirebase() async {
    try {
      final snapshot = await firebaseDb.getData('employees');
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> maps = [];
        data.forEach((key, value) {
          final employee = EmployeeModel.fromJson(Map<String, dynamic>.from(value as Map));
          maps.add({
            ...employee.toMap(),
            'lastUpdated': DateTime.now().millisecondsSinceEpoch,
          });
        });
        await localDatabase.saveEmployees(maps);
      }
    } catch (e) {
      Log.w('Could not refresh employees from Firebase: $e', name: 'Employees');
    }
  }

  @override
  Future<Result<bool>> updateAttendance(String id, String status) async {
    try {
      if (kIsWeb) {
        if (AppConfig.useFirebase) {
          await firebaseDb.updateData('employees/$id', {'attendanceStatus': status});
        }
        await remoteDataSource.updateAttendance(id, status);
        return Result.success(true);
      }

      // 1. Update locally
      await localDatabase.updateEmployeeAttendance(id, status);

      // 2. Push to Cloud (Firebase)
      if (AppConfig.useFirebase) {
        try {
          await firebaseDb.updateData('employees/$id', {'attendanceStatus': status});
          
          // Record Activity
          await firebaseDb.pushData('activities', {
            'id': 'ATT-$id-${DateTime.now().millisecondsSinceEpoch}',
            'title': 'Attendance Updated',
            'subtitle': 'Employee $id marked as $status',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'type': 'userLogin', // Reusing type for UI icon
          });
        } catch (e) {
          Log.w('Firebase attendance update failed: $e', name: 'Employees');
        }
      }

      // 3. Attempt legacy remote
      try {
        await remoteDataSource.updateAttendance(id, status);
      } catch (e) {
        // 4. Queue for sync
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
      final model = EmployeeModel(
        id: employee.id,
        name: employee.name,
        role: employee.role,
        email: employee.email,
        phone: employee.phone,
        salary: employee.salary,
        attendanceStatus: employee.attendanceStatus,
      );

      if (kIsWeb) {
        if (AppConfig.useFirebase) {
          await firebaseDb.setData('employees/${employee.id}', model.toJson());
        }
        await remoteDataSource.addEmployee(employee);
        return Result.success(true);
      }

      // 1. Save locally
      await localDatabase.saveEmployees([{
        ...employee.toMap(),
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      }]);

      // 2. Push to Cloud (Firebase)
      if (AppConfig.useFirebase) {
        try {
          await firebaseDb.setData('employees/${employee.id}', model.toJson());
          
          // Record Activity
          await firebaseDb.pushData('activities', {
            'id': 'EMP-${employee.id}',
            'title': 'New Employee Added',
            'subtitle': '${employee.name} (${employee.role})',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'type': 'userLogin',
          });
        } catch (e) {
          Log.w('Firebase employee add failed: $e', name: 'Employees');
        }
      }

      // 3. Attempt legacy remote
      try {
        await remoteDataSource.addEmployee(employee);
      } catch (e) {
        // 4. Queue for sync
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
    if (kIsWeb) return;
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
