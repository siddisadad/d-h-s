import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/data/datasources/inventory_remote_data_source.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/domain/entities/product.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/domain/entities/warehouse.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/domain/usecases/get_products.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/database_providers.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/firebase_providers.dart';
import 'package:deshmukh_steel_e_r_p/core/services/notification_service.dart';
import 'package:deshmukh_steel_e_r_p/core/network/api_client.dart';
import 'package:deshmukh_steel_e_r_p/core/utils/logger.dart';
import 'package:deshmukh_steel_e_r_p/features/dashboard/presentation/providers/activity_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/dashboard/domain/entities/activity.dart' as activity;

part 'inventory_provider.g.dart';

@riverpod
InventoryRepository inventoryRepository(InventoryRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  final firebaseDb = ref.watch(firebaseDatabaseServiceProvider);
  final localDb = ref.watch(localDatabaseProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  final inventoryDataSource = InventoryRemoteDataSourceImpl(client);

  return InventoryRepositoryImpl(
    remoteDataSource: inventoryDataSource,
    localDb: localDb,
    firebaseDb: firebaseDb,
    notificationService: notificationService,
  );
}

@riverpod
GetProducts getProductsUseCase(GetProductsUseCaseRef ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GetProducts(repository);
}

@riverpod
class InventoryCategory extends _$InventoryCategory {
  @override
  String build() => 'All Items';
  void set(String category) => state = category;
}

@riverpod
class InventorySearch extends _$InventorySearch {
  @override
  String build() => '';
  void set(String query) => state = query;
}

@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  @override
  Future<List<Product>> build() async => _fetchFromApi();

  Future<List<Product>> _fetchFromApi() async {
    try {
      final useCase = ref.read(getProductsUseCaseProvider);
      final result = await useCase(GetProductsParams(category: null));
      return result.fold((f) => throw Exception(f.message), (p) => p);
    } catch (e) { rethrow; }
  }

  Future<void> adjustStock(String sku, String warehouseId, double quantity, {String? reason, String? notes}) async {
    final repository = ref.read(inventoryRepositoryProvider);
    final result = await repository.adjustStock(sku, warehouseId, quantity, reason: reason, notes: notes);
    result.fold(
      (failure) => Log.e('Failed to adjust stock', error: failure.message, name: 'Inventory'),
      (success) {
        ref.read(activityNotifierProvider.notifier).addActivity(
          'Stock Adjusted',
          'SKU: $sku ${quantity >= 0 ? "+" : ""}$quantity in $warehouseId',
          activity.ActivityType.stockAdjustment,
        );
        ref.invalidateSelf();
      },
    );
  }

  Future<void> addProduct(Product product) async {
    state = const AsyncLoading();
    final result = await ref.read(inventoryRepositoryProvider).createProduct(product);
    state = await AsyncValue.guard(() async {
      return result.fold(
        (f) => throw Exception(f.message),
        (s) {
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
    final result = await ref.read(inventoryRepositoryProvider).updateProduct(product);
    state = await AsyncValue.guard(() async {
      return result.fold(
        (f) => throw Exception(f.message),
        (s) {
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
    final result = await ref.read(inventoryRepositoryProvider).deleteProduct(sku);
    state = await AsyncValue.guard(() async {
      return result.fold((f) => throw Exception(f.message), (s) => _fetchFromApi());
    });
  }
}

@riverpod
class WarehouseNotifier extends _$WarehouseNotifier {
  @override
  Future<List<Warehouse>> build() async {
    final repository = ref.read(inventoryRepositoryProvider);
    final result = await repository.getWarehouses();
    return result.fold((f) => [], (w) => w);
  }

  Future<void> addWarehouse(Warehouse warehouse) async {
    final repository = ref.read(inventoryRepositoryProvider);
    final result = await repository.createWarehouse(warehouse);
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
  }
}

@riverpod
Future<Product?> product(ProductRef ref, String sku) async {
  final products = await ref.watch(inventoryNotifierProvider.future);
  try { return products.firstWhere((p) => p.sku == sku); } catch (_) { return null; }
}

@riverpod
Future<Map<String, double>> stockBreakdown(StockBreakdownRef ref, String sku) async {
  final result = await ref.watch(inventoryRepositoryProvider).getStockBreakdown(sku);
  return result.fold((f) => {}, (b) => b);
}

@riverpod
List<Product> filteredProducts(FilteredProductsRef ref) {
  final productsAsync = ref.watch(inventoryNotifierProvider);
  final query = ref.watch(inventorySearchProvider).toLowerCase();
  final category = ref.watch(inventoryCategoryProvider);

  return productsAsync.maybeWhen(
    data: (products) {
      var filtered = products;
      if (category != 'All Items') {
        filtered = filtered.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
      }
      if (query.isNotEmpty) {
        filtered = filtered.where((p) => p.name.toLowerCase().contains(query) || p.sku.toLowerCase().contains(query)).toList();
      }
      return filtered;
    },
    orElse: () => [],
  );
}
