import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/employee.dart';
import '../models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<Employee>> getEmployees();
  Future<bool> updateAttendance(String id, String status);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final ApiClient _client;

  EmployeeRemoteDataSourceImpl(this._client);

  @override
  Future<List<Employee>> getEmployees() async {
    try {
      final response = await _client.dio.get('/employees');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => EmployeeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      debugPrint('⚠️ [Employee API] Fetch Failed: $e');
      if (kDebugMode) return _mockEmployees;
      rethrow;
    }
  }

  @override
  Future<bool> updateAttendance(String id, String status) async {
    try {
      final response = await _client.dio.patch('/employees/$id/attendance', data: {'status': status});
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [Employee API] Attendance Update Failed: $e');
      if (kDebugMode) return true;
      rethrow;
    }
  }

  final List<Employee> _mockEmployees = [
    Employee(id: 'E001', name: 'Rahul Sharma', role: 'Sales Manager', email: 'rahul@dhs.com', phone: '9876543210', salary: '45,000'),
    Employee(id: 'E002', name: 'Priya Patel', role: 'Inventory Specialist', email: 'priya@dhs.com', phone: '9876543211', salary: '35,000'),
    Employee(id: 'E003', name: 'Amit Kumar', role: 'Warehouse Operative', email: 'amit@dhs.com', phone: '9876543212', salary: '25,000'),
  ];
}

class EmployeeMockDataSourceImpl implements EmployeeRemoteDataSource {
  final List<Employee> _mockEmployees = [
    Employee(id: 'E001', name: 'Rahul Sharma', role: 'Sales Manager', email: 'rahul@dhs.com', phone: '9876543210', salary: '45,000'),
    Employee(id: 'E002', name: 'Priya Patel', role: 'Inventory Specialist', email: 'priya@dhs.com', phone: '9876543211', salary: '35,000'),
  ];

  @override
  Future<List<Employee>> getEmployees() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockEmployees;
  }

  @override
  Future<bool> updateAttendance(String id, String status) async => true;
}
