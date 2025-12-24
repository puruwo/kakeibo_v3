// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryByModeHash() => r'e79eddd05cab7809252977dcaca229215dd0141b';

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

/// TransactionModeに応じたカテゴリーを取得するProvider
///
/// [mode] トランザクションの種類（支出、固定費、収入）
/// [categoryId] カテゴリーID
///
/// Copied from [categoryByMode].
@ProviderFor(categoryByMode)
const categoryByModeProvider = CategoryByModeFamily();

/// TransactionModeに応じたカテゴリーを取得するProvider
///
/// [mode] トランザクションの種類（支出、固定費、収入）
/// [categoryId] カテゴリーID
///
/// Copied from [categoryByMode].
class CategoryByModeFamily extends Family<AsyncValue<ICategoryEntity>> {
  /// TransactionModeに応じたカテゴリーを取得するProvider
  ///
  /// [mode] トランザクションの種類（支出、固定費、収入）
  /// [categoryId] カテゴリーID
  ///
  /// Copied from [categoryByMode].
  const CategoryByModeFamily();

  /// TransactionModeに応じたカテゴリーを取得するProvider
  ///
  /// [mode] トランザクションの種類（支出、固定費、収入）
  /// [categoryId] カテゴリーID
  ///
  /// Copied from [categoryByMode].
  CategoryByModeProvider call({
    required TransactionMode mode,
    required int categoryId,
  }) {
    return CategoryByModeProvider(
      mode: mode,
      categoryId: categoryId,
    );
  }

  @override
  CategoryByModeProvider getProviderOverride(
    covariant CategoryByModeProvider provider,
  ) {
    return call(
      mode: provider.mode,
      categoryId: provider.categoryId,
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
  String? get name => r'categoryByModeProvider';
}

/// TransactionModeに応じたカテゴリーを取得するProvider
///
/// [mode] トランザクションの種類（支出、固定費、収入）
/// [categoryId] カテゴリーID
///
/// Copied from [categoryByMode].
class CategoryByModeProvider
    extends AutoDisposeFutureProvider<ICategoryEntity> {
  /// TransactionModeに応じたカテゴリーを取得するProvider
  ///
  /// [mode] トランザクションの種類（支出、固定費、収入）
  /// [categoryId] カテゴリーID
  ///
  /// Copied from [categoryByMode].
  CategoryByModeProvider({
    required TransactionMode mode,
    required int categoryId,
  }) : this._internal(
          (ref) => categoryByMode(
            ref as CategoryByModeRef,
            mode: mode,
            categoryId: categoryId,
          ),
          from: categoryByModeProvider,
          name: r'categoryByModeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryByModeHash,
          dependencies: CategoryByModeFamily._dependencies,
          allTransitiveDependencies:
              CategoryByModeFamily._allTransitiveDependencies,
          mode: mode,
          categoryId: categoryId,
        );

  CategoryByModeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mode,
    required this.categoryId,
  }) : super.internal();

  final TransactionMode mode;
  final int categoryId;

  @override
  Override overrideWith(
    FutureOr<ICategoryEntity> Function(CategoryByModeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryByModeProvider._internal(
        (ref) => create(ref as CategoryByModeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mode: mode,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ICategoryEntity> createElement() {
    return _CategoryByModeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryByModeProvider &&
        other.mode == mode &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryByModeRef on AutoDisposeFutureProviderRef<ICategoryEntity> {
  /// The parameter `mode` of this provider.
  TransactionMode get mode;

  /// The parameter `categoryId` of this provider.
  int get categoryId;
}

class _CategoryByModeProviderElement
    extends AutoDisposeFutureProviderElement<ICategoryEntity>
    with CategoryByModeRef {
  _CategoryByModeProviderElement(super.provider);

  @override
  TransactionMode get mode => (origin as CategoryByModeProvider).mode;
  @override
  int get categoryId => (origin as CategoryByModeProvider).categoryId;
}

String _$categoriesByModeHash() => r'43918e7d150eca7e6aa735c3fc4749498cfd61ed';

/// TransactionModeに応じたカテゴリーリストを取得するProvider
///
/// [mode] トランザクションの種類（支出、固定費、収入）
///
/// Copied from [categoriesByMode].
@ProviderFor(categoriesByMode)
const categoriesByModeProvider = CategoriesByModeFamily();

/// TransactionModeに応じたカテゴリーリストを取得するProvider
///
/// [mode] トランザクションの種類（支出、固定費、収入）
///
/// Copied from [categoriesByMode].
class CategoriesByModeFamily extends Family<AsyncValue<List<ICategoryEntity>>> {
  /// TransactionModeに応じたカテゴリーリストを取得するProvider
  ///
  /// [mode] トランザクションの種類（支出、固定費、収入）
  ///
  /// Copied from [categoriesByMode].
  const CategoriesByModeFamily();

  /// TransactionModeに応じたカテゴリーリストを取得するProvider
  ///
  /// [mode] トランザクションの種類（支出、固定費、収入）
  ///
  /// Copied from [categoriesByMode].
  CategoriesByModeProvider call(
    TransactionMode mode,
  ) {
    return CategoriesByModeProvider(
      mode,
    );
  }

  @override
  CategoriesByModeProvider getProviderOverride(
    covariant CategoriesByModeProvider provider,
  ) {
    return call(
      provider.mode,
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
  String? get name => r'categoriesByModeProvider';
}

/// TransactionModeに応じたカテゴリーリストを取得するProvider
///
/// [mode] トランザクションの種類（支出、固定費、収入）
///
/// Copied from [categoriesByMode].
class CategoriesByModeProvider
    extends AutoDisposeFutureProvider<List<ICategoryEntity>> {
  /// TransactionModeに応じたカテゴリーリストを取得するProvider
  ///
  /// [mode] トランザクションの種類（支出、固定費、収入）
  ///
  /// Copied from [categoriesByMode].
  CategoriesByModeProvider(
    TransactionMode mode,
  ) : this._internal(
          (ref) => categoriesByMode(
            ref as CategoriesByModeRef,
            mode,
          ),
          from: categoriesByModeProvider,
          name: r'categoriesByModeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoriesByModeHash,
          dependencies: CategoriesByModeFamily._dependencies,
          allTransitiveDependencies:
              CategoriesByModeFamily._allTransitiveDependencies,
          mode: mode,
        );

  CategoriesByModeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mode,
  }) : super.internal();

  final TransactionMode mode;

  @override
  Override overrideWith(
    FutureOr<List<ICategoryEntity>> Function(CategoriesByModeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoriesByModeProvider._internal(
        (ref) => create(ref as CategoriesByModeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mode: mode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ICategoryEntity>> createElement() {
    return _CategoriesByModeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesByModeProvider && other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoriesByModeRef
    on AutoDisposeFutureProviderRef<List<ICategoryEntity>> {
  /// The parameter `mode` of this provider.
  TransactionMode get mode;
}

class _CategoriesByModeProviderElement
    extends AutoDisposeFutureProviderElement<List<ICategoryEntity>>
    with CategoriesByModeRef {
  _CategoriesByModeProviderElement(super.provider);

  @override
  TransactionMode get mode => (origin as CategoriesByModeProvider).mode;
}

String _$categoryPaginationHash() =>
    r'0ac5b566defd87b28698171490a0ad950db1553f';

/// ページネーション情報を計算するProvider
///
/// [categoryCount] カテゴリーの総数
///
/// Copied from [categoryPagination].
@ProviderFor(categoryPagination)
const categoryPaginationProvider = CategoryPaginationFamily();

/// ページネーション情報を計算するProvider
///
/// [categoryCount] カテゴリーの総数
///
/// Copied from [categoryPagination].
class CategoryPaginationFamily extends Family<CategoryPagination> {
  /// ページネーション情報を計算するProvider
  ///
  /// [categoryCount] カテゴリーの総数
  ///
  /// Copied from [categoryPagination].
  const CategoryPaginationFamily();

  /// ページネーション情報を計算するProvider
  ///
  /// [categoryCount] カテゴリーの総数
  ///
  /// Copied from [categoryPagination].
  CategoryPaginationProvider call(
    int categoryCount,
  ) {
    return CategoryPaginationProvider(
      categoryCount,
    );
  }

  @override
  CategoryPaginationProvider getProviderOverride(
    covariant CategoryPaginationProvider provider,
  ) {
    return call(
      provider.categoryCount,
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
  String? get name => r'categoryPaginationProvider';
}

/// ページネーション情報を計算するProvider
///
/// [categoryCount] カテゴリーの総数
///
/// Copied from [categoryPagination].
class CategoryPaginationProvider
    extends AutoDisposeProvider<CategoryPagination> {
  /// ページネーション情報を計算するProvider
  ///
  /// [categoryCount] カテゴリーの総数
  ///
  /// Copied from [categoryPagination].
  CategoryPaginationProvider(
    int categoryCount,
  ) : this._internal(
          (ref) => categoryPagination(
            ref as CategoryPaginationRef,
            categoryCount,
          ),
          from: categoryPaginationProvider,
          name: r'categoryPaginationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryPaginationHash,
          dependencies: CategoryPaginationFamily._dependencies,
          allTransitiveDependencies:
              CategoryPaginationFamily._allTransitiveDependencies,
          categoryCount: categoryCount,
        );

  CategoryPaginationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryCount,
  }) : super.internal();

  final int categoryCount;

  @override
  Override overrideWith(
    CategoryPagination Function(CategoryPaginationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryPaginationProvider._internal(
        (ref) => create(ref as CategoryPaginationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryCount: categoryCount,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<CategoryPagination> createElement() {
    return _CategoryPaginationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryPaginationProvider &&
        other.categoryCount == categoryCount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryCount.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryPaginationRef on AutoDisposeProviderRef<CategoryPagination> {
  /// The parameter `categoryCount` of this provider.
  int get categoryCount;
}

class _CategoryPaginationProviderElement
    extends AutoDisposeProviderElement<CategoryPagination>
    with CategoryPaginationRef {
  _CategoryPaginationProviderElement(super.provider);

  @override
  int get categoryCount => (origin as CategoryPaginationProvider).categoryCount;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
