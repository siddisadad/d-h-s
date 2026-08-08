import '../../domain/entities/stock_audit.dart';

class StockAuditModel extends StockAudit {
  StockAuditModel({
    required super.id,
    required super.warehouseId,
    required super.timestamp,
    required super.performedBy,
    required super.items,
    super.status,
    super.lastUpdated,
  });

  factory StockAuditModel.fromJson(Map<String, dynamic> json) {
    return StockAuditModel(
      id: json['id'] as String,
      warehouseId: json['warehouseId'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      performedBy: json['performedBy'] as String,
      items: (json['items'] as List)
          .map((i) => StockAuditItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? 'Draft',
      lastUpdated: json['lastUpdated'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warehouseId': warehouseId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'performedBy': performedBy,
      'items': items.map((i) => StockAuditItemModel.fromEntity(i).toJson()).toList(),
      'status': status,
      'lastUpdated': lastUpdated,
    };
  }
}

class StockAuditItemModel extends StockAuditItem {
  StockAuditItemModel({
    required super.productSku,
    required super.productName,
    required super.systemQuantity,
    required super.physicalQuantity,
  });

  factory StockAuditItemModel.fromJson(Map<String, dynamic> json) {
    return StockAuditItemModel(
      productSku: json['productSku'] as String,
      productName: json['productName'] as String,
      systemQuantity: (json['systemQuantity'] as num).toDouble(),
      physicalQuantity: (json['physicalQuantity'] as num).toDouble(),
    );
  }

  factory StockAuditItemModel.fromEntity(StockAuditItem entity) {
    return StockAuditItemModel(
      productSku: entity.productSku,
      productName: entity.productName,
      systemQuantity: entity.systemQuantity,
      physicalQuantity: entity.physicalQuantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productSku': productSku,
      'productName': productName,
      'systemQuantity': systemQuantity,
      'physicalQuantity': physicalQuantity,
    };
  }
}
