import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<Product>> getProducts({String? category});
  Future<Product> getProductBySku(String sku);
  Future<bool> createProduct(Product product);
  Future<bool> updateProduct(Product product);
  Future<bool> deleteProduct(String sku);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient _client;

  InventoryRemoteDataSourceImpl(this._client);

  @override
  Future<List<Product>> getProducts({String? category}) async {
    try {
      final response = await _client.dio.get(
        '/products',
        queryParameters: category != null ? {'category': category} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      debugPrint('⚠️ [Inventory API] Fetch Failed: $e');
      if (kDebugMode) {
        debugPrint('🛠️ [Debug Fallback] Returning Mock Products...');
        return _mockProducts;
      }
      rethrow;
    }
  }

  @override
  Future<Product> getProductBySku(String sku) async {
    try {
      final response = await _client.dio.get('/products/$sku');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      debugPrint('⚠️ [Inventory API] SKU $sku Fetch Failed: $e');
      if (kDebugMode) {
        return _mockProducts.firstWhere((p) => p.sku == sku);
      }
      rethrow;
    }
  }

  @override
  Future<bool> createProduct(Product product) async {
    try {
      final model = ProductModel(
        name: product.name,
        sku: product.sku,
        category: product.category,
        price: product.price,
        stock: product.stock,
        unit: product.unit,
        isLowStock: product.isLowStock,
      );
      final response = await _client.dio.post('/products', data: model.toJson());
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [Inventory API] Create Failed: $e');
      if (kDebugMode) return true;
      rethrow;
    }
  }

  @override
  Future<bool> updateProduct(Product product) async {
    try {
      final model = ProductModel(
        name: product.name,
        sku: product.sku,
        category: product.category,
        price: product.price,
        stock: product.stock,
        unit: product.unit,
        isLowStock: product.isLowStock,
      );
      final response = await _client.dio.put('/products/${product.sku}', data: model.toJson());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [Inventory API] Update Failed: $e');
      if (kDebugMode) return true;
      rethrow;
    }
  }

  @override
  Future<bool> deleteProduct(String sku) async {
    try {
      final response = await _client.dio.delete('/products/$sku');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('⚠️ [Inventory API] Delete Failed: $e');
      if (kDebugMode) return true;
      rethrow;
    }
  }

  final List<Product> _mockProducts = [
    Product(category: 'Steel', name: 'Tata Tiscon TMT Bars 12mm', price: 68.50, sku: 'STEEL-TT-12', stock: 4200, unit: 'Kg', isLowStock: false, hsnCode: '7214'),
    Product(category: 'Power Tools', name: 'Bosch Professional Drill 750W', price: 4250, sku: 'TOOL-BOS-750', stock: 8, unit: 'Piece', isLowStock: true, hsnCode: '8467'),
    Product(category: 'Plumbing', name: 'Copper Pipe 1 inch (Standard)', price: 210, sku: 'PLUMB-COP-1', stock: 150, unit: 'Meter', isLowStock: false, hsnCode: '7411'),
    Product(category: 'Electrical', name: 'Havells 1.5mm Double Core Wire', price: 1120, sku: 'ELEC-HAV-15', stock: 45, unit: 'Reel', isLowStock: false, hsnCode: '8544'),
  ];
}

class InventoryMockDataSourceImpl implements InventoryRemoteDataSource {
  final List<Product> _mockProducts = [
    Product(category: 'Steel', name: 'Tata Tiscon TMT Bars 12mm', price: 68.50, sku: 'STEEL-TT-12', stock: 4200, unit: 'Kg', isLowStock: false, hsnCode: '7214'),
    Product(category: 'Power Tools', name: 'Bosch Professional Drill 750W', price: 4250, sku: 'TOOL-BOS-750', stock: 8, unit: 'Piece', isLowStock: true, hsnCode: '8467'),
    Product(category: 'Plumbing', name: 'Copper Pipe 1 inch (Standard)', price: 210, sku: 'PLUMB-COP-1', stock: 150, unit: 'Meter', isLowStock: false, hsnCode: '7411'),
    Product(category: 'Electrical', name: 'Havells 1.5mm Double Core Wire', price: 1120, sku: 'ELEC-HAV-15', stock: 45, unit: 'Reel', isLowStock: false, hsnCode: '8544'),
  ];

  @override
  Future<List<Product>> getProducts({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (category == null || category.isEmpty || category == 'All Items') return _mockProducts;
    return _mockProducts.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  @override
  Future<Product> getProductBySku(String sku) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockProducts.firstWhere((p) => p.sku == sku);
  }

  @override
  Future<bool> createProduct(Product product) async => true;
  @override
  Future<bool> updateProduct(Product product) async => true;
  @override
  Future<bool> deleteProduct(String sku) async => true;
}
