import '../../../../core/error/result.dart';
import '../entities/product.dart';
import '../entities/warehouse.dart';
import '../entities/stock_transfer.dart';

abstract class InventoryRepository {
  Future<Result<List<Product>>> getProducts({String? category});
  Future<Result<Product>> getProductBySku(String sku);
  Future<Result<bool>> createProduct(Product product);
  Future<Result<bool>> updateProduct(Product product);
  Future<Result<bool>> deleteProduct(String sku);
  
  // Multi-Warehouse
  Future<Result<List<Warehouse>>> getWarehouses();
  Future<Result<bool>> createWarehouse(Warehouse warehouse);
  Future<Result<Map<String, double>>> getStockBreakdown(String sku);
  Future<Result<bool>> adjustStock(String sku, String warehouseId, double quantity, {String? reason, String? notes});
  Future<Result<bool>> transferStock(StockTransfer transfer);
}
