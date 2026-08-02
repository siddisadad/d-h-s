import '../../../../core/error/result.dart';
import '../entities/report_item.dart';

abstract class AnalyticsRepository {
  Future<Result<List<ReportItem>>> getRecentReports();
}
