import '../../domain/entities/sales_invoice.dart';
import '../../domain/entities/invoice_item.dart';

class InvoiceModel extends SalesInvoice {
  InvoiceModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.date,
    required super.items,
    super.discount,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List)
          .map((i) => InvoiceItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'date': date.toIso8601String(),
      'items': items.map((i) => InvoiceItemModel.fromEntity(i).toJson()).toList(),
      'discount': discount,
    };
  }
}

class InvoiceItemModel extends InvoiceItem {
  InvoiceItemModel({
    required super.name,
    required super.sku,
    super.hsnCode,
    required super.price,
    required super.qty,
    required super.gstRate,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      name: json['name'] as String,
      sku: json['sku'] as String? ?? '',
      hsnCode: json['hsnCode'] as String?,
      price: (json['price'] as num).toDouble(),
      qty: (json['qty'] as num).toDouble(),
      gstRate: (json['gstRate'] as num).toDouble(),
    );
  }

  factory InvoiceItemModel.fromEntity(InvoiceItem entity) {
    return InvoiceItemModel(
      name: entity.name,
      sku: entity.sku,
      hsnCode: entity.hsnCode,
      price: entity.price,
      qty: entity.qty,
      gstRate: entity.gstRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      'hsnCode': hsnCode,
      'price': price,
      'qty': qty,
      'gstRate': gstRate,
    };
  }
}
