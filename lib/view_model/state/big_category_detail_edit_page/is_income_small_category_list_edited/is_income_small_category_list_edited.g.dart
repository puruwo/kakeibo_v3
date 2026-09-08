// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_income_small_category_list_edited.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isIncomeSmallCategoryListEditedNotifierHash() =>
    r'9a81ac67d7b4d59f3b108cd8ccdfb51eb5fc2ef5';

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

abstract class _$IsIncomeSmallCategoryListEditedNotifier
    extends BuildlessAutoDisposeNotifier<bool> {
  late final int bigId;

  bool build(int bigId);
}

/// See also [IsIncomeSmallCategoryListEditedNotifier].
@ProviderFor(IsIncomeSmallCategoryListEditedNotifier)
const isIncomeSmallCategoryListEditedNotifierProvider =
    IsIncomeSmallCategoryListEditedNotifierFamily();

/// See also [IsIncomeSmallCategoryListEditedNotifier].
class IsIncomeSmallCategoryListEditedNotifierFamily extends Family<bool> {
  /// See also [IsIncomeSmallCategoryListEditedNotifier].
  const IsIncomeSmallCategoryListEditedNotifierFamily();

  /// See also [IsIncomeSmallCategoryListEditedNotifier].
  IsIncomeSmallCategoryListEditedNotifierProvider call(int bigId) {
    return IsIncomeSmallCategoryListEditedNotifierProvider(bigId);
  }

  @override
  IsIncomeSmallCategoryListEditedNotifierProvider getProviderOverride(
    covariant IsIncomeSmallCategoryListEditedNotifierProvider provider,
  ) {
    return call(provider.bigId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isIncomeSmallCategoryListEditedNotifierProvider';
}

/// See also [IsIncomeSmallCategoryListEditedNotifier].
class IsIncomeSmallCategoryListEditedNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          IsIncomeSmallCategoryListEditedNotifier,
          bool
        > {
  /// See also [IsIncomeSmallCategoryListEditedNotifier].
  IsIncomeSmallCategoryListEditedNotifierProvider(int bigId)
    : this._internal(
        () => IsIncomeSmallCategoryListEditedNotifier()..bigId = bigId,
        from: isIncomeSmallCategoryListEditedNotifierProvider,
        name: r'isIncomeSmallCategoryListEditedNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isIncomeSmallCategoryListEditedNotifierHash,
        dependencies:
            IsIncomeSmallCategoryListEditedNotifierFamily._dependencies,
        allTransitiveDependencies: IsIncomeSmallCategoryListEditedNotifierFamily
            ._allTransitiveDependencies,
        bigId: bigId,
      );

  IsIncomeSmallCategoryListEditedNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bigId,
  }) : super.internal();

  final int bigId;

  @override
  bool runNotifierBuild(
    covariant IsIncomeSmallCategoryListEditedNotifier notifier,
  ) {
    return notifier.build(bigId);
  }

  @override
  Override overrideWith(
    IsIncomeSmallCategoryListEditedNotifier Function() create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsIncomeSmallCategoryListEditedNotifierProvider._internal(
        () => create()..bigId = bigId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bigId: bigId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    IsIncomeSmallCategoryListEditedNotifier,
    bool
  >
  createElement() {
    return _IsIncomeSmallCategoryListEditedNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsIncomeSmallCategoryListEditedNotifierProvider &&
        other.bigId == bigId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bigId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsIncomeSmallCategoryListEditedNotifierRef
    on AutoDisposeNotifierProviderRef<bool> {
  /// The parameter `bigId` of this provider.
  int get bigId;
}

class _IsIncomeSmallCategoryListEditedNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          IsIncomeSmallCategoryListEditedNotifier,
          bool
        >
    with IsIncomeSmallCategoryListEditedNotifierRef {
  _IsIncomeSmallCategoryListEditedNotifierProviderElement(super.provider);

  @override
  int get bigId =>
      (origin as IsIncomeSmallCategoryListEditedNotifierProvider).bigId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
