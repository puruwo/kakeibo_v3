// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_tile_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CategoryTileEntity {
  CategoryEntity get categoryEntity => throw _privateConstructorUsedError;
  List<SmallCategoryTileEntity> get smallCategoryList =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CategoryTileEntityCopyWith<CategoryTileEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryTileEntityCopyWith<$Res> {
  factory $CategoryTileEntityCopyWith(
          CategoryTileEntity value, $Res Function(CategoryTileEntity) then) =
      _$CategoryTileEntityCopyWithImpl<$Res, CategoryTileEntity>;
  @useResult
  $Res call(
      {CategoryEntity categoryEntity,
      List<SmallCategoryTileEntity> smallCategoryList});

  $CategoryEntityCopyWith<$Res> get categoryEntity;
}

/// @nodoc
class _$CategoryTileEntityCopyWithImpl<$Res, $Val extends CategoryTileEntity>
    implements $CategoryTileEntityCopyWith<$Res> {
  _$CategoryTileEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryEntity = null,
    Object? smallCategoryList = null,
  }) {
    return _then(_value.copyWith(
      categoryEntity: null == categoryEntity
          ? _value.categoryEntity
          : categoryEntity // ignore: cast_nullable_to_non_nullable
              as CategoryEntity,
      smallCategoryList: null == smallCategoryList
          ? _value.smallCategoryList
          : smallCategoryList // ignore: cast_nullable_to_non_nullable
              as List<SmallCategoryTileEntity>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CategoryEntityCopyWith<$Res> get categoryEntity {
    return $CategoryEntityCopyWith<$Res>(_value.categoryEntity, (value) {
      return _then(_value.copyWith(categoryEntity: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CategoryTileEntityImplCopyWith<$Res>
    implements $CategoryTileEntityCopyWith<$Res> {
  factory _$$CategoryTileEntityImplCopyWith(_$CategoryTileEntityImpl value,
          $Res Function(_$CategoryTileEntityImpl) then) =
      __$$CategoryTileEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CategoryEntity categoryEntity,
      List<SmallCategoryTileEntity> smallCategoryList});

  @override
  $CategoryEntityCopyWith<$Res> get categoryEntity;
}

/// @nodoc
class __$$CategoryTileEntityImplCopyWithImpl<$Res>
    extends _$CategoryTileEntityCopyWithImpl<$Res, _$CategoryTileEntityImpl>
    implements _$$CategoryTileEntityImplCopyWith<$Res> {
  __$$CategoryTileEntityImplCopyWithImpl(_$CategoryTileEntityImpl _value,
      $Res Function(_$CategoryTileEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryEntity = null,
    Object? smallCategoryList = null,
  }) {
    return _then(_$CategoryTileEntityImpl(
      categoryEntity: null == categoryEntity
          ? _value.categoryEntity
          : categoryEntity // ignore: cast_nullable_to_non_nullable
              as CategoryEntity,
      smallCategoryList: null == smallCategoryList
          ? _value._smallCategoryList
          : smallCategoryList // ignore: cast_nullable_to_non_nullable
              as List<SmallCategoryTileEntity>,
    ));
  }
}

/// @nodoc

class _$CategoryTileEntityImpl implements _CategoryTileEntity {
  const _$CategoryTileEntityImpl(
      {required this.categoryEntity,
      required final List<SmallCategoryTileEntity> smallCategoryList})
      : _smallCategoryList = smallCategoryList;

  @override
  final CategoryEntity categoryEntity;
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
    return 'CategoryTileEntity(categoryEntity: $categoryEntity, smallCategoryList: $smallCategoryList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryTileEntityImpl &&
            (identical(other.categoryEntity, categoryEntity) ||
                other.categoryEntity == categoryEntity) &&
            const DeepCollectionEquality()
                .equals(other._smallCategoryList, _smallCategoryList));
  }

  @override
  int get hashCode => Object.hash(runtimeType, categoryEntity,
      const DeepCollectionEquality().hash(_smallCategoryList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryTileEntityImplCopyWith<_$CategoryTileEntityImpl> get copyWith =>
      __$$CategoryTileEntityImplCopyWithImpl<_$CategoryTileEntityImpl>(
          this, _$identity);
}

abstract class _CategoryTileEntity implements CategoryTileEntity {
  const factory _CategoryTileEntity(
          {required final CategoryEntity categoryEntity,
          required final List<SmallCategoryTileEntity> smallCategoryList}) =
      _$CategoryTileEntityImpl;

  @override
  CategoryEntity get categoryEntity;
  @override
  List<SmallCategoryTileEntity> get smallCategoryList;
  @override
  @JsonKey(ignore: true)
  _$$CategoryTileEntityImplCopyWith<_$CategoryTileEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
