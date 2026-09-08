// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editting_small_category_edit_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$edittingSmallCategoryListNotifierHash() =>
    r'64e25858f694dfdb8c43a5023e3227ec16a001be';

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

abstract class _$EdittingSmallCategoryListNotifier
    extends BuildlessAutoDisposeNotifier<List<EditExpenseSmallCategoryValue>> {
  late final int bigId;

  List<EditExpenseSmallCategoryValue> build(int bigId);
}

/// See also [EdittingSmallCategoryListNotifier].
@ProviderFor(EdittingSmallCategoryListNotifier)
const edittingSmallCategoryListNotifierProvider =
    EdittingSmallCategoryListNotifierFamily();

/// See also [EdittingSmallCategoryListNotifier].
class EdittingSmallCategoryListNotifierFamily
    extends Family<List<EditExpenseSmallCategoryValue>> {
  /// See also [EdittingSmallCategoryListNotifier].
  const EdittingSmallCategoryListNotifierFamily();

  /// See also [EdittingSmallCategoryListNotifier].
  EdittingSmallCategoryListNotifierProvider call(int bigId) {
    return EdittingSmallCategoryListNotifierProvider(bigId);
  }

  @override
  EdittingSmallCategoryListNotifierProvider getProviderOverride(
    covariant EdittingSmallCategoryListNotifierProvider provider,
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
  String? get name => r'edittingSmallCategoryListNotifierProvider';
}

/// See also [EdittingSmallCategoryListNotifier].
class EdittingSmallCategoryListNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          EdittingSmallCategoryListNotifier,
          List<EditExpenseSmallCategoryValue>
        > {
  /// See also [EdittingSmallCategoryListNotifier].
  EdittingSmallCategoryListNotifierProvider(int bigId)
    : this._internal(
        () => EdittingSmallCategoryListNotifier()..bigId = bigId,
        from: edittingSmallCategoryListNotifierProvider,
        name: r'edittingSmallCategoryListNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$edittingSmallCategoryListNotifierHash,
        dependencies: EdittingSmallCategoryListNotifierFamily._dependencies,
        allTransitiveDependencies:
            EdittingSmallCategoryListNotifierFamily._allTransitiveDependencies,
        bigId: bigId,
      );

  EdittingSmallCategoryListNotifierProvider._internal(
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
  List<EditExpenseSmallCategoryValue> runNotifierBuild(
    covariant EdittingSmallCategoryListNotifier notifier,
  ) {
    return notifier.build(bigId);
  }

  @override
  Override overrideWith(EdittingSmallCategoryListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: EdittingSmallCategoryListNotifierProvider._internal(
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
    EdittingSmallCategoryListNotifier,
    List<EditExpenseSmallCategoryValue>
  >
  createElement() {
    return _EdittingSmallCategoryListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EdittingSmallCategoryListNotifierProvider &&
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
mixin EdittingSmallCategoryListNotifierRef
    on AutoDisposeNotifierProviderRef<List<EditExpenseSmallCategoryValue>> {
  /// The parameter `bigId` of this provider.
  int get bigId;
}

class _EdittingSmallCategoryListNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          EdittingSmallCategoryListNotifier,
          List<EditExpenseSmallCategoryValue>
        >
    with EdittingSmallCategoryListNotifierRef {
  _EdittingSmallCategoryListNotifierProviderElement(super.provider);

  @override
  int get bigId => (origin as EdittingSmallCategoryListNotifierProvider).bigId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
