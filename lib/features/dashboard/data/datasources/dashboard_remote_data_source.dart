import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/dashboard_stats.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStats> getStats();
  Future<List<double>> getRevenueTrend();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _client;

  DashboardRemoteDataSourceImpl(this._client);

  @override
  Future<DashboardStats> getStats() async {
    try {
      final response = await _client.dio.get('/dashboard/stats');

      if (response.statusCode == 200) {
        final data = response.data;
        Log.d('Dashboard Stats Data: $data', name: 'API');
        
        if (data is! Map) {
          throw Exception('Expected JSON Map but received: ${data.runtimeType}');
        }

        return DashboardStats(
          sales: data['sales']?.toString() ?? '₹0',
          purchases: data['purchases']?.toString() ?? '₹0',
          collections: data['collections']?.toString() ?? '₹0',
          lowStock: data['lowStock']?.toString() ?? '0 Items',
        );
      } else {
        throw Exception('Failed to load dashboard stats (Status: ${response.statusCode})');
      }
    } catch (e, stack) {
      Log.e('Get Dashboard Stats Failed', error: e, stackTrace: stack, name: 'API');
      rethrow;
    }
  }

  @override
  Future<List<double>> getRevenueTrend() async {
    final response = await _client.dio.get('/dashboard/revenue-trend');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((d) => (d as num).toDouble()).toList();
    } else {
      throw Exception('Failed to load revenue trend');
    }
  }
}

class DashboardMockDataSourceImpl implements DashboardRemoteDataSource {
  @override
  Future<DashboardStats> getStats() async {
    Log.d('Fetching Mock Dashboard Stats', name: 'MOCK');
    await Future.delayed(const Duration(milliseconds: 500));
    return DashboardStats(
      sales: '₹1,45,200',
      purchases: '₹82,400',
      collections: '₹92,000',
      lowStock: '14 Items',
    );
  }

  @override
  Future<List<double>> getRevenueTrend() async {
    return [45.0, 52.0, 48.0, 70.0, 61.0, 85.0, 92.0];
  }
}
