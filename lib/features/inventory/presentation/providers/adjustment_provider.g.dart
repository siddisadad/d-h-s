// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjustment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productHistoryHash() => r'219cb36b8f534b6c0996deac57766de17f81d57a';

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

/// See also [productHistory].
@ProviderFor(productHistory)
const productHistoryProvider = ProductHistoryFamily();

/// See also [productHistory].
class ProductHistoryFamily extends Family<List<StockAdjustment>> {
  /// See also [productHistory].
  const ProductHistoryFamily();

  /// See also [productHistory].
  ProductHistoryProvider call(
    String sku,
  ) {
    return ProductHistoryProvider(
      sku,
    );
  }

  @override
  ProductHistoryProvider getProviderOverride(
    covariant ProductHistoryProvider provider,
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
  String? get name => r'productHistoryProvider';
}

/// See also [productHistory].
class ProductHistoryProvider
    extends AutoDisposeProvider<List<StockAdjustment>> {
  /// See also [productHistory].
  ProductHistoryProvider(
    String sku,
  ) : this._internal(
          (ref) => productHistory(
            ref as ProductHistoryRef,
            sku,
          ),
          from: productHistoryProvider,
          name: r'productHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productHistoryHash,
          dependencies: ProductHistoryFamily._dependencies,
          allTransitiveDependencies:
              ProductHistoryFamily._allTransitiveDependencies,
          sku: sku,
        );

  ProductHistoryProvider._internal(
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
    List<StockAdjustment> Function(ProductHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductHistoryProvider._internal(
        (ref) => create(ref as ProductHistoryRef),
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
  AutoDisposeProviderElement<List<StockAdjustment>> createElement() {
    return _ProductHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductHistoryProvider && other.sku == sku;
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
mixin ProductHistoryRef on AutoDisposeProviderRef<List<StockAdjustment>> {
  /// The parameter `sku` of this provider.
  String get sku;
}

class _ProductHistoryProviderElement
    extends AutoDisposeProviderElement<List<StockAdjustment>>
    with ProductHistoryRef {
  _ProductHistoryProviderElement(super.provider);

  @override
  String get sku => (origin as ProductHistoryProvider).sku;
}

String _$adjustmentNotifierHash() =>
    r'96661b1153c789dedb4ae23910bfb57f9c0812d7';

/// See also [AdjustmentNotifier].
@ProviderFor(AdjustmentNotifier)
final adjustmentNotifierProvider = AutoDisposeNotifierProvider<
    AdjustmentNotifier, List<StockAdjustment>>.internal(
  AdjustmentNotifier.new,
  name: r'adjustmentNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adjustmentNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdjustmentNotifier = AutoDisposeNotifier<List<StockAdjustment>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
