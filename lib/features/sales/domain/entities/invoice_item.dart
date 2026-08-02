class InvoiceItem {
  final String name;
  final double price;
  final double qty;
  final double gstRate;

  InvoiceItem({
    required this.name,
    required this.price,
    required this.qty,
    required this.gstRate,
  });

  double get subtotal => price * qty;
  double get total => subtotal * (1 + gstRate / 100);
}
