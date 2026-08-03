class StockTransfer {
  final String id;
  final String fromWarehouseId;
  final String toWarehouseId;
  final String productSku;
  final String productName;
  final double quantity;
  final DateTime timestamp;
  final String performedBy;
  final String? notes;

  StockTransfer({
    required this.id,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    required this.productSku,
    required this.productName,
    required this.quantity,
    required this.timestamp,
    required this.performedBy,
    this.notes,
  });
}
