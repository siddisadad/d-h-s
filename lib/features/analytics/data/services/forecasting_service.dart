import 'dart:math';
import '../../../sales/domain/entities/sales_invoice.dart';
import '../../domain/entities/demand_forecast.dart';

class ForecastingService {
  DemandForecast calculateForecast({
    required String sku,
    required List<SalesInvoice> history,
    required double currentStock,
  }) {
    final now = DateTime.now();
    
    // 1. Group sales by week (last 4 weeks)
    final week1Sales = _getQuantityForPeriod(sku, history, now.subtract(const Duration(days: 7)), now);
    final week2Sales = _getQuantityForPeriod(sku, history, now.subtract(const Duration(days: 14)), now.subtract(const Duration(days: 7)));
    final week3Sales = _getQuantityForPeriod(sku, history, now.subtract(const Duration(days: 21)), now.subtract(const Duration(days: 14)));
    final week4Sales = _getQuantityForPeriod(sku, history, now.subtract(const Duration(days: 28)), now.subtract(const Duration(days: 21)));

    // 2. Weighted Moving Average (WMA)
    // Most recent week gets highest weight
    final predictedWeeklyDemand = (week1Sales * 0.4) + (week2Sales * 0.3) + (week3Sales * 0.2) + (week4Sales * 0.1);

    // 3. Determine Trend
    TrendDirection trend = TrendDirection.stable;
    if (week1Sales > week2Sales * 1.1) {
      trend = TrendDirection.up;
    } else if (week1Sales < week2Sales * 0.9) {
      trend = TrendDirection.down;
    }

    // 4. Calculate Confidence (based on data density)
    final totalSalesRecords = history.where((inv) => inv.items.any((item) => item.sku == sku)).length;
    final confidence = min(1.0, totalSalesRecords / 10.0); // 10+ records for full confidence

    // 5. Days until stock out
    int estimatedDaysUntilStockOut = 999;
    if (predictedWeeklyDemand > 0) {
      final dailyDemand = predictedWeeklyDemand / 7;
      estimatedDaysUntilStockOut = (currentStock / dailyDemand).floor();
    }

    return DemandForecast(
      sku: sku,
      predictedWeeklyDemand: predictedWeeklyDemand,
      confidence: confidence,
      trend: trend,
      estimatedDaysUntilStockOut: estimatedDaysUntilStockOut,
    );
  }

  double _getQuantityForPeriod(String sku, List<SalesInvoice> history, DateTime start, DateTime end) {
    double total = 0;
    for (var inv in history) {
      if (inv.date.isAfter(start) && inv.date.isBefore(end)) {
        for (var item in inv.items) {
          if (item.sku == sku) {
            total += item.qty;
          }
        }
      }
    }
    return total;
  }
}
