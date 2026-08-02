// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRepositoryHash() =>
    r'44c84df7fc43171b90c15a08e7ff25fb2608e8ff';

/// See also [dashboardRepository].
@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider =
    AutoDisposeProvider<DashboardRepository>.internal(
  dashboardRepository,
  name: r'dashboardRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRepositoryRef = AutoDisposeProviderRef<DashboardRepository>;
String _$getDashboardStatsUseCaseHash() =>
    r'bd1f1abd505a465426354417874bb8a87dcfc444';

/// See also [getDashboardStatsUseCase].
@ProviderFor(getDashboardStatsUseCase)
final getDashboardStatsUseCaseProvider =
    AutoDisposeProvider<GetDashboardStats>.internal(
  getDashboardStatsUseCase,
  name: r'getDashboardStatsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getDashboardStatsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetDashboardStatsUseCaseRef = AutoDisposeProviderRef<GetDashboardStats>;
String _$dashboardStatsNotifierHash() =>
    r'785bb413c81e636d60518f8ad410ba0353e731c5';

/// See also [DashboardStatsNotifier].
@ProviderFor(DashboardStatsNotifier)
final dashboardStatsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    DashboardStatsNotifier, DashboardStats?>.internal(
  DashboardStatsNotifier.new,
  name: r'dashboardStatsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardStatsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DashboardStatsNotifier = AutoDisposeAsyncNotifier<DashboardStats?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
