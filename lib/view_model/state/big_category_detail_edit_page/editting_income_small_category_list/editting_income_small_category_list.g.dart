// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editting_income_small_category_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$edittingIncomeSmallCategoryListNotifierHash() =>
    r'afe146a79dba076fbba68ca93f7397dfe008c151';

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

abstract class _$EdittingIncomeSmallCategoryListNotifier
    extends BuildlessAutoDisposeNotifier<List<EditIncomeSmallCategoryValue>> {
  late final int bigId;

  List<EditIncomeSmallCategoryValue> build(int bigId);
}

/// See also [EdittingIncomeSmallCategoryListNotifier].
@ProviderFor(EdittingIncomeSmallCategoryListNotifier)
const edittingIncomeSmallCategoryListNotifierProvider =
    EdittingIncomeSmallCategoryListNotifierFamily();

/// See also [EdittingIncomeSmallCategoryListNotifier].
class EdittingIncomeSmallCategoryListNotifierFamily
    extends Family<List<EditIncomeSmallCategoryValue>> {
  /// See also [EdittingIncomeSmallCategoryListNotifier].
  const EdittingIncomeSmallCategoryListNotifierFamily();

  /// See also [EdittingIncomeSmallCategoryListNotifier].
  EdittingIncomeSmallCategoryListNotifierProvider call(int bigId) {
    return EdittingIncomeSmallCategoryListNotifierProvider(bigId);
  }

  @override
  EdittingIncomeSmallCategoryListNotifierProvider getProviderOverride(
    covariant EdittingIncomeSmallCategoryListNotifierProvider provider,
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
  String? get name => r'edittingIncomeSmallCategoryListNotifierProvider';
}

/// See also [EdittingIncomeSmallCategoryListNotifier].
class EdittingIncomeSmallCategoryListNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          EdittingIncomeSmallCategoryListNotifier,
          List<EditIncomeSmallCategoryValue>
        > {
  /// See also [EdittingIncomeSmallCategoryListNotifier].
  EdittingIncomeSmallCategoryListNotifierProvider(int bigId)
    : this._internal(
        () => EdittingIncomeSmallCategoryListNotifier()..bigId = bigId,
        from: edittingIncomeSmallCategoryListNotifierProvider,
        name: r'edittingIncomeSmallCategoryListNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$edittingIncomeSmallCategoryListNotifierHash,
        dependencies:
            EdittingIncomeSmallCategoryListNotifierFamily._dependencies,
        allTransitiveDependencies: EdittingIncomeSmallCategoryListNotifierFamily
            ._allTransitiveDependencies,
        bigId: bigId,
      );

  EdittingIncomeSmallCategoryListNotifierProvider._internal(
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
  List<EditIncomeSmallCategoryValue> runNotifierBuild(
    covariant EdittingIncomeSmallCategoryListNotifier notifier,
  ) {
    return notifier.build(bigId);
  }

  @override
  Override overrideWith(
    EdittingIncomeSmallCategoryListNotifier Function() create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EdittingIncomeSmallCategoryListNotifierProvider._internal(
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
    EdittingIncomeSmallCategoryListNotifier,
    List<EditIncomeSmallCategoryValue>
  >
  createElement() {
    return _EdittingIncomeSmallCategoryListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EdittingIncomeSmallCategoryListNotifierProvider &&
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
mixin EdittingIncomeSmallCategoryListNotifierRef
    on AutoDisposeNotifierProviderRef<List<EditIncomeSmallCategoryValue>> {
  /// The parameter `bigId` of this provider.
  int get bigId;
}

class _EdittingIncomeSmallCategoryListNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          EdittingIncomeSmallCategoryListNotifier,
          List<EditIncomeSmallCategoryValue>
        >
    with EdittingIncomeSmallCategoryListNotifierRef {
  _EdittingIncomeSmallCategoryListNotifierProviderElement(super.provider);

  @override
  int get bigId =>
      (origin as EdittingIncomeSmallCategoryListNotifierProvider).bigId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
