import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/logger.dart';
import '../../../../features/sales/presentation/providers/sales_history_provider.dart';
import '../../../../features/inventory/presentation/providers/inventory_provider.dart';
import 'package:intl/intl.dart';
import '../../../../features/purchases/presentation/providers/purchase_history_provider.dart';

part 'dashboard_provider.g.dart';

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) => sl.dashboardRepository;

@riverpod
GetDashboardStats getDashboardStatsUseCase(GetDashboardStatsUseCaseRef ref) => sl.getStatsUseCase;



@riverpod
class DashboardStatsNotifier extends _$DashboardStatsNotifier {
  @override
  Future<DashboardStats?> build() async {
    final salesAsync = ref.watch(salesHistoryProvider);
    final purchasesAsync = ref.watch(purchaseHistoryProvider);
    final inventoryAsync = ref.watch(inventoryNotifierProvider);

    if (salesAsync is AsyncData && purchasesAsync is AsyncData && inventoryAsync is AsyncData) {
      final sales = salesAsync.value!;
      final purchases = purchasesAsync.value!;
      final products = inventoryAsync.value!;

      final today = DateTime.now();
      
      final todaySales = sales.where((s) => 
        s.date.year == today.year && 
        s.date.month == today.month && 
        s.date.day == today.day
      ).fold(0.0, (sum, s) => sum + s.grandTotal);

      final todayPurchases = purchases.where((p) => 
        p.date.year == today.year && 
        p.date.month == today.month && 
        p.date.day == today.day
      ).fold(0.0, (sum, p) => sum + p.grandTotal);

      final totalRevenue = sales.fold(0.0, (sum, s) => sum + s.grandTotal);
      final lowStockCount = products.where((p) => p.isLowStock || p.stock < 10).length;

      final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

      return DashboardStats(
        sales: formatter.format(todaySales),
        purchases: formatter.format(todayPurchases),
        collections: formatter.format(totalRevenue),
        lowStock: '$lowStockCount Items',
      );
    }

    return _fetchStats();
  }

  Future<DashboardStats?> _fetchStats() async {
    final useCase = ref.read(getDashboardStatsUseCaseProvider);
    
    final result = await useCase(NoParams());
    
    return result.fold(
      (failure) {
        Log.e('Dashboard Stats Fetch Failed', error: failure.message, name: 'Dashboard');
        return null;
      },
      (stats) => stats,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidate(salesHistoryProvider);
    ref.invalidate(inventoryNotifierProvider);
    state = await AsyncValue.guard(() => _fetchStats());
  }
}
