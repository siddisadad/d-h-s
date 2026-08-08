class StockAudit {
  final String id;
  final String warehouseId;
  final DateTime timestamp;
  final String performedBy;
  final List<StockAuditItem> items;
  final String status; // 'Draft', 'Completed'
  final int lastUpdated;

  StockAudit({
    required this.id,
    required this.warehouseId,
    required this.timestamp,
    required this.performedBy,
    required this.items,
    this.status = 'Draft',
    this.lastUpdated = 0,
  });
}

class StockAuditItem {
  final String productSku;
  final String productName;
  final double systemQuantity;
  final double physicalQuantity;

  StockAuditItem({
    required this.productSku,
    required this.productName,
    required this.systemQuantity,
    required this.physicalQuantity,
  });

  double get variance => physicalQuantity - systemQuantity;
}
