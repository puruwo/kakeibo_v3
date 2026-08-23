// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fixed_cost_registration_list_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FixedCostRegistrationListValue {
  List<ExpenseBigCategoryGroup> get categoryGroups =>
      throw _privateConstructorUsedError;

  /// Create a copy of FixedCostRegistrationListValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FixedCostRegistrationListValueCopyWith<FixedCostRegistrationListValue>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FixedCostRegistrationListValueCopyWith<$Res> {
  factory $FixedCostRegistrationListValueCopyWith(
    FixedCostRegistrationListValue value,
    $Res Function(FixedCostRegistrationListValue) then,
  ) =
      _$FixedCostRegistrationListValueCopyWithImpl<
        $Res,
        FixedCostRegistrationListValue
      >;
  @useResult
  $Res call({List<ExpenseBigCategoryGroup> categoryGroups});
}

/// @nodoc
class _$FixedCostRegistrationListValueCopyWithImpl<
  $Res,
  $Val extends FixedCostRegistrationListValue
>
    implements $FixedCostRegistrationListValueCopyWith<$Res> {
  _$FixedCostRegistrationListValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FixedCostRegistrationListValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? categoryGroups = null}) {
    return _then(
      _value.copyWith(
            categoryGroups: null == categoryGroups
                ? _value.categoryGroups
                : categoryGroups // ignore: cast_nullable_to_non_nullable
                      as List<ExpenseBigCategoryGroup>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FixedCostRegistrationListValueImplCopyWith<$Res>
    implements $FixedCostRegistrationListValueCopyWith<$Res> {
  factory _$$FixedCostRegistrationListValueImplCopyWith(
    _$FixedCostRegistrationListValueImpl value,
    $Res Function(_$FixedCostRegistrationListValueImpl) then,
  ) = __$$FixedCostRegistrationListValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ExpenseBigCategoryGroup> categoryGroups});
}

/// @nodoc
class __$$FixedCostRegistrationListValueImplCopyWithImpl<$Res>
    extends
        _$FixedCostRegistrationListValueCopyWithImpl<
          $Res,
          _$FixedCostRegistrationListValueImpl
        >
    implements _$$FixedCostRegistrationListValueImplCopyWith<$Res> {
  __$$FixedCostRegistrationListValueImplCopyWithImpl(
    _$FixedCostRegistrationListValueImpl _value,
    $Res Function(_$FixedCostRegistrationListValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FixedCostRegistrationListValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? categoryGroups = null}) {
    return _then(
      _$FixedCostRegistrationListValueImpl(
        categoryGroups: null == categoryGroups
            ? _value._categoryGroups
            : categoryGroups // ignore: cast_nullable_to_non_nullable
                  as List<ExpenseBigCategoryGroup>,
      ),
    );
  }
}

/// @nodoc

class _$FixedCostRegistrationListValueImpl
    implements _FixedCostRegistrationListValue {
  const _$FixedCostRegistrationListValueImpl({
    required final List<ExpenseBigCategoryGroup> categoryGroups,
  }) : _categoryGroups = categoryGroups;

  final List<ExpenseBigCategoryGroup> _categoryGroups;
  @override
  List<ExpenseBigCategoryGroup> get categoryGroups {
    if (_categoryGroups is EqualUnmodifiableListView) return _categoryGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoryGroups);
  }

  @override
  String toString() {
    return 'FixedCostRegistrationListValue(categoryGroups: $categoryGroups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FixedCostRegistrationListValueImpl &&
            const DeepCollectionEquality().equals(
              other._categoryGroups,
              _categoryGroups,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_categoryGroups),
  );

  /// Create a copy of FixedCostRegistrationListValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FixedCostRegistrationListValueImplCopyWith<
    _$FixedCostRegistrationListValueImpl
  >
  get copyWith =>
      __$$FixedCostRegistrationListValueImplCopyWithImpl<
        _$FixedCostRegistrationListValueImpl
      >(this, _$identity);
}

abstract class _FixedCostRegistrationListValue
    implements FixedCostRegistrationListValue {
  const factory _FixedCostRegistrationListValue({
    required final List<ExpenseBigCategoryGroup> categoryGroups,
  }) = _$FixedCostRegistrationListValueImpl;

  @override
  List<ExpenseBigCategoryGroup> get categoryGroups;

  /// Create a copy of FixedCostRegistrationListValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FixedCostRegistrationListValueImplCopyWith<
    _$FixedCostRegistrationListValueImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExpenseBigCategoryGroup {
  int get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String get categoryIconPath => throw _privateConstructorUsedError;
  String get categoryColorCode => throw _privateConstructorUsedError;
  List<FixedCostEntity> get items => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseBigCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseBigCategoryGroupCopyWith<ExpenseBigCategoryGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseBigCategoryGroupCopyWith<$Res> {
  factory $ExpenseBigCategoryGroupCopyWith(
    ExpenseBigCategoryGroup value,
    $Res Function(ExpenseBigCategoryGroup) then,
  ) = _$ExpenseBigCategoryGroupCopyWithImpl<$Res, ExpenseBigCategoryGroup>;
  @useResult
  $Res call({
    int categoryId,
    String categoryName,
    String categoryIconPath,
    String categoryColorCode,
    List<FixedCostEntity> items,
  });
}

/// @nodoc
class _$ExpenseBigCategoryGroupCopyWithImpl<
  $Res,
  $Val extends ExpenseBigCategoryGroup
>
    implements $ExpenseBigCategoryGroupCopyWith<$Res> {
  _$ExpenseBigCategoryGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseBigCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? categoryName = null,
    Object? categoryIconPath = null,
    Object? categoryColorCode = null,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryIconPath: null == categoryIconPath
                ? _value.categoryIconPath
                : categoryIconPath // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryColorCode: null == categoryColorCode
                ? _value.categoryColorCode
                : categoryColorCode // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<FixedCostEntity>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpenseBigCategoryGroupImplCopyWith<$Res>
    implements $ExpenseBigCategoryGroupCopyWith<$Res> {
  factory _$$ExpenseBigCategoryGroupImplCopyWith(
    _$ExpenseBigCategoryGroupImpl value,
    $Res Function(_$ExpenseBigCategoryGroupImpl) then,
  ) = __$$ExpenseBigCategoryGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int categoryId,
    String categoryName,
    String categoryIconPath,
    String categoryColorCode,
    List<FixedCostEntity> items,
  });
}

/// @nodoc
class __$$ExpenseBigCategoryGroupImplCopyWithImpl<$Res>
    extends
        _$ExpenseBigCategoryGroupCopyWithImpl<
          $Res,
          _$ExpenseBigCategoryGroupImpl
        >
    implements _$$ExpenseBigCategoryGroupImplCopyWith<$Res> {
  __$$ExpenseBigCategoryGroupImplCopyWithImpl(
    _$ExpenseBigCategoryGroupImpl _value,
    $Res Function(_$ExpenseBigCategoryGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseBigCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? categoryName = null,
    Object? categoryIconPath = null,
    Object? categoryColorCode = null,
    Object? items = null,
  }) {
    return _then(
      _$ExpenseBigCategoryGroupImpl(
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryIconPath: null == categoryIconPath
            ? _value.categoryIconPath
            : categoryIconPath // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryColorCode: null == categoryColorCode
            ? _value.categoryColorCode
            : categoryColorCode // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<FixedCostEntity>,
      ),
    );
  }
}

/// @nodoc

class _$ExpenseBigCategoryGroupImpl implements _ExpenseBigCategoryGroup {
  const _$ExpenseBigCategoryGroupImpl({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconPath,
    required this.categoryColorCode,
    required final List<FixedCostEntity> items,
  }) : _items = items;

  @override
  final int categoryId;
  @override
  final String categoryName;
  @override
  final String categoryIconPath;
  @override
  final String categoryColorCode;
  final List<FixedCostEntity> _items;
  @override
  List<FixedCostEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'ExpenseBigCategoryGroup(categoryId: $categoryId, categoryName: $categoryName, categoryIconPath: $categoryIconPath, categoryColorCode: $categoryColorCode, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseBigCategoryGroupImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.categoryIconPath, categoryIconPath) ||
                other.categoryIconPath == categoryIconPath) &&
            (identical(other.categoryColorCode, categoryColorCode) ||
                other.categoryColorCode == categoryColorCode) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    categoryId,
    categoryName,
    categoryIconPath,
    categoryColorCode,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of ExpenseBigCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseBigCategoryGroupImplCopyWith<_$ExpenseBigCategoryGroupImpl>
  get copyWith =>
      __$$ExpenseBigCategoryGroupImplCopyWithImpl<
        _$ExpenseBigCategoryGroupImpl
      >(this, _$identity);
}

abstract class _ExpenseBigCategoryGroup implements ExpenseBigCategoryGroup {
  const factory _ExpenseBigCategoryGroup({
    required final int categoryId,
    required final String categoryName,
    required final String categoryIconPath,
    required final String categoryColorCode,
    required final List<FixedCostEntity> items,
  }) = _$ExpenseBigCategoryGroupImpl;

  @override
  int get categoryId;
  @override
  String get categoryName;
  @override
  String get categoryIconPath;
  @override
  String get categoryColorCode;
  @override
  List<FixedCostEntity> get items;

  /// Create a copy of ExpenseBigCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseBigCategoryGroupImplCopyWith<_$ExpenseBigCategoryGroupImpl>
  get copyWith => throw _privateConstructorUsedError;
}
