import 'package:flutter/foundation.dart';
import 'package:deshmukh_steel_e_r_p/core/error/failures.dart';
import 'package:deshmukh_steel_e_r_p/core/error/result.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/domain/entities/report_item.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:deshmukh_steel_e_r_p/core/database/local_database.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final LocalDatabase localDatabase;

  AnalyticsRepositoryImpl({required this.localDatabase});

  @override
  Future<Result<List<ReportItem>>> getRecentReports() async {
    try {
      if (kIsWeb) {
        return Result.success([
          ReportItem(title: 'Monthly Sales (Mock)', date: _getCurrentMonth(), type: 'PDF', summary: 'Preview data for Web demo.'),
        ]);
      }
      final db = await localDatabase.database;
      
      // Calculate real stats for the summary report
      final List<Map<String, dynamic>> sales = await db.query('sales');
      final double totalRevenue = sales.fold(0.0, (sum, item) => sum + (item['grandTotal'] as num).toDouble());
      
      return Result.success([
        ReportItem(
          title: 'Monthly Sales Analysis', 
          date: _getCurrentMonth(), 
          type: 'PDF',
          summary: 'Total Revenue: ₹${totalRevenue.toStringAsFixed(0)} (${sales.length} Invoices)',
        ),
        ReportItem(
          title: 'Inventory Aging Report', 
          date: _getCurrentMonth(), 
          type: 'CSV',
          summary: 'Auto-generated based on current stock levels.',
        ),
      ]);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  String _getCurrentMonth() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[now.month - 1]} ${now.year}';
  }
}
