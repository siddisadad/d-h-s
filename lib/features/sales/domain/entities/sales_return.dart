import 'invoice_item.dart';
import '../../data/models/invoice_model.dart';

class SalesReturn {
  final String id;
  final String originalInvoiceId;
  final String customerId;
  final String customerName;
  final DateTime date;
  final List<InvoiceItem> items;
  final String reason;
  final double grandTotal;

  SalesReturn({
    required this.id,
    required this.originalInvoiceId,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.items,
    required this.reason,
    required this.grandTotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalInvoiceId': originalInvoiceId,
      'customerId': customerId,
      'customerName': customerName,
      'date': date.millisecondsSinceEpoch,
      'items': items.map((i) => (i as InvoiceItemModel).toJson()).toList(),
      'reason': reason,
      'grandTotal': grandTotal,
    };
  }

  factory SalesReturn.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'];
    return SalesReturn(
      id: json['id'],
      originalInvoiceId: json['originalInvoiceId'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      items: itemsJson.map((i) => InvoiceItemModel.fromJson(i)).toList(),
      reason: json['reason'],
      grandTotal: (json['grandTotal'] as num).toDouble(),
    );
  }
}
