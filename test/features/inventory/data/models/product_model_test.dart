import 'package:flutter_test/flutter_test.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/data/models/product_model.dart';

void main() {
  group('ProductModel', () {
    final tProductModel = ProductModel(
      name: 'Test Product',
      sku: 'SKU123',
      category: 'Test Category',
      price: 100.0,
      stock: 50.0,
      unit: 'kg',
      isLowStock: false,
      hsnCode: 'HSN123',
      lastUpdated: 123456789,
    );

    test('fromJson should return a valid model with hsnCode', () {
      final Map<String, dynamic> jsonMap = {
        'name': 'Test Product',
        'sku': 'SKU123',
        'category': 'Test Category',
        'price': 100.0,
        'stock': 50.0,
        'unit': 'kg',
        'isLowStock': false,
        'hsnCode': 'HSN123',
        'lastUpdated': 123456789,
      };

      final result = ProductModel.fromJson(jsonMap);

      expect(result.hsnCode, 'HSN123');
    });

    test('toJson should return a JSON map containing hsnCode', () {
      final result = tProductModel.toJson();

      expect(result['hsnCode'], 'HSN123');
    });
  });
}
