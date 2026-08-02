import 'package:deshmukh_steel_e_r_p/core/error/failures.dart';
import 'package:deshmukh_steel_e_r_p/core/error/result.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/domain/entities/report_item.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  @override
  Future<Result<List<ReportItem>>> getRecentReports() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return Result.success([
        ReportItem(title: 'Monthly Sales Analysis', date: 'Oct 2024', type: 'PDF'),
        ReportItem(title: 'Inventory Aging Report', date: 'Oct 2024', type: 'CSV'),
      ]);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
