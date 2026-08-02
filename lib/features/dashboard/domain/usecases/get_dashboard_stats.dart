import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStats implements UseCase<DashboardStats, NoParams> {
  final DashboardRepository repository;

  GetDashboardStats(this.repository);

  @override
  Future<Result<DashboardStats>> call(NoParams params) async {
    return await repository.getStats();
  }
}
