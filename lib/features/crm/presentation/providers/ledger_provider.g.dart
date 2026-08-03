// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ledgerNotifierHash() => r'3245d443d0154334861fcf34e9ad2615364e6907';

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

abstract class _$LedgerNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<LedgerEntry>> {
  late final String contactId;

  FutureOr<List<LedgerEntry>> build(
    String contactId,
  );
}

/// See also [LedgerNotifier].
@ProviderFor(LedgerNotifier)
const ledgerNotifierProvider = LedgerNotifierFamily();

/// See also [LedgerNotifier].
class LedgerNotifierFamily extends Family<AsyncValue<List<LedgerEntry>>> {
  /// See also [LedgerNotifier].
  const LedgerNotifierFamily();

  /// See also [LedgerNotifier].
  LedgerNotifierProvider call(
    String contactId,
  ) {
    return LedgerNotifierProvider(
      contactId,
    );
  }

  @override
  LedgerNotifierProvider getProviderOverride(
    covariant LedgerNotifierProvider provider,
  ) {
    return call(
      provider.contactId,
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
  String? get name => r'ledgerNotifierProvider';
}

/// See also [LedgerNotifier].
class LedgerNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    LedgerNotifier, List<LedgerEntry>> {
  /// See also [LedgerNotifier].
  LedgerNotifierProvider(
    String contactId,
  ) : this._internal(
          () => LedgerNotifier()..contactId = contactId,
          from: ledgerNotifierProvider,
          name: r'ledgerNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ledgerNotifierHash,
          dependencies: LedgerNotifierFamily._dependencies,
          allTransitiveDependencies:
              LedgerNotifierFamily._allTransitiveDependencies,
          contactId: contactId,
        );

  LedgerNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
  }) : super.internal();

  final String contactId;

  @override
  FutureOr<List<LedgerEntry>> runNotifierBuild(
    covariant LedgerNotifier notifier,
  ) {
    return notifier.build(
      contactId,
    );
  }

  @override
  Override overrideWith(LedgerNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: LedgerNotifierProvider._internal(
        () => create()..contactId = contactId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<LedgerNotifier, List<LedgerEntry>>
      createElement() {
    return _LedgerNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LedgerNotifierProvider && other.contactId == contactId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LedgerNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<LedgerEntry>> {
  /// The parameter `contactId` of this provider.
  String get contactId;
}

class _LedgerNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<LedgerNotifier,
        List<LedgerEntry>> with LedgerNotifierRef {
  _LedgerNotifierProviderElement(super.provider);

  @override
  String get contactId => (origin as LedgerNotifierProvider).contactId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
