import 'purchase_item.dart';

class PurchaseOrder {
  final String id;
  final String supplierId;
  final String supplierName;
  final DateTime date;
  final List<PurchaseItem> items;
  final double discount;
  final String status;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.date,
    required this.items,
    this.discount = 0.0,
    required this.status,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get totalGst => items.fold(0.0, (sum, item) => sum + (item.subtotal * item.gstRate / 100));
  double get grandTotal => subtotal + totalGst - discount;
}
