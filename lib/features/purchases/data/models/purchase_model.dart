import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/purchase_item.dart';

class PurchaseModel extends PurchaseOrder {
  PurchaseModel({
    required super.id,
    required super.supplierId,
    required super.supplierName,
    required super.date,
    required super.items,
    super.discount,
    required super.status,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List)
          .map((i) => PurchaseItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'date': date.toIso8601String(),
      'items': items.map((i) => PurchaseItemModel.fromEntity(i).toJson()).toList(),
      'discount': discount,
      'status': status,
    };
  }
}

class PurchaseItemModel extends PurchaseItem {
  PurchaseItemModel({
    required super.name,
    required super.sku,
    super.hsnCode,
    required super.costPrice,
    required super.qty,
    required super.gstRate,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      name: json['name'] as String,
      sku: json['sku'] as String? ?? '',
      hsnCode: json['hsnCode'] as String?,
      costPrice: (json['costPrice'] as num).toDouble(),
      qty: (json['qty'] as num).toDouble(),
      gstRate: (json['gstRate'] as num).toDouble(),
    );
  }

  factory PurchaseItemModel.fromEntity(PurchaseItem entity) {
    return PurchaseItemModel(
      name: entity.name,
      sku: entity.sku,
      hsnCode: entity.hsnCode,
      costPrice: entity.costPrice,
      qty: entity.qty,
      gstRate: entity.gstRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      'hsnCode': hsnCode,
      'costPrice': costPrice,
      'qty': qty,
      'gstRate': gstRate,
    };
  }
}
