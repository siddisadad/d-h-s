class Product {
  final String name;
  final String sku;
  final String category;
  final double price;
  final double stock;
  final String unit;
  final bool isLowStock;
  final String? hsnCode;
  final String? preferredSupplierId;
  final double reorderPoint;
  final int lastUpdated;

  Product({
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
    required this.unit,
    required this.isLowStock,
    this.hsnCode,
    this.preferredSupplierId,
    this.reorderPoint = 0.0,
    this.lastUpdated = 0,
  });
}
