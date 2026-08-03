// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredCustomersHash() => r'cec15da1dd4331919e4dcd4a8b09c91357d29249';

/// See also [filteredCustomers].
@ProviderFor(filteredCustomers)
final filteredCustomersProvider =
    AutoDisposeFutureProvider<List<Contact>>.internal(
  filteredCustomers,
  name: r'filteredCustomersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredCustomersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredCustomersRef = AutoDisposeFutureProviderRef<List<Contact>>;
String _$customerLocationsHash() => r'59510c7ab014f1339f7f923641d490ad0d595ca5';

/// See also [customerLocations].
@ProviderFor(customerLocations)
final customerLocationsProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  customerLocations,
  name: r'customerLocationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customerLocationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomerLocationsRef = AutoDisposeFutureProviderRef<List<String>>;
String _$customerSearchHash() => r'd84835f2b740a145a8cf41d98cdc90025305b335';

/// See also [CustomerSearch].
@ProviderFor(CustomerSearch)
final customerSearchProvider =
    AutoDisposeNotifierProvider<CustomerSearch, String>.internal(
  CustomerSearch.new,
  name: r'customerSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customerSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CustomerSearch = AutoDisposeNotifier<String>;
String _$customerLocationFilterHash() =>
    r'35d21b4ea497013c82114ba7a31124f09a45b5ae';

/// See also [CustomerLocationFilter].
@ProviderFor(CustomerLocationFilter)
final customerLocationFilterProvider =
    AutoDisposeNotifierProvider<CustomerLocationFilter, String>.internal(
  CustomerLocationFilter.new,
  name: r'customerLocationFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customerLocationFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CustomerLocationFilter = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
