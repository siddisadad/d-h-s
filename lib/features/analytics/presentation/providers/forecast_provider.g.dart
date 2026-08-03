// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$demandForecastHash() => r'96e534bd4f2588248209d9a78ae8c46305f33f9b';

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

/// See also [demandForecast].
@ProviderFor(demandForecast)
const demandForecastProvider = DemandForecastFamily();

/// See also [demandForecast].
class DemandForecastFamily extends Family<AsyncValue<DemandForecast?>> {
  /// See also [demandForecast].
  const DemandForecastFamily();

  /// See also [demandForecast].
  DemandForecastProvider call(
    String sku,
  ) {
    return DemandForecastProvider(
      sku,
    );
  }

  @override
  DemandForecastProvider getProviderOverride(
    covariant DemandForecastProvider provider,
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
  String? get name => r'demandForecastProvider';
}

/// See also [demandForecast].
class DemandForecastProvider
    extends AutoDisposeFutureProvider<DemandForecast?> {
  /// See also [demandForecast].
  DemandForecastProvider(
    String sku,
  ) : this._internal(
          (ref) => demandForecast(
            ref as DemandForecastRef,
            sku,
          ),
          from: demandForecastProvider,
          name: r'demandForecastProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$demandForecastHash,
          dependencies: DemandForecastFamily._dependencies,
          allTransitiveDependencies:
              DemandForecastFamily._allTransitiveDependencies,
          sku: sku,
        );

  DemandForecastProvider._internal(
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
    FutureOr<DemandForecast?> Function(DemandForecastRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DemandForecastProvider._internal(
        (ref) => create(ref as DemandForecastRef),
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
  AutoDisposeFutureProviderElement<DemandForecast?> createElement() {
    return _DemandForecastProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DemandForecastProvider && other.sku == sku;
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
mixin DemandForecastRef on AutoDisposeFutureProviderRef<DemandForecast?> {
  /// The parameter `sku` of this provider.
  String get sku;
}

class _DemandForecastProviderElement
    extends AutoDisposeFutureProviderElement<DemandForecast?>
    with DemandForecastRef {
  _DemandForecastProviderElement(super.provider);

  @override
  String get sku => (origin as DemandForecastProvider).sku;
}

String _$allDemandForecastsHash() =>
    r'31bbbaf097dfc5ecf19453281e335e67566f2369';

/// See also [allDemandForecasts].
@ProviderFor(allDemandForecasts)
final allDemandForecastsProvider =
    AutoDisposeFutureProvider<Map<String, DemandForecast>>.internal(
  allDemandForecasts,
  name: r'allDemandForecastsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allDemandForecastsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllDemandForecastsRef
    = AutoDisposeFutureProviderRef<Map<String, DemandForecast>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
