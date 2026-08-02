import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/get_products.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/logger.dart';
import '../../../dashboard/presentation/providers/activity_provider.dart';
import '../../../dashboard/domain/entities/activity.dart' as activity;

part 'inventory_provider.g.dart';

@riverpod
InventoryRepository inventoryRepository(InventoryRepositoryRef ref) => sl.inventoryRepository;

@riverpod
GetProducts getProductsUseCase(GetProductsUseCaseRef ref) => sl.getProductsUseCase;

@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  @override
  Future<List<Product>> build() async {
    return _fetchFromApi();
  }

  String _currentCategory = 'All Items';
  String _searchQuery = '';

  String get currentCategory => _currentCategory;
  String get searchQuery => _searchQuery;

  Future<List<Product>> _fetchFromApi() async {
    try {
      Log.d('Fetching Inventory from API...', name: 'Inventory');
      final useCase = ref.read(getProductsUseCaseProvider);
      final result = await useCase(GetProductsParams(category: null));

      return result.fold(
        (failure) {
          Log.e('Inventory API Fetch Failed', error: failure.message, name: 'Inventory');
          throw Exception(failure.message);
        },
        (products) {
          Log.d('Inventory API Fetch Complete. Records: ${products.length}', name: 'Inventory');
          
          if (_currentCategory == 'All Items') {
            return products;
          }
          return products.where((p) => p.category.toLowerCase() == _currentCategory.toLowerCase()).toList();
        },
      );
    } catch (e, stack) {
      Log.e('Inventory Provider Error', error: e, stackTrace: stack, name: 'Inventory');
      rethrow;
    }
  }

  void setCategory(String category) {
    _currentCategory = category;
    ref.invalidateSelf();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    ref.notifyListeners(); 
  }

  Future<void> addProduct(Product product) async {
    state = const AsyncLoading();
    final repository = ref.read(inventoryRepositoryProvider);
    final result = await repository.createProduct(product);
    
    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) => throw Exception(failure.message),
        (success) {
          ref.read(activityNotifierProvider.notifier).addActivity(
            'New Product Added',
            '${product.name} (SKU: ${product.sku})',
            activity.ActivityType.stockAdjustment,
          );
          return _fetchFromApi();
        },
      );
    });
  }

  Future<void> updateProduct(Product product) async {
    state = const AsyncLoading();
    final repository = ref.read(inventoryRepositoryProvider);
    final result = await repository.updateProduct(product);
    
    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) => throw Exception(failure.message),
        (success) {
          ref.read(activityNotifierProvider.notifier).addActivity(
            'Product Updated',
            '${product.name} details modified',
            activity.ActivityType.stockAdjustment,
          );
          return _fetchFromApi();
        },
      );
    });
  }

  Future<void> deleteProduct(String sku) async {
    state = const AsyncLoading();
    final repository = ref.read(inventoryRepositoryProvider);
    final result = await repository.deleteProduct(sku);
    
    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) => throw Exception(failure.message),
        (success) {
          ref.read(activityNotifierProvider.notifier).addActivity(
            'Product Deleted',
            'SKU: $sku removed from system',
            activity.ActivityType.stockAdjustment,
          );
          return _fetchFromApi();
        },
      );
    });
  }

  Future<void> adjustStock(String sku, double quantity) async {
    ref.read(activityNotifierProvider.notifier).addActivity(
      'Stock Adjusted',
      'SKU: $sku ${quantity >= 0 ? "+" : ""}$quantity',
      activity.ActivityType.stockAdjustment,
    );

    ref.invalidateSelf();
  }
}

@riverpod
List<Product> filteredProducts(FilteredProductsRef ref) {
  final productsAsync = ref.watch(inventoryNotifierProvider);
  final notifier = ref.watch(inventoryNotifierProvider.notifier);
  final query = notifier.searchQuery.toLowerCase();

  return productsAsync.maybeWhen(
    data: (products) {
      if (query.isEmpty) return products;
      return products.where((p) => 
        p.name.toLowerCase().contains(query) || 
        p.sku.toLowerCase().contains(query)
      ).toList();
    },
    orElse: () => [],
  );
}
