// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_accounting_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CategoryAccountingEntity _$CategoryAccountingEntityFromJson(
    Map<String, dynamic> json) {
  return _CategoryAccountingEntity.fromJson(json);
}

/// @nodoc
mixin _$CategoryAccountingEntity {
  int get id => throw _privateConstructorUsedError;
  String get categoryColor => throw _privateConstructorUsedError;
  String get bigCategoryName => throw _privateConstructorUsedError;
  String get categoryIconPath => throw _privateConstructorUsedError;
  int get totalExpenseByBigCategory => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CategoryAccountingEntityCopyWith<CategoryAccountingEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryAccountingEntityCopyWith<$Res> {
  factory $CategoryAccountingEntityCopyWith(CategoryAccountingEntity value,
          $Res Function(CategoryAccountingEntity) then) =
      _$CategoryAccountingEntityCopyWithImpl<$Res, CategoryAccountingEntity>;
  @useResult
  $Res call(
      {int id,
      String categoryColor,
      String bigCategoryName,
      String categoryIconPath,
      int totalExpenseByBigCategory});
}

/// @nodoc
class _$CategoryAccountingEntityCopyWithImpl<$Res,
        $Val extends CategoryAccountingEntity>
    implements $CategoryAccountingEntityCopyWith<$Res> {
  _$CategoryAccountingEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryColor = null,
    Object? bigCategoryName = null,
    Object? categoryIconPath = null,
    Object? totalExpenseByBigCategory = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      categoryColor: null == categoryColor
          ? _value.categoryColor
          : categoryColor // ignore: cast_nullable_to_non_nullable
              as String,
      bigCategoryName: null == bigCategoryName
          ? _value.bigCategoryName
          : bigCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      categoryIconPath: null == categoryIconPath
          ? _value.categoryIconPath
          : categoryIconPath // ignore: cast_nullable_to_non_nullable
              as String,
      totalExpenseByBigCategory: null == totalExpenseByBigCategory
          ? _value.totalExpenseByBigCategory
          : totalExpenseByBigCategory // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryAccountingEntityImplCopyWith<$Res>
    implements $CategoryAccountingEntityCopyWith<$Res> {
  factory _$$CategoryAccountingEntityImplCopyWith(
          _$CategoryAccountingEntityImpl value,
          $Res Function(_$CategoryAccountingEntityImpl) then) =
      __$$CategoryAccountingEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String categoryColor,
      String bigCategoryName,
      String categoryIconPath,
      int totalExpenseByBigCategory});
}

/// @nodoc
class __$$CategoryAccountingEntityImplCopyWithImpl<$Res>
    extends _$CategoryAccountingEntityCopyWithImpl<$Res,
        _$CategoryAccountingEntityImpl>
    implements _$$CategoryAccountingEntityImplCopyWith<$Res> {
  __$$CategoryAccountingEntityImplCopyWithImpl(
      _$CategoryAccountingEntityImpl _value,
      $Res Function(_$CategoryAccountingEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryColor = null,
    Object? bigCategoryName = null,
    Object? categoryIconPath = null,
    Object? totalExpenseByBigCategory = null,
  }) {
    return _then(_$CategoryAccountingEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      categoryColor: null == categoryColor
          ? _value.categoryColor
          : categoryColor // ignore: cast_nullable_to_non_nullable
              as String,
      bigCategoryName: null == bigCategoryName
          ? _value.bigCategoryName
          : bigCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      categoryIconPath: null == categoryIconPath
          ? _value.categoryIconPath
          : categoryIconPath // ignore: cast_nullable_to_non_nullable
              as String,
      totalExpenseByBigCategory: null == totalExpenseByBigCategory
          ? _value.totalExpenseByBigCategory
          : totalExpenseByBigCategory // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryAccountingEntityImpl implements _CategoryAccountingEntity {
  const _$CategoryAccountingEntityImpl(
      {this.id = 0,
      required this.categoryColor,
      required this.bigCategoryName,
      required this.categoryIconPath,
      this.totalExpenseByBigCategory = 0});

  factory _$CategoryAccountingEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryAccountingEntityImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  final String categoryColor;
  @override
  final String bigCategoryName;
  @override
  final String categoryIconPath;
  @override
  @JsonKey()
  final int totalExpenseByBigCategory;

  @override
  String toString() {
    return 'CategoryAccountingEntity(id: $id, categoryColor: $categoryColor, bigCategoryName: $bigCategoryName, categoryIconPath: $categoryIconPath, totalExpenseByBigCategory: $totalExpenseByBigCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryAccountingEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryColor, categoryColor) ||
                other.categoryColor == categoryColor) &&
            (identical(other.bigCategoryName, bigCategoryName) ||
                other.bigCategoryName == bigCategoryName) &&
            (identical(other.categoryIconPath, categoryIconPath) ||
                other.categoryIconPath == categoryIconPath) &&
            (identical(other.totalExpenseByBigCategory,
                    totalExpenseByBigCategory) ||
                other.totalExpenseByBigCategory == totalExpenseByBigCategory));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, categoryColor,
      bigCategoryName, categoryIconPath, totalExpenseByBigCategory);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryAccountingEntityImplCopyWith<_$CategoryAccountingEntityImpl>
      get copyWith => __$$CategoryAccountingEntityImplCopyWithImpl<
          _$CategoryAccountingEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryAccountingEntityImplToJson(
      this,
    );
  }
}

abstract class _CategoryAccountingEntity implements CategoryAccountingEntity {
  const factory _CategoryAccountingEntity(
      {final int id,
      required final String categoryColor,
      required final String bigCategoryName,
      required final String categoryIconPath,
      final int totalExpenseByBigCategory}) = _$CategoryAccountingEntityImpl;

  factory _CategoryAccountingEntity.fromJson(Map<String, dynamic> json) =
      _$CategoryAccountingEntityImpl.fromJson;

  @override
  int get id;
  @override
  String get categoryColor;
  @override
  String get bigCategoryName;
  @override
  String get categoryIconPath;
  @override
  int get totalExpenseByBigCategory;
  @override
  @JsonKey(ignore: true)
  _$$CategoryAccountingEntityImplCopyWith<_$CategoryAccountingEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
