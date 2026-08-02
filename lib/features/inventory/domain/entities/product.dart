class Product {
  final String name;
  final String sku;
  final String category;
  final String price;
  final String stock;
  final String unit;
  final bool isLowStock;

  Product({
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
    required this.unit,
    required this.isLowStock,
  });
}
