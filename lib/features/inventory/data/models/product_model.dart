import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.name,
    required super.sku,
    required super.category,
    required super.price,
    required super.stock,
    required super.unit,
    required super.isLowStock,
    super.hsnCode,
    super.preferredSupplierId,
    super.reorderPoint = 0.0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      name: json['name'] as String,
      sku: json['sku'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toDouble(),
      unit: json['unit'] as String,
      isLowStock: json['isLowStock'] as bool? ?? false,
      hsnCode: json['hsnCode'] as String?,
      preferredSupplierId: json['preferredSupplierId'] as String?,
      reorderPoint: (json['reorderPoint'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'stock': stock,
      'unit': unit,
      'isLowStock': isLowStock,
      'hsnCode': hsnCode,
      'preferredSupplierId': preferredSupplierId,
      'reorderPoint': reorderPoint,
    };
  }

  Product toEntity() {
    return Product(
      name: name,
      sku: sku,
      category: category,
      price: price,
      stock: stock,
      unit: unit,
      isLowStock: isLowStock,
      hsnCode: hsnCode,
      preferredSupplierId: preferredSupplierId,
      reorderPoint: reorderPoint,
    );
  }
}
