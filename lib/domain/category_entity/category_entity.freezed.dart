// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CategoryEntity _$CategoryEntityFromJson(Map<String, dynamic> json) {
  return _CategoryEntity.fromJson(json);
}

/// @nodoc
mixin _$CategoryEntity {
  int get id => throw _privateConstructorUsedError;
  String get categoryColor => throw _privateConstructorUsedError;
  String get bigCategoryName => throw _privateConstructorUsedError;
  String get categoryIconPath => throw _privateConstructorUsedError;
  int get budget => throw _privateConstructorUsedError;
  int get totalExpenseByBigCategory => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CategoryEntityCopyWith<CategoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryEntityCopyWith<$Res> {
  factory $CategoryEntityCopyWith(
          CategoryEntity value, $Res Function(CategoryEntity) then) =
      _$CategoryEntityCopyWithImpl<$Res, CategoryEntity>;
  @useResult
  $Res call(
      {int id,
      String categoryColor,
      String bigCategoryName,
      String categoryIconPath,
      int budget,
      int totalExpenseByBigCategory});
}

/// @nodoc
class _$CategoryEntityCopyWithImpl<$Res, $Val extends CategoryEntity>
    implements $CategoryEntityCopyWith<$Res> {
  _$CategoryEntityCopyWithImpl(this._value, this._then);

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
    Object? budget = null,
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
      budget: null == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as int,
      totalExpenseByBigCategory: null == totalExpenseByBigCategory
          ? _value.totalExpenseByBigCategory
          : totalExpenseByBigCategory // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryEntityImplCopyWith<$Res>
    implements $CategoryEntityCopyWith<$Res> {
  factory _$$CategoryEntityImplCopyWith(_$CategoryEntityImpl value,
          $Res Function(_$CategoryEntityImpl) then) =
      __$$CategoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String categoryColor,
      String bigCategoryName,
      String categoryIconPath,
      int budget,
      int totalExpenseByBigCategory});
}

/// @nodoc
class __$$CategoryEntityImplCopyWithImpl<$Res>
    extends _$CategoryEntityCopyWithImpl<$Res, _$CategoryEntityImpl>
    implements _$$CategoryEntityImplCopyWith<$Res> {
  __$$CategoryEntityImplCopyWithImpl(
      _$CategoryEntityImpl _value, $Res Function(_$CategoryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryColor = null,
    Object? bigCategoryName = null,
    Object? categoryIconPath = null,
    Object? budget = null,
    Object? totalExpenseByBigCategory = null,
  }) {
    return _then(_$CategoryEntityImpl(
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
      budget: null == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as int,
      totalExpenseByBigCategory: null == totalExpenseByBigCategory
          ? _value.totalExpenseByBigCategory
          : totalExpenseByBigCategory // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryEntityImpl implements _CategoryEntity {
  const _$CategoryEntityImpl(
      {this.id = 0,
      required this.categoryColor,
      required this.bigCategoryName,
      required this.categoryIconPath,
      this.budget = 0,
      this.totalExpenseByBigCategory = 0});

  factory _$CategoryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryEntityImplFromJson(json);

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
  final int budget;
  @override
  @JsonKey()
  final int totalExpenseByBigCategory;

  @override
  String toString() {
    return 'CategoryEntity(id: $id, categoryColor: $categoryColor, bigCategoryName: $bigCategoryName, categoryIconPath: $categoryIconPath, budget: $budget, totalExpenseByBigCategory: $totalExpenseByBigCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryColor, categoryColor) ||
                other.categoryColor == categoryColor) &&
            (identical(other.bigCategoryName, bigCategoryName) ||
                other.bigCategoryName == bigCategoryName) &&
            (identical(other.categoryIconPath, categoryIconPath) ||
                other.categoryIconPath == categoryIconPath) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.totalExpenseByBigCategory,
                    totalExpenseByBigCategory) ||
                other.totalExpenseByBigCategory == totalExpenseByBigCategory));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, categoryColor,
      bigCategoryName, categoryIconPath, budget, totalExpenseByBigCategory);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryEntityImplCopyWith<_$CategoryEntityImpl> get copyWith =>
      __$$CategoryEntityImplCopyWithImpl<_$CategoryEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryEntityImplToJson(
      this,
    );
  }
}

abstract class _CategoryEntity implements CategoryEntity {
  const factory _CategoryEntity(
      {final int id,
      required final String categoryColor,
      required final String bigCategoryName,
      required final String categoryIconPath,
      final int budget,
      final int totalExpenseByBigCategory}) = _$CategoryEntityImpl;

  factory _CategoryEntity.fromJson(Map<String, dynamic> json) =
      _$CategoryEntityImpl.fromJson;

  @override
  int get id;
  @override
  String get categoryColor;
  @override
  String get bigCategoryName;
  @override
  String get categoryIconPath;
  @override
  int get budget;
  @override
  int get totalExpenseByBigCategory;
  @override
  @JsonKey(ignore: true)
  _$$CategoryEntityImplCopyWith<_$CategoryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
