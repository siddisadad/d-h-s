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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      name: json['name'] as String,
      sku: json['sku'] as String,
      category: json['category'] as String,
      price: json['price'] as String,
      stock: json['stock'] as String,
      unit: json['unit'] as String,
      isLowStock: json['isLowStock'] as bool? ?? false,
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
    };
  }
}
