// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'income_category_accounting_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$IncomeCategoryAccountingEntity {
  int get id => throw _privateConstructorUsedError;
  String get smallCategoryName => throw _privateConstructorUsedError;
  int get totalIncomeBySmallCategory => throw _privateConstructorUsedError;
  String get categoryIconPath => throw _privateConstructorUsedError;
  String get categoryColor => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IncomeCategoryAccountingEntityCopyWith<IncomeCategoryAccountingEntity>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeCategoryAccountingEntityCopyWith<$Res> {
  factory $IncomeCategoryAccountingEntityCopyWith(
          IncomeCategoryAccountingEntity value,
          $Res Function(IncomeCategoryAccountingEntity) then) =
      _$IncomeCategoryAccountingEntityCopyWithImpl<$Res,
          IncomeCategoryAccountingEntity>;
  @useResult
  $Res call(
      {int id,
      String smallCategoryName,
      int totalIncomeBySmallCategory,
      String categoryIconPath,
      String categoryColor});
}

/// @nodoc
class _$IncomeCategoryAccountingEntityCopyWithImpl<$Res,
        $Val extends IncomeCategoryAccountingEntity>
    implements $IncomeCategoryAccountingEntityCopyWith<$Res> {
  _$IncomeCategoryAccountingEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smallCategoryName = null,
    Object? totalIncomeBySmallCategory = null,
    Object? categoryIconPath = null,
    Object? categoryColor = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryName: null == smallCategoryName
          ? _value.smallCategoryName
          : smallCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      totalIncomeBySmallCategory: null == totalIncomeBySmallCategory
          ? _value.totalIncomeBySmallCategory
          : totalIncomeBySmallCategory // ignore: cast_nullable_to_non_nullable
              as int,
      categoryIconPath: null == categoryIconPath
          ? _value.categoryIconPath
          : categoryIconPath // ignore: cast_nullable_to_non_nullable
              as String,
      categoryColor: null == categoryColor
          ? _value.categoryColor
          : categoryColor // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IncomeCategoryAccountingEntityImplCopyWith<$Res>
    implements $IncomeCategoryAccountingEntityCopyWith<$Res> {
  factory _$$IncomeCategoryAccountingEntityImplCopyWith(
          _$IncomeCategoryAccountingEntityImpl value,
          $Res Function(_$IncomeCategoryAccountingEntityImpl) then) =
      __$$IncomeCategoryAccountingEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String smallCategoryName,
      int totalIncomeBySmallCategory,
      String categoryIconPath,
      String categoryColor});
}

/// @nodoc
class __$$IncomeCategoryAccountingEntityImplCopyWithImpl<$Res>
    extends _$IncomeCategoryAccountingEntityCopyWithImpl<$Res,
        _$IncomeCategoryAccountingEntityImpl>
    implements _$$IncomeCategoryAccountingEntityImplCopyWith<$Res> {
  __$$IncomeCategoryAccountingEntityImplCopyWithImpl(
      _$IncomeCategoryAccountingEntityImpl _value,
      $Res Function(_$IncomeCategoryAccountingEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smallCategoryName = null,
    Object? totalIncomeBySmallCategory = null,
    Object? categoryIconPath = null,
    Object? categoryColor = null,
  }) {
    return _then(_$IncomeCategoryAccountingEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryName: null == smallCategoryName
          ? _value.smallCategoryName
          : smallCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      totalIncomeBySmallCategory: null == totalIncomeBySmallCategory
          ? _value.totalIncomeBySmallCategory
          : totalIncomeBySmallCategory // ignore: cast_nullable_to_non_nullable
              as int,
      categoryIconPath: null == categoryIconPath
          ? _value.categoryIconPath
          : categoryIconPath // ignore: cast_nullable_to_non_nullable
              as String,
      categoryColor: null == categoryColor
          ? _value.categoryColor
          : categoryColor // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$IncomeCategoryAccountingEntityImpl
    implements _IncomeCategoryAccountingEntity {
  const _$IncomeCategoryAccountingEntityImpl(
      {required this.id,
      required this.smallCategoryName,
      required this.totalIncomeBySmallCategory,
      required this.categoryIconPath,
      required this.categoryColor});

  @override
  final int id;
  @override
  final String smallCategoryName;
  @override
  final int totalIncomeBySmallCategory;
  @override
  final String categoryIconPath;
  @override
  final String categoryColor;

  @override
  String toString() {
    return 'IncomeCategoryAccountingEntity(id: $id, smallCategoryName: $smallCategoryName, totalIncomeBySmallCategory: $totalIncomeBySmallCategory, categoryIconPath: $categoryIconPath, categoryColor: $categoryColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeCategoryAccountingEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.smallCategoryName, smallCategoryName) ||
                other.smallCategoryName == smallCategoryName) &&
            (identical(other.totalIncomeBySmallCategory,
                    totalIncomeBySmallCategory) ||
                other.totalIncomeBySmallCategory ==
                    totalIncomeBySmallCategory) &&
            (identical(other.categoryIconPath, categoryIconPath) ||
                other.categoryIconPath == categoryIconPath) &&
            (identical(other.categoryColor, categoryColor) ||
                other.categoryColor == categoryColor));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, smallCategoryName,
      totalIncomeBySmallCategory, categoryIconPath, categoryColor);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomeCategoryAccountingEntityImplCopyWith<
          _$IncomeCategoryAccountingEntityImpl>
      get copyWith => __$$IncomeCategoryAccountingEntityImplCopyWithImpl<
          _$IncomeCategoryAccountingEntityImpl>(this, _$identity);
}

abstract class _IncomeCategoryAccountingEntity
    implements IncomeCategoryAccountingEntity {
  const factory _IncomeCategoryAccountingEntity(
          {required final int id,
          required final String smallCategoryName,
          required final int totalIncomeBySmallCategory,
          required final String categoryIconPath,
          required final String categoryColor}) =
      _$IncomeCategoryAccountingEntityImpl;

  @override
  int get id;
  @override
  String get smallCategoryName;
  @override
  int get totalIncomeBySmallCategory;
  @override
  String get categoryIconPath;
  @override
  String get categoryColor;
  @override
  @JsonKey(ignore: true)
  _$$IncomeCategoryAccountingEntityImplCopyWith<
          _$IncomeCategoryAccountingEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
