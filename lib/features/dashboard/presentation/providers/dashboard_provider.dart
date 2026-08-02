import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/logger.dart';

part 'dashboard_provider.g.dart';

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) => sl.dashboardRepository;

@riverpod
GetDashboardStats getDashboardStatsUseCase(GetDashboardStatsUseCaseRef ref) => sl.getStatsUseCase;

@riverpod
class DashboardStatsNotifier extends _$DashboardStatsNotifier {
  @override
  Future<DashboardStats?> build() async {
    return _fetchStats();
  }

  Future<DashboardStats?> _fetchStats() async {
    final useCase = ref.read(getDashboardStatsUseCaseProvider);
    
    final result = await useCase(NoParams());
    
    return result.fold(
      (failure) {
        Log.e('Dashboard Stats Fetch Failed', error: failure.message, name: 'Dashboard');
        throw Exception(failure.message);
      },
      (stats) => stats,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}
