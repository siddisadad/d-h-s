import '../../domain/entities/purchase_order.dart';

class PurchaseModel extends PurchaseOrder {
  PurchaseModel({
    required super.id,
    required super.supplierName,
    required super.date,
    required super.amount,
    required super.status,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as String,
      supplierName: json['supplierName'] as String,
      date: json['date'] as String,
      amount: json['amount'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierName': supplierName,
      'date': date,
      'amount': amount,
      'status': status,
    };
  }
}
