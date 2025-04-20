// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'small_category_tile_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SmallCategoryTileEntity _$SmallCategoryTileEntityFromJson(
    Map<String, dynamic> json) {
  return _SmallCategoryTileEntity.fromJson(json);
}

/// @nodoc
mixin _$SmallCategoryTileEntity {
  int get id => throw _privateConstructorUsedError;
  int get displeyOrder => throw _privateConstructorUsedError;
  String get smallCategoryName => throw _privateConstructorUsedError;
  int get totalExpenseBySmallCategory => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SmallCategoryTileEntityCopyWith<SmallCategoryTileEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmallCategoryTileEntityCopyWith<$Res> {
  factory $SmallCategoryTileEntityCopyWith(SmallCategoryTileEntity value,
          $Res Function(SmallCategoryTileEntity) then) =
      _$SmallCategoryTileEntityCopyWithImpl<$Res, SmallCategoryTileEntity>;
  @useResult
  $Res call(
      {int id,
      int displeyOrder,
      String smallCategoryName,
      int totalExpenseBySmallCategory});
}

/// @nodoc
class _$SmallCategoryTileEntityCopyWithImpl<$Res,
        $Val extends SmallCategoryTileEntity>
    implements $SmallCategoryTileEntityCopyWith<$Res> {
  _$SmallCategoryTileEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displeyOrder = null,
    Object? smallCategoryName = null,
    Object? totalExpenseBySmallCategory = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      displeyOrder: null == displeyOrder
          ? _value.displeyOrder
          : displeyOrder // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryName: null == smallCategoryName
          ? _value.smallCategoryName
          : smallCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      totalExpenseBySmallCategory: null == totalExpenseBySmallCategory
          ? _value.totalExpenseBySmallCategory
          : totalExpenseBySmallCategory // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SmallCategoryTileEntityImplCopyWith<$Res>
    implements $SmallCategoryTileEntityCopyWith<$Res> {
  factory _$$SmallCategoryTileEntityImplCopyWith(
          _$SmallCategoryTileEntityImpl value,
          $Res Function(_$SmallCategoryTileEntityImpl) then) =
      __$$SmallCategoryTileEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int displeyOrder,
      String smallCategoryName,
      int totalExpenseBySmallCategory});
}

/// @nodoc
class __$$SmallCategoryTileEntityImplCopyWithImpl<$Res>
    extends _$SmallCategoryTileEntityCopyWithImpl<$Res,
        _$SmallCategoryTileEntityImpl>
    implements _$$SmallCategoryTileEntityImplCopyWith<$Res> {
  __$$SmallCategoryTileEntityImplCopyWithImpl(
      _$SmallCategoryTileEntityImpl _value,
      $Res Function(_$SmallCategoryTileEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displeyOrder = null,
    Object? smallCategoryName = null,
    Object? totalExpenseBySmallCategory = null,
  }) {
    return _then(_$SmallCategoryTileEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      displeyOrder: null == displeyOrder
          ? _value.displeyOrder
          : displeyOrder // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryName: null == smallCategoryName
          ? _value.smallCategoryName
          : smallCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      totalExpenseBySmallCategory: null == totalExpenseBySmallCategory
          ? _value.totalExpenseBySmallCategory
          : totalExpenseBySmallCategory // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SmallCategoryTileEntityImpl implements _SmallCategoryTileEntity {
  const _$SmallCategoryTileEntityImpl(
      {this.id = 0,
      this.displeyOrder = 0,
      required this.smallCategoryName,
      this.totalExpenseBySmallCategory = 0});

  factory _$SmallCategoryTileEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmallCategoryTileEntityImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  @JsonKey()
  final int displeyOrder;
  @override
  final String smallCategoryName;
  @override
  @JsonKey()
  final int totalExpenseBySmallCategory;

  @override
  String toString() {
    return 'SmallCategoryTileEntity(id: $id, displeyOrder: $displeyOrder, smallCategoryName: $smallCategoryName, totalExpenseBySmallCategory: $totalExpenseBySmallCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmallCategoryTileEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.displeyOrder, displeyOrder) ||
                other.displeyOrder == displeyOrder) &&
            (identical(other.smallCategoryName, smallCategoryName) ||
                other.smallCategoryName == smallCategoryName) &&
            (identical(other.totalExpenseBySmallCategory,
                    totalExpenseBySmallCategory) ||
                other.totalExpenseBySmallCategory ==
                    totalExpenseBySmallCategory));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, displeyOrder,
      smallCategoryName, totalExpenseBySmallCategory);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SmallCategoryTileEntityImplCopyWith<_$SmallCategoryTileEntityImpl>
      get copyWith => __$$SmallCategoryTileEntityImplCopyWithImpl<
          _$SmallCategoryTileEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmallCategoryTileEntityImplToJson(
      this,
    );
  }
}

abstract class _SmallCategoryTileEntity implements SmallCategoryTileEntity {
  const factory _SmallCategoryTileEntity(
      {final int id,
      final int displeyOrder,
      required final String smallCategoryName,
      final int totalExpenseBySmallCategory}) = _$SmallCategoryTileEntityImpl;

  factory _SmallCategoryTileEntity.fromJson(Map<String, dynamic> json) =
      _$SmallCategoryTileEntityImpl.fromJson;

  @override
  int get id;
  @override
  int get displeyOrder;
  @override
  String get smallCategoryName;
  @override
  int get totalExpenseBySmallCategory;
  @override
  @JsonKey(ignore: true)
  _$$SmallCategoryTileEntityImplCopyWith<_$SmallCategoryTileEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
