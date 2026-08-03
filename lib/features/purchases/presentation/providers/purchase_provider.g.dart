// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$purchaseRepositoryHash() =>
    r'4d4dfd3f2ae1d4ce2e53ab653f56b538cd2714ed';

/// See also [purchaseRepository].
@ProviderFor(purchaseRepository)
final purchaseRepositoryProvider =
    AutoDisposeProvider<PurchaseRepository>.internal(
  purchaseRepository,
  name: r'purchaseRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$purchaseRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PurchaseRepositoryRef = AutoDisposeProviderRef<PurchaseRepository>;
String _$purchaseNotifierHash() => r'754be7f505969907a4061306f0c8dc3de89e03db';

/// See also [PurchaseNotifier].
@ProviderFor(PurchaseNotifier)
final purchaseNotifierProvider = AutoDisposeAsyncNotifierProvider<
    PurchaseNotifier, List<PurchaseOrder>>.internal(
  PurchaseNotifier.new,
  name: r'purchaseNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$purchaseNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PurchaseNotifier = AutoDisposeAsyncNotifier<List<PurchaseOrder>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
