// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_fixed_cost_by_category_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MonthlyFixedCostByCategoryGroup {
  /// 支出大カテゴリーid（v10で固定費カテゴリーから移行）
  int get expenseBigCategoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get resourcePath => throw _privateConstructorUsedError;
  List<IMonthlyFixedTileValue> get items => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyFixedCostByCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyFixedCostByCategoryGroupCopyWith<MonthlyFixedCostByCategoryGroup>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyFixedCostByCategoryGroupCopyWith<$Res> {
  factory $MonthlyFixedCostByCategoryGroupCopyWith(
    MonthlyFixedCostByCategoryGroup value,
    $Res Function(MonthlyFixedCostByCategoryGroup) then,
  ) =
      _$MonthlyFixedCostByCategoryGroupCopyWithImpl<
        $Res,
        MonthlyFixedCostByCategoryGroup
      >;
  @useResult
  $Res call({
    int expenseBigCategoryId,
    String categoryName,
    String colorCode,
    String resourcePath,
    List<IMonthlyFixedTileValue> items,
  });
}

/// @nodoc
class _$MonthlyFixedCostByCategoryGroupCopyWithImpl<
  $Res,
  $Val extends MonthlyFixedCostByCategoryGroup
>
    implements $MonthlyFixedCostByCategoryGroupCopyWith<$Res> {
  _$MonthlyFixedCostByCategoryGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyFixedCostByCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expenseBigCategoryId = null,
    Object? categoryName = null,
    Object? colorCode = null,
    Object? resourcePath = null,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            expenseBigCategoryId: null == expenseBigCategoryId
                ? _value.expenseBigCategoryId
                : expenseBigCategoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            colorCode: null == colorCode
                ? _value.colorCode
                : colorCode // ignore: cast_nullable_to_non_nullable
                      as String,
            resourcePath: null == resourcePath
                ? _value.resourcePath
                : resourcePath // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<IMonthlyFixedTileValue>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyFixedCostByCategoryGroupImplCopyWith<$Res>
    implements $MonthlyFixedCostByCategoryGroupCopyWith<$Res> {
  factory _$$MonthlyFixedCostByCategoryGroupImplCopyWith(
    _$MonthlyFixedCostByCategoryGroupImpl value,
    $Res Function(_$MonthlyFixedCostByCategoryGroupImpl) then,
  ) = __$$MonthlyFixedCostByCategoryGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int expenseBigCategoryId,
    String categoryName,
    String colorCode,
    String resourcePath,
    List<IMonthlyFixedTileValue> items,
  });
}

/// @nodoc
class __$$MonthlyFixedCostByCategoryGroupImplCopyWithImpl<$Res>
    extends
        _$MonthlyFixedCostByCategoryGroupCopyWithImpl<
          $Res,
          _$MonthlyFixedCostByCategoryGroupImpl
        >
    implements _$$MonthlyFixedCostByCategoryGroupImplCopyWith<$Res> {
  __$$MonthlyFixedCostByCategoryGroupImplCopyWithImpl(
    _$MonthlyFixedCostByCategoryGroupImpl _value,
    $Res Function(_$MonthlyFixedCostByCategoryGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyFixedCostByCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expenseBigCategoryId = null,
    Object? categoryName = null,
    Object? colorCode = null,
    Object? resourcePath = null,
    Object? items = null,
  }) {
    return _then(
      _$MonthlyFixedCostByCategoryGroupImpl(
        expenseBigCategoryId: null == expenseBigCategoryId
            ? _value.expenseBigCategoryId
            : expenseBigCategoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        colorCode: null == colorCode
            ? _value.colorCode
            : colorCode // ignore: cast_nullable_to_non_nullable
                  as String,
        resourcePath: null == resourcePath
            ? _value.resourcePath
            : resourcePath // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<IMonthlyFixedTileValue>,
      ),
    );
  }
}

/// @nodoc

class _$MonthlyFixedCostByCategoryGroupImpl
    implements _MonthlyFixedCostByCategoryGroup {
  const _$MonthlyFixedCostByCategoryGroupImpl({
    required this.expenseBigCategoryId,
    required this.categoryName,
    required this.colorCode,
    required this.resourcePath,
    required final List<IMonthlyFixedTileValue> items,
  }) : _items = items;

  /// 支出大カテゴリーid（v10で固定費カテゴリーから移行）
  @override
  final int expenseBigCategoryId;
  @override
  final String categoryName;
  @override
  final String colorCode;
  @override
  final String resourcePath;
  final List<IMonthlyFixedTileValue> _items;
  @override
  List<IMonthlyFixedTileValue> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'MonthlyFixedCostByCategoryGroup(expenseBigCategoryId: $expenseBigCategoryId, categoryName: $categoryName, colorCode: $colorCode, resourcePath: $resourcePath, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyFixedCostByCategoryGroupImpl &&
            (identical(other.expenseBigCategoryId, expenseBigCategoryId) ||
                other.expenseBigCategoryId == expenseBigCategoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.resourcePath, resourcePath) ||
                other.resourcePath == resourcePath) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    expenseBigCategoryId,
    categoryName,
    colorCode,
    resourcePath,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of MonthlyFixedCostByCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyFixedCostByCategoryGroupImplCopyWith<
    _$MonthlyFixedCostByCategoryGroupImpl
  >
  get copyWith =>
      __$$MonthlyFixedCostByCategoryGroupImplCopyWithImpl<
        _$MonthlyFixedCostByCategoryGroupImpl
      >(this, _$identity);
}

abstract class _MonthlyFixedCostByCategoryGroup
    implements MonthlyFixedCostByCategoryGroup {
  const factory _MonthlyFixedCostByCategoryGroup({
    required final int expenseBigCategoryId,
    required final String categoryName,
    required final String colorCode,
    required final String resourcePath,
    required final List<IMonthlyFixedTileValue> items,
  }) = _$MonthlyFixedCostByCategoryGroupImpl;

  /// 支出大カテゴリーid（v10で固定費カテゴリーから移行）
  @override
  int get expenseBigCategoryId;
  @override
  String get categoryName;
  @override
  String get colorCode;
  @override
  String get resourcePath;
  @override
  List<IMonthlyFixedTileValue> get items;

  /// Create a copy of MonthlyFixedCostByCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyFixedCostByCategoryGroupImplCopyWith<
    _$MonthlyFixedCostByCategoryGroupImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
