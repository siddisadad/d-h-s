import '../../domain/entities/sales_return.dart';
import 'invoice_model.dart';

class ReturnModel extends SalesReturn {
  ReturnModel({
    required super.id,
    required super.originalInvoiceId,
    required super.customerId,
    required super.customerName,
    required super.date,
    required super.items,
    required super.reason,
    required super.grandTotal,
    required super.lastUpdated,
  });

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    return ReturnModel(
      id: json['id'],
      originalInvoiceId: json['originalInvoiceId'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      items: (json['items'] as List).map((i) => InvoiceItemModel.fromJson(i)).toList(),
      reason: json['reason'],
      grandTotal: (json['grandTotal'] as num).toDouble(),
      lastUpdated: json['lastUpdated'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
    };
  }
}
