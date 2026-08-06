// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'procurement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$procurementServiceHash() =>
    r'a28add5128dfbc72a6b614f9a812db3e5be96d0b';

/// See also [procurementService].
@ProviderFor(procurementService)
final procurementServiceProvider =
    AutoDisposeProvider<ProcurementService>.internal(
  procurementService,
  name: r'procurementServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$procurementServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProcurementServiceRef = AutoDisposeProviderRef<ProcurementService>;
String _$restockSuggestionsHash() =>
    r'9a2db61aefeb99871f08b99f94a21e162bc14db7';

/// See also [restockSuggestions].
@ProviderFor(restockSuggestions)
final restockSuggestionsProvider =
    AutoDisposeFutureProvider<List<RestockSuggestion>>.internal(
  restockSuggestions,
  name: r'restockSuggestionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$restockSuggestionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RestockSuggestionsRef
    = AutoDisposeFutureProviderRef<List<RestockSuggestion>>;
String _$suggestionsBySupplierHash() =>
    r'b4c274e7468a5be726dd4bc85e2b1c7dbc8144e6';

/// See also [suggestionsBySupplier].
@ProviderFor(suggestionsBySupplier)
final suggestionsBySupplierProvider =
    AutoDisposeFutureProvider<Map<String?, List<RestockSuggestion>>>.internal(
  suggestionsBySupplier,
  name: r'suggestionsBySupplierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$suggestionsBySupplierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SuggestionsBySupplierRef
    = AutoDisposeFutureProviderRef<Map<String?, List<RestockSuggestion>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
