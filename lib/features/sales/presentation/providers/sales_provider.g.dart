// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$salesRepositoryHash() => r'b4bed8d93fc42d4a1c4ad16bed1a5416efbc114e';

/// See also [salesRepository].
@ProviderFor(salesRepository)
final salesRepositoryProvider = AutoDisposeProvider<SalesRepository>.internal(
  salesRepository,
  name: r'salesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$salesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SalesRepositoryRef = AutoDisposeProviderRef<SalesRepository>;
String _$createInvoiceUseCaseHash() =>
    r'c819646b5b61553647a68a3fcf7b77c1f06bbbc5';

/// See also [createInvoiceUseCase].
@ProviderFor(createInvoiceUseCase)
final createInvoiceUseCaseProvider =
    AutoDisposeProvider<CreateInvoice>.internal(
  createInvoiceUseCase,
  name: r'createInvoiceUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createInvoiceUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateInvoiceUseCaseRef = AutoDisposeProviderRef<CreateInvoice>;
String _$salesInvoiceNotifierHash() =>
    r'6603012af20c05834fb5f4fcd1f49c3def8b6041';

/// See also [SalesInvoiceNotifier].
@ProviderFor(SalesInvoiceNotifier)
final salesInvoiceNotifierProvider = AutoDisposeNotifierProvider<
    SalesInvoiceNotifier, SalesInvoiceDraft>.internal(
  SalesInvoiceNotifier.new,
  name: r'salesInvoiceNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$salesInvoiceNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SalesInvoiceNotifier = AutoDisposeNotifier<SalesInvoiceDraft>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
