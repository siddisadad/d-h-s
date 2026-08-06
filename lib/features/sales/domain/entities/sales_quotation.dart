import 'invoice_item.dart';
import '../../data/models/invoice_model.dart';

enum QuotationStatus { pending, converted, expired, cancelled }

class SalesQuotation {
  final String id;
  final String customerId;
  final String customerName;
  final DateTime date;
  final DateTime expiryDate;
  final List<InvoiceItem> items;
  final double discount;
  final QuotationStatus status;
  final int lastUpdated;

  SalesQuotation({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.expiryDate,
    required this.items,
    required this.discount,
    this.status = QuotationStatus.pending,
    this.lastUpdated = 0,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get totalGst => items.fold(0, (sum, item) => sum + (item.subtotal * (item.gstRate / 100)));
  double get grandTotal => subtotal + totalGst - discount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'date': date.millisecondsSinceEpoch,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'items': items.map((i) => InvoiceItemModel.fromEntity(i).toJson()).toList(),
      'discount': discount,
      'status': status.name,
      'grandTotal': grandTotal,
      'lastUpdated': lastUpdated,
    };
  }

  factory SalesQuotation.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'];
    return SalesQuotation(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(json['expiryDate']),
      items: itemsJson.map((i) => InvoiceItemModel.fromJson(i)).toList(),
      discount: (json['discount'] as num).toDouble(),
      status: QuotationStatus.values.byName(json['status']),
      lastUpdated: json['lastUpdated'] as int? ?? 0,
    );
  }
}
