// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRepositoryHash() =>
    r'6c50029b504f48b523badf41381a507cad558528';

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
    r'3d9ceb6c219b3bebac81d3ee5c1ef2c305f27eae';

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
    r'62744b66cf5e143bc0a5b53707a400e58e009da5';

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
