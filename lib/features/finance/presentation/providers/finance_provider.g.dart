// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$financeRepositoryHash() => r'072c2891e3e6edcf92f85b14b26f3b5222cdf829';

/// See also [financeRepository].
@ProviderFor(financeRepository)
final financeRepositoryProvider =
    AutoDisposeProvider<FinanceRepository>.internal(
  financeRepository,
  name: r'financeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$financeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FinanceRepositoryRef = AutoDisposeProviderRef<FinanceRepository>;
String _$financeNotifierHash() => r'83cb328653d52029ebd2d6596306a698cca2d01d';

/// See also [FinanceNotifier].
@ProviderFor(FinanceNotifier)
final financeNotifierProvider = AutoDisposeAsyncNotifierProvider<
    FinanceNotifier, List<TransactionModel>>.internal(
  FinanceNotifier.new,
  name: r'financeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$financeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FinanceNotifier = AutoDisposeAsyncNotifier<List<TransactionModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
