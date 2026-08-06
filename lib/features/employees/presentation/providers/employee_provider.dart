import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../data/datasources/employee_remote_data_source.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

part 'employee_provider.g.dart';

@riverpod
EmployeeRepository employeeRepository(EmployeeRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  final firebaseDb = ref.watch(firebaseDatabaseServiceProvider);
  final localDb = ref.watch(localDatabaseProvider);

  return EmployeeRepositoryImpl(
    remoteDataSource: EmployeeRemoteDataSourceImpl(client),
    localDatabase: localDb,
    firebaseDb: firebaseDb,
  );
}

@riverpod
class EmployeeNotifier extends _$EmployeeNotifier {
  @override
  Future<List<Employee>> build() async {
    return _fetchFromApi();
  }

  Future<List<Employee>> _fetchFromApi() async {
    try {
      Log.d('Fetching employees from API...', name: 'Employees');
      final repository = ref.read(employeeRepositoryProvider);
      final result = await repository.getEmployees();

      return result.fold(
        (failure) {
          Log.e('Employees API Fetch Failed', error: failure.message, name: 'Employees');
          throw Exception(failure.message);
        },
        (employees) {
          Log.d('Employees API Fetch Complete', name: 'Employees');
          return employees;
        },
      );
    } catch (e, stack) {
      Log.e('Employee Provider Error', error: e, stackTrace: stack, name: 'Employees');
      rethrow;
    }
  }

  Future<void> updateAttendance(String id, String status) async {
    final repository = ref.read(employeeRepositoryProvider);
    final result = await repository.updateAttendance(id, status);
    
    result.fold(
      (failure) => Log.e('Failed to update attendance', error: failure.message, name: 'Employees'),
      (success) {
        ref.invalidateSelf();
      },
    );
  }

  Future<void> addEmployee(Employee employee) async {
    final repository = ref.read(employeeRepositoryProvider);
    final result = await repository.addEmployee(employee);
    
    result.fold(
      (failure) => Log.e('Failed to add employee', error: failure.message, name: 'Employees'),
      (success) {
        ref.invalidateSelf();
      },
    );
  }
}
