import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<DashboardStats>> getStats() async {
    try {
      final stats = await remoteDataSource.getStats();
      return Result.success(stats);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<double>>> getRevenueTrend() async {
    try {
      final trend = await remoteDataSource.getRevenueTrend();
      return Result.success(trend);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
