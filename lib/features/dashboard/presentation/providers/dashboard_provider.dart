import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../../../features/sales/presentation/providers/sales_history_provider.dart';
import '../../../../features/inventory/presentation/providers/inventory_provider.dart';
import 'package:intl/intl.dart';
import '../../../../features/purchases/presentation/providers/purchase_history_provider.dart';
import '../../../../core/config/app_config.dart';

part 'dashboard_provider.g.dart';

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  if (AppConfig.useMocks) {
    return DashboardRepositoryImpl(remoteDataSource: DashboardMockDataSourceImpl());
  }

  final client = ref.watch(apiClientProvider);
  final dashboardDataSource = DashboardRemoteDataSourceImpl(client);

  return DashboardRepositoryImpl(remoteDataSource: dashboardDataSource);
}

@riverpod
GetDashboardStats getDashboardStatsUseCase(GetDashboardStatsUseCaseRef ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetDashboardStats(repository);
}



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
      final firstOfThisMonth = DateTime(today.year, today.month, 1);
      final firstOfLastMonth = DateTime(today.year, today.month - 1, 1);

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

      // Trend Calculations (Month-over-Month)
      final thisMonthSales = sales.where((s) => s.date.isAfter(firstOfThisMonth)).fold(0.0, (sum, s) => sum + s.grandTotal);
      final lastMonthSales = sales.where((s) => s.date.isAfter(firstOfLastMonth) && s.date.isBefore(firstOfThisMonth)).fold(0.0, (sum, s) => sum + s.grandTotal);

      final thisMonthPurchases = purchases.where((p) => p.date.isAfter(firstOfThisMonth)).fold(0.0, (sum, p) => sum + p.grandTotal);
      final lastMonthPurchases = purchases.where((p) => p.date.isAfter(firstOfLastMonth) && p.date.isBefore(firstOfThisMonth)).fold(0.0, (sum, p) => sum + p.grandTotal);

      final totalRevenue = sales.fold(0.0, (sum, s) => sum + s.grandTotal);
      final lowStockCount = products.where((p) => p.isLowStock || p.stock < 10).length;

      final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

      return DashboardStats(
        sales: formatter.format(todaySales),
        salesTrend: _calculateTrend(thisMonthSales, lastMonthSales),
        purchases: formatter.format(todayPurchases),
        purchasesTrend: _calculateTrend(thisMonthPurchases, lastMonthPurchases),
        collections: formatter.format(totalRevenue),
        collectionsTrend: "+${((thisMonthSales / (totalRevenue > 0 ? totalRevenue : 1)) * 100).toStringAsFixed(0)}%",
        lowStock: '$lowStockCount Items',
      );
    }

    return _fetchStats();
  }

  String? _calculateTrend(double current, double previous) {
    if (previous <= 0) return current > 0 ? "+100%" : null;
    final pct = ((current - previous) / previous) * 100;
    final sign = pct >= 0 ? "+" : "";
    return "$sign${pct.toStringAsFixed(0)}%";
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
