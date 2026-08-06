class PurchaseItem {
  final String name;
  final String sku;
  final String? hsnCode;
  final double costPrice;
  final double qty;
  final double gstRate;

  PurchaseItem({
    required this.name,
    required this.sku,
    this.hsnCode,
    required this.costPrice,
    required this.qty,
    required this.gstRate,
  });

  double get subtotal => costPrice * qty;
  double get total => subtotal * (1 + gstRate / 100);
}
