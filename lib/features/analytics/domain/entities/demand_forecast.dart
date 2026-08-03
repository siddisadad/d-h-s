enum TrendDirection { up, down, stable }

class DemandForecast {
  final String sku;
  final double predictedWeeklyDemand;
  final double confidence; // 0.0 to 1.0
  final TrendDirection trend;
  final int estimatedDaysUntilStockOut;

  DemandForecast({
    required this.sku,
    required this.predictedWeeklyDemand,
    required this.confidence,
    required this.trend,
    required this.estimatedDaysUntilStockOut,
  });

  bool get isCritical => estimatedDaysUntilStockOut <= 3;
  bool get isWarning => estimatedDaysUntilStockOut <= 7;
}
