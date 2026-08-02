import '../../../../core/error/result.dart';
import '../entities/product.dart';

abstract class InventoryRepository {
  Future<Result<List<Product>>> getProducts({String? category});
  Future<Result<Product>> getProductBySku(String sku);
  Future<Result<bool>> createProduct(Product product);
  Future<Result<bool>> updateProduct(Product product);
  Future<Result<bool>> deleteProduct(String sku);
}
