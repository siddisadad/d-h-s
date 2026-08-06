// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$employeeRepositoryHash() =>
    r'e03aecffa6490999e107348614ce0022bc5dba3e';

/// See also [employeeRepository].
@ProviderFor(employeeRepository)
final employeeRepositoryProvider =
    AutoDisposeProvider<EmployeeRepository>.internal(
  employeeRepository,
  name: r'employeeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$employeeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EmployeeRepositoryRef = AutoDisposeProviderRef<EmployeeRepository>;
String _$employeeNotifierHash() => r'c107b6561c73a33c305f05a4c015d00f2a6e232a';

/// See also [EmployeeNotifier].
@ProviderFor(EmployeeNotifier)
final employeeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<EmployeeNotifier, List<Employee>>.internal(
  EmployeeNotifier.new,
  name: r'employeeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$employeeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EmployeeNotifier = AutoDisposeAsyncNotifier<List<Employee>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
