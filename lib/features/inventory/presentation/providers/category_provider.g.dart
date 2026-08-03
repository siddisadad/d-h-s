// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryNamesHash() => r'90e1588b266515f3db3a46bb92d685d418386350';

/// See also [categoryNames].
@ProviderFor(categoryNames)
final categoryNamesProvider = AutoDisposeProvider<List<String>>.internal(
  categoryNames,
  name: r'categoryNamesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryNamesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryNamesRef = AutoDisposeProviderRef<List<String>>;
String _$categoryNotifierHash() => r'6f1b01584d299bcac8df2adbbeb8c98091689e3f';

/// See also [CategoryNotifier].
@ProviderFor(CategoryNotifier)
final categoryNotifierProvider = AutoDisposeNotifierProvider<CategoryNotifier,
    List<InventoryCategory>>.internal(
  CategoryNotifier.new,
  name: r'categoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoryNotifier = AutoDisposeNotifier<List<InventoryCategory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
