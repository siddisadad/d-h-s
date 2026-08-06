// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productMovementHash() => r'94f7f6130fe46d973b473b78bf8a79a34d4d5973';

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

/// See also [productMovement].
@ProviderFor(productMovement)
const productMovementProvider = ProductMovementFamily();

/// See also [productMovement].
class ProductMovementFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [productMovement].
  const ProductMovementFamily();

  /// See also [productMovement].
  ProductMovementProvider call(
    String sku,
  ) {
    return ProductMovementProvider(
      sku,
    );
  }

  @override
  ProductMovementProvider getProviderOverride(
    covariant ProductMovementProvider provider,
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
  String? get name => r'productMovementProvider';
}

/// See also [productMovement].
class ProductMovementProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [productMovement].
  ProductMovementProvider(
    String sku,
  ) : this._internal(
          (ref) => productMovement(
            ref as ProductMovementRef,
            sku,
          ),
          from: productMovementProvider,
          name: r'productMovementProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productMovementHash,
          dependencies: ProductMovementFamily._dependencies,
          allTransitiveDependencies:
              ProductMovementFamily._allTransitiveDependencies,
          sku: sku,
        );

  ProductMovementProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(ProductMovementRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductMovementProvider._internal(
        (ref) => create(ref as ProductMovementRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _ProductMovementProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductMovementProvider && other.sku == sku;
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
mixin ProductMovementRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `sku` of this provider.
  String get sku;
}

class _ProductMovementProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with ProductMovementRef {
  _ProductMovementProviderElement(super.provider);

  @override
  String get sku => (origin as ProductMovementProvider).sku;
}

String _$allMovementsHash() => r'30517d6762948b58f946cd10ce8d72afaf98a362';

/// See also [allMovements].
@ProviderFor(allMovements)
final allMovementsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  allMovements,
  name: r'allMovementsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allMovementsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllMovementsRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
