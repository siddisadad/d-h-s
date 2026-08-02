import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

class GetProductsParams {
  final String? category;
  GetProductsParams({this.category});
}

class GetProducts implements UseCase<List<Product>, GetProductsParams> {
  final InventoryRepository repository;

  GetProducts(this.repository);

  @override
  Future<Result<List<Product>>> call(GetProductsParams params) async {
    return await repository.getProducts(category: params.category);
  }
}
