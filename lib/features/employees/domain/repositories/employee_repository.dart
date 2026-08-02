import '../../../../core/error/result.dart';
import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<Result<List<Employee>>> getEmployees();
  Future<Result<bool>> updateAttendance(String id, String status);
}
