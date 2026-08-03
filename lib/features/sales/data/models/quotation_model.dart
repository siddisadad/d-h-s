import '../../domain/entities/sales_quotation.dart';
import 'invoice_model.dart';

class QuotationModel extends SalesQuotation {
  QuotationModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.date,
    required super.expiryDate,
    required super.items,
    required super.discount,
    super.status,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(json['expiryDate']),
      items: (json['items'] as List).map((i) => InvoiceItemModel.fromJson(i)).toList(),
      discount: (json['discount'] as num).toDouble(),
      status: QuotationStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => QuotationStatus.pending),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'date': date.millisecondsSinceEpoch,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'items': items.map((i) => (i as InvoiceItemModel).toJson()).toList(),
      'discount': discount,
      'status': status.name,
      'grandTotal': grandTotal,
    };
  }
}
