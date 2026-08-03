import 'invoice_item.dart';

class SalesInvoice {
  final String id;
  final String customerId;
  final String customerName;
  final DateTime date;
  final List<InvoiceItem> items;
  final double discount;

  SalesInvoice({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.items,
    this.discount = 0.0,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get totalGst => items.fold(0.0, (sum, item) => sum + (item.subtotal * item.gstRate / 100));
  double get grandTotal => subtotal + totalGst - discount;
}
