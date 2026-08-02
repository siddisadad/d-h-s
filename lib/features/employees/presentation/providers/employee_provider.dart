import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/employee.dart';
import '../../../../core/di/injection_container.dart';

part 'employee_provider.g.dart';

@riverpod
class EmployeeNotifier extends _$EmployeeNotifier {
  @override
  Future<List<Employee>> build() async {
    return _fetchFromApi();
  }

  Future<List<Employee>> _fetchFromApi() async {
    try {
      debugPrint('🌐 [Employees] Fetching from API...');
      final repository = sl.employeeRepository;
      final result = await repository.getEmployees();

      return result.fold(
        (failure) {
          debugPrint('❌ [Employees] API Fetch Failed: ${failure.message}');
          throw Exception(failure.message);
        },
        (employees) {
          debugPrint('✅ [Employees] API Fetch Complete');
          return employees;
        },
      );
    } catch (e) {
      debugPrint('⚠️ [Employees] Error: $e');
      rethrow;
    }
  }

  Future<void> updateAttendance(String id, String status) async {
    final repository = sl.employeeRepository;
    final result = await repository.updateAttendance(id, status);
    
    result.fold(
      (failure) => debugPrint('❌ [Employees] Failed to update attendance: ${failure.message}'),
      (success) {
        ref.invalidateSelf();
      },
    );
  }

  Future<void> addEmployee(Employee employee) async {
    // Note: In real implementation, should call POST /employees
    debugPrint('👷 [Employees] Add Employee: ${employee.name}');
    ref.invalidateSelf();
  }
}
