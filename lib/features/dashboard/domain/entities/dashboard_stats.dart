class DashboardStats {
  final String sales;
  final String? salesTrend;
  final String purchases;
  final String? purchasesTrend;
  final String collections;
  final String? collectionsTrend;
  final String lowStock;

  DashboardStats({
    required this.sales,
    this.salesTrend,
    required this.purchases,
    this.purchasesTrend,
    required this.collections,
    this.collectionsTrend,
    required this.lowStock,
  });
}
