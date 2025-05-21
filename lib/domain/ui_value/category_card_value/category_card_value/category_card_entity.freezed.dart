// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_card_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CategoryCardEntity {
  int get monthlyBudget => throw _privateConstructorUsedError;
  CategoryAccountingEntity get monthlyExpenseByCategoryEntity =>
      throw _privateConstructorUsedError;
  List<SmallCategoryTileEntity> get smallCategoryList =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CategoryCardEntityCopyWith<CategoryCardEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCardEntityCopyWith<$Res> {
  factory $CategoryCardEntityCopyWith(
          CategoryCardEntity value, $Res Function(CategoryCardEntity) then) =
      _$CategoryCardEntityCopyWithImpl<$Res, CategoryCardEntity>;
  @useResult
  $Res call(
      {int monthlyBudget,
      CategoryAccountingEntity monthlyExpenseByCategoryEntity,
      List<SmallCategoryTileEntity> smallCategoryList});

  $CategoryAccountingEntityCopyWith<$Res> get monthlyExpenseByCategoryEntity;
}

/// @nodoc
class _$CategoryCardEntityCopyWithImpl<$Res, $Val extends CategoryCardEntity>
    implements $CategoryCardEntityCopyWith<$Res> {
  _$CategoryCardEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyBudget = null,
    Object? monthlyExpenseByCategoryEntity = null,
    Object? smallCategoryList = null,
  }) {
    return _then(_value.copyWith(
      monthlyBudget: null == monthlyBudget
          ? _value.monthlyBudget
          : monthlyBudget // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyExpenseByCategoryEntity: null == monthlyExpenseByCategoryEntity
          ? _value.monthlyExpenseByCategoryEntity
          : monthlyExpenseByCategoryEntity // ignore: cast_nullable_to_non_nullable
              as CategoryAccountingEntity,
      smallCategoryList: null == smallCategoryList
          ? _value.smallCategoryList
          : smallCategoryList // ignore: cast_nullable_to_non_nullable
              as List<SmallCategoryTileEntity>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CategoryAccountingEntityCopyWith<$Res> get monthlyExpenseByCategoryEntity {
    return $CategoryAccountingEntityCopyWith<$Res>(
        _value.monthlyExpenseByCategoryEntity, (value) {
      return _then(
          _value.copyWith(monthlyExpenseByCategoryEntity: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CategoryCardEntityImplCopyWith<$Res>
    implements $CategoryCardEntityCopyWith<$Res> {
  factory _$$CategoryCardEntityImplCopyWith(_$CategoryCardEntityImpl value,
          $Res Function(_$CategoryCardEntityImpl) then) =
      __$$CategoryCardEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int monthlyBudget,
      CategoryAccountingEntity monthlyExpenseByCategoryEntity,
      List<SmallCategoryTileEntity> smallCategoryList});

  @override
  $CategoryAccountingEntityCopyWith<$Res> get monthlyExpenseByCategoryEntity;
}

/// @nodoc
class __$$CategoryCardEntityImplCopyWithImpl<$Res>
    extends _$CategoryCardEntityCopyWithImpl<$Res, _$CategoryCardEntityImpl>
    implements _$$CategoryCardEntityImplCopyWith<$Res> {
  __$$CategoryCardEntityImplCopyWithImpl(_$CategoryCardEntityImpl _value,
      $Res Function(_$CategoryCardEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyBudget = null,
    Object? monthlyExpenseByCategoryEntity = null,
    Object? smallCategoryList = null,
  }) {
    return _then(_$CategoryCardEntityImpl(
      monthlyBudget: null == monthlyBudget
          ? _value.monthlyBudget
          : monthlyBudget // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyExpenseByCategoryEntity: null == monthlyExpenseByCategoryEntity
          ? _value.monthlyExpenseByCategoryEntity
          : monthlyExpenseByCategoryEntity // ignore: cast_nullable_to_non_nullable
              as CategoryAccountingEntity,
      smallCategoryList: null == smallCategoryList
          ? _value._smallCategoryList
          : smallCategoryList // ignore: cast_nullable_to_non_nullable
              as List<SmallCategoryTileEntity>,
    ));
  }
}

/// @nodoc

class _$CategoryCardEntityImpl implements _CategoryCardEntity {
  const _$CategoryCardEntityImpl(
      {required this.monthlyBudget,
      required this.monthlyExpenseByCategoryEntity,
      required final List<SmallCategoryTileEntity> smallCategoryList})
      : _smallCategoryList = smallCategoryList;

  @override
  final int monthlyBudget;
  @override
  final CategoryAccountingEntity monthlyExpenseByCategoryEntity;
  final List<SmallCategoryTileEntity> _smallCategoryList;
  @override
  List<SmallCategoryTileEntity> get smallCategoryList {
    if (_smallCategoryList is EqualUnmodifiableListView)
      return _smallCategoryList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_smallCategoryList);
  }

  @override
  String toString() {
    return 'CategoryCardEntity(monthlyBudget: $monthlyBudget, monthlyExpenseByCategoryEntity: $monthlyExpenseByCategoryEntity, smallCategoryList: $smallCategoryList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryCardEntityImpl &&
            (identical(other.monthlyBudget, monthlyBudget) ||
                other.monthlyBudget == monthlyBudget) &&
            (identical(other.monthlyExpenseByCategoryEntity,
                    monthlyExpenseByCategoryEntity) ||
                other.monthlyExpenseByCategoryEntity ==
                    monthlyExpenseByCategoryEntity) &&
            const DeepCollectionEquality()
                .equals(other._smallCategoryList, _smallCategoryList));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      monthlyBudget,
      monthlyExpenseByCategoryEntity,
      const DeepCollectionEquality().hash(_smallCategoryList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryCardEntityImplCopyWith<_$CategoryCardEntityImpl> get copyWith =>
      __$$CategoryCardEntityImplCopyWithImpl<_$CategoryCardEntityImpl>(
          this, _$identity);
}

abstract class _CategoryCardEntity implements CategoryCardEntity {
  const factory _CategoryCardEntity(
      {required final int monthlyBudget,
      required final CategoryAccountingEntity monthlyExpenseByCategoryEntity,
      required final List<SmallCategoryTileEntity>
          smallCategoryList}) = _$CategoryCardEntityImpl;

  @override
  int get monthlyBudget;
  @override
  CategoryAccountingEntity get monthlyExpenseByCategoryEntity;
  @override
  List<SmallCategoryTileEntity> get smallCategoryList;
  @override
  @JsonKey(ignore: true)
  _$$CategoryCardEntityImplCopyWith<_$CategoryCardEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
