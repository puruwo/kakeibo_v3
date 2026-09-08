// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_small_category_list_edited.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isSmallCategoryListEditedNotifierHash() =>
    r'371a60ab8b4c7b33d955c6a16993cf3e526eab56';

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

abstract class _$IsSmallCategoryListEditedNotifier
    extends BuildlessAutoDisposeNotifier<bool> {
  late final int bigId;

  bool build(int bigId);
}

/// See also [IsSmallCategoryListEditedNotifier].
@ProviderFor(IsSmallCategoryListEditedNotifier)
const isSmallCategoryListEditedNotifierProvider =
    IsSmallCategoryListEditedNotifierFamily();

/// See also [IsSmallCategoryListEditedNotifier].
class IsSmallCategoryListEditedNotifierFamily extends Family<bool> {
  /// See also [IsSmallCategoryListEditedNotifier].
  const IsSmallCategoryListEditedNotifierFamily();

  /// See also [IsSmallCategoryListEditedNotifier].
  IsSmallCategoryListEditedNotifierProvider call(int bigId) {
    return IsSmallCategoryListEditedNotifierProvider(bigId);
  }

  @override
  IsSmallCategoryListEditedNotifierProvider getProviderOverride(
    covariant IsSmallCategoryListEditedNotifierProvider provider,
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
  String? get name => r'isSmallCategoryListEditedNotifierProvider';
}

/// See also [IsSmallCategoryListEditedNotifier].
class IsSmallCategoryListEditedNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          IsSmallCategoryListEditedNotifier,
          bool
        > {
  /// See also [IsSmallCategoryListEditedNotifier].
  IsSmallCategoryListEditedNotifierProvider(int bigId)
    : this._internal(
        () => IsSmallCategoryListEditedNotifier()..bigId = bigId,
        from: isSmallCategoryListEditedNotifierProvider,
        name: r'isSmallCategoryListEditedNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isSmallCategoryListEditedNotifierHash,
        dependencies: IsSmallCategoryListEditedNotifierFamily._dependencies,
        allTransitiveDependencies:
            IsSmallCategoryListEditedNotifierFamily._allTransitiveDependencies,
        bigId: bigId,
      );

  IsSmallCategoryListEditedNotifierProvider._internal(
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
  bool runNotifierBuild(covariant IsSmallCategoryListEditedNotifier notifier) {
    return notifier.build(bigId);
  }

  @override
  Override overrideWith(IsSmallCategoryListEditedNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: IsSmallCategoryListEditedNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<IsSmallCategoryListEditedNotifier, bool>
  createElement() {
    return _IsSmallCategoryListEditedNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsSmallCategoryListEditedNotifierProvider &&
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
mixin IsSmallCategoryListEditedNotifierRef
    on AutoDisposeNotifierProviderRef<bool> {
  /// The parameter `bigId` of this provider.
  int get bigId;
}

class _IsSmallCategoryListEditedNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          IsSmallCategoryListEditedNotifier,
          bool
        >
    with IsSmallCategoryListEditedNotifierRef {
  _IsSmallCategoryListEditedNotifierProviderElement(super.provider);

  @override
  int get bigId => (origin as IsSmallCategoryListEditedNotifierProvider).bigId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
