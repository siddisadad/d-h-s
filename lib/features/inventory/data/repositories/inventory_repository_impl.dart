import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<Product>>> getProducts({String? category}) async {
    try {
      final products = await remoteDataSource.getProducts(category: category);
      return Result.success(products);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product>> getProductBySku(String sku) async {
    try {
      final product = await remoteDataSource.getProductBySku(sku);
      return Result.success(product);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> createProduct(Product product) async {
    try {
      final success = await remoteDataSource.createProduct(product);
      return Result.success(success);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> updateProduct(Product product) async {
    try {
      final success = await remoteDataSource.updateProduct(product);
      return Result.success(success);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> deleteProduct(String sku) async {
    try {
      final success = await remoteDataSource.deleteProduct(sku);
      return Result.success(success);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
