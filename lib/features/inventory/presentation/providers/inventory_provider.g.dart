// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inventoryRepositoryHash() =>
    r'148fff5ffe1ae5c22df33547b0d03c9a0af2093d';

/// See also [inventoryRepository].
@ProviderFor(inventoryRepository)
final inventoryRepositoryProvider =
    AutoDisposeProvider<InventoryRepository>.internal(
  inventoryRepository,
  name: r'inventoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InventoryRepositoryRef = AutoDisposeProviderRef<InventoryRepository>;
String _$getProductsUseCaseHash() =>
    r'0bbc75d3b3f87f3876a81126ffb9854593098e5d';

/// See also [getProductsUseCase].
@ProviderFor(getProductsUseCase)
final getProductsUseCaseProvider = AutoDisposeProvider<GetProducts>.internal(
  getProductsUseCase,
  name: r'getProductsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getProductsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetProductsUseCaseRef = AutoDisposeProviderRef<GetProducts>;
String _$productHash() => r'6d5db047975ebbf8bfc41b7386cfb155d18a7df4';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [product].
@ProviderFor(product)
const productProvider = ProductFamily();

/// See also [product].
class ProductFamily extends Family<AsyncValue<Product?>> {
  /// See also [product].
  const ProductFamily();

  /// See also [product].
  ProductProvider call(
    String sku,
  ) {
    return ProductProvider(
      sku,
    );
  }

  @override
  ProductProvider getProviderOverride(
    covariant ProductProvider provider,
  ) {
    return call(
      provider.sku,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productProvider';
}

/// See also [product].
class ProductProvider extends AutoDisposeFutureProvider<Product?> {
  /// See also [product].
  ProductProvider(
    String sku,
  ) : this._internal(
          (ref) => product(
            ref as ProductRef,
            sku,
          ),
          from: productProvider,
          name: r'productProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productHash,
          dependencies: ProductFamily._dependencies,
          allTransitiveDependencies: ProductFamily._allTransitiveDependencies,
          sku: sku,
        );

  ProductProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sku,
  }) : super.internal();

  final String sku;

  @override
  Override overrideWith(
    FutureOr<Product?> Function(ProductRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductProvider._internal(
        (ref) => create(ref as ProductRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sku: sku,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Product?> createElement() {
    return _ProductProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductProvider && other.sku == sku;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sku.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductRef on AutoDisposeFutureProviderRef<Product?> {
  /// The parameter `sku` of this provider.
  String get sku;
}

class _ProductProviderElement extends AutoDisposeFutureProviderElement<Product?>
    with ProductRef {
  _ProductProviderElement(super.provider);

  @override
  String get sku => (origin as ProductProvider).sku;
}

String _$stockBreakdownHash() => r'd3bc4acc63eed40b90365f07f7e5daa8ff5e3bb3';

/// See also [stockBreakdown].
@ProviderFor(stockBreakdown)
const stockBreakdownProvider = StockBreakdownFamily();

/// See also [stockBreakdown].
class StockBreakdownFamily extends Family<AsyncValue<Map<String, double>>> {
  /// See also [stockBreakdown].
  const StockBreakdownFamily();

  /// See also [stockBreakdown].
  StockBreakdownProvider call(
    String sku,
  ) {
    return StockBreakdownProvider(
      sku,
    );
  }

  @override
  StockBreakdownProvider getProviderOverride(
    covariant StockBreakdownProvider provider,
  ) {
    return call(
      provider.sku,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stockBreakdownProvider';
}

/// See also [stockBreakdown].
class StockBreakdownProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// See also [stockBreakdown].
  StockBreakdownProvider(
    String sku,
  ) : this._internal(
          (ref) => stockBreakdown(
            ref as StockBreakdownRef,
            sku,
          ),
          from: stockBreakdownProvider,
          name: r'stockBreakdownProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$stockBreakdownHash,
          dependencies: StockBreakdownFamily._dependencies,
          allTransitiveDependencies:
              StockBreakdownFamily._allTransitiveDependencies,
          sku: sku,
        );

  StockBreakdownProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sku,
  }) : super.internal();

  final String sku;

  @override
  Override overrideWith(
    FutureOr<Map<String, double>> Function(StockBreakdownRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StockBreakdownProvider._internal(
        (ref) => create(ref as StockBreakdownRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sku: sku,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _StockBreakdownProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StockBreakdownProvider && other.sku == sku;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sku.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StockBreakdownRef on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `sku` of this provider.
  String get sku;
}

class _StockBreakdownProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with StockBreakdownRef {
  _StockBreakdownProviderElement(super.provider);

  @override
  String get sku => (origin as StockBreakdownProvider).sku;
}

String _$filteredProductsHash() => r'a69acd7020be84940a57695805ee456e91dd8408';

/// See also [filteredProducts].
@ProviderFor(filteredProducts)
final filteredProductsProvider = AutoDisposeProvider<List<Product>>.internal(
  filteredProducts,
  name: r'filteredProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredProductsRef = AutoDisposeProviderRef<List<Product>>;
String _$inventoryCategoryHash() => r'1ccf64816f896d1cc9ecc8f626666e5187bb74b0';

/// See also [InventoryCategory].
@ProviderFor(InventoryCategory)
final inventoryCategoryProvider =
    AutoDisposeNotifierProvider<InventoryCategory, String>.internal(
  InventoryCategory.new,
  name: r'inventoryCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryCategory = AutoDisposeNotifier<String>;
String _$inventorySearchHash() => r'22d83e6195ab22608b98f1151b7a4f35957d1f73';

/// See also [InventorySearch].
@ProviderFor(InventorySearch)
final inventorySearchProvider =
    AutoDisposeNotifierProvider<InventorySearch, String>.internal(
  InventorySearch.new,
  name: r'inventorySearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventorySearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventorySearch = AutoDisposeNotifier<String>;
String _$inventoryNotifierHash() => r'af9d7e0cc9133d28f4faba4c4ec5dfa383b5a44e';

/// See also [InventoryNotifier].
@ProviderFor(InventoryNotifier)
final inventoryNotifierProvider =
    AutoDisposeAsyncNotifierProvider<InventoryNotifier, List<Product>>.internal(
  InventoryNotifier.new,
  name: r'inventoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryNotifier = AutoDisposeAsyncNotifier<List<Product>>;
String _$warehouseNotifierHash() => r'67a2948b1b6f95ac0abb8e7e922cfaf24c11e69a';

/// See also [WarehouseNotifier].
@ProviderFor(WarehouseNotifier)
final warehouseNotifierProvider = AutoDisposeAsyncNotifierProvider<
    WarehouseNotifier, List<Warehouse>>.internal(
  WarehouseNotifier.new,
  name: r'warehouseNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$warehouseNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WarehouseNotifier = AutoDisposeAsyncNotifier<List<Warehouse>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
