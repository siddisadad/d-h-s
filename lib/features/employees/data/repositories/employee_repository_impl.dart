import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_data_source.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<Employee>>> getEmployees() async {
    try {
      final employees = await remoteDataSource.getEmployees();
      return Result.success(employees);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> updateAttendance(String id, String status) async {
    try {
      final success = await remoteDataSource.updateAttendance(id, status);
      return Result.success(success);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
