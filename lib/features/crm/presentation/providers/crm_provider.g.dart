// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$crmRepositoryHash() => r'ee5dfba1ee3fc53da97329aca3185bab3cd3bb66';

/// See also [crmRepository].
@ProviderFor(crmRepository)
final crmRepositoryProvider = AutoDisposeProvider<CrmRepository>.internal(
  crmRepository,
  name: r'crmRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$crmRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrmRepositoryRef = AutoDisposeProviderRef<CrmRepository>;
String _$getContactsUseCaseHash() =>
    r'4663d610a2eab064c6fe07697d5a1d0e660f2fc4';

/// See also [getContactsUseCase].
@ProviderFor(getContactsUseCase)
final getContactsUseCaseProvider = AutoDisposeProvider<GetContacts>.internal(
  getContactsUseCase,
  name: r'getContactsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getContactsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetContactsUseCaseRef = AutoDisposeProviderRef<GetContacts>;
String _$crmNotifierHash() => r'ef423953ab487c465b7719c9053e1acab95c1482';

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

abstract class _$CrmNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Contact>> {
  late final ContactType type;

  FutureOr<List<Contact>> build(
    ContactType type,
  );
}

/// See also [CrmNotifier].
@ProviderFor(CrmNotifier)
const crmNotifierProvider = CrmNotifierFamily();

/// See also [CrmNotifier].
class CrmNotifierFamily extends Family<AsyncValue<List<Contact>>> {
  /// See also [CrmNotifier].
  const CrmNotifierFamily();

  /// See also [CrmNotifier].
  CrmNotifierProvider call(
    ContactType type,
  ) {
    return CrmNotifierProvider(
      type,
    );
  }

  @override
  CrmNotifierProvider getProviderOverride(
    covariant CrmNotifierProvider provider,
  ) {
    return call(
      provider.type,
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
  String? get name => r'crmNotifierProvider';
}

/// See also [CrmNotifier].
class CrmNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<CrmNotifier, List<Contact>> {
  /// See also [CrmNotifier].
  CrmNotifierProvider(
    ContactType type,
  ) : this._internal(
          () => CrmNotifier()..type = type,
          from: crmNotifierProvider,
          name: r'crmNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$crmNotifierHash,
          dependencies: CrmNotifierFamily._dependencies,
          allTransitiveDependencies:
              CrmNotifierFamily._allTransitiveDependencies,
          type: type,
        );

  CrmNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final ContactType type;

  @override
  FutureOr<List<Contact>> runNotifierBuild(
    covariant CrmNotifier notifier,
  ) {
    return notifier.build(
      type,
    );
  }

  @override
  Override overrideWith(CrmNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CrmNotifierProvider._internal(
        () => create()..type = type,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CrmNotifier, List<Contact>>
      createElement() {
    return _CrmNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CrmNotifierProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CrmNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Contact>> {
  /// The parameter `type` of this provider.
  ContactType get type;
}

class _CrmNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CrmNotifier, List<Contact>>
    with CrmNotifierRef {
  _CrmNotifierProviderElement(super.provider);

  @override
  ContactType get type => (origin as CrmNotifierProvider).type;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
