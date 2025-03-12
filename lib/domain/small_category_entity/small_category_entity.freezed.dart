// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'small_category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SmallCategoryEntity _$SmallCategoryEntityFromJson(Map<String, dynamic> json) {
  return _SmallCategoryEntity.fromJson(json);
}

/// @nodoc
mixin _$SmallCategoryEntity {
  int get id => throw _privateConstructorUsedError;
  int get displeyOrder => throw _privateConstructorUsedError;
  String get smallCategoryName => throw _privateConstructorUsedError;
  int get totalExpenseBySmallCategory => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SmallCategoryEntityCopyWith<SmallCategoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmallCategoryEntityCopyWith<$Res> {
  factory $SmallCategoryEntityCopyWith(
          SmallCategoryEntity value, $Res Function(SmallCategoryEntity) then) =
      _$SmallCategoryEntityCopyWithImpl<$Res, SmallCategoryEntity>;
  @useResult
  $Res call(
      {int id,
      int displeyOrder,
      String smallCategoryName,
      int totalExpenseBySmallCategory});
}

/// @nodoc
class _$SmallCategoryEntityCopyWithImpl<$Res, $Val extends SmallCategoryEntity>
    implements $SmallCategoryEntityCopyWith<$Res> {
  _$SmallCategoryEntityCopyWithImpl(this._value, this._then);

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
abstract class _$$SmallCategoryEntityImplCopyWith<$Res>
    implements $SmallCategoryEntityCopyWith<$Res> {
  factory _$$SmallCategoryEntityImplCopyWith(_$SmallCategoryEntityImpl value,
          $Res Function(_$SmallCategoryEntityImpl) then) =
      __$$SmallCategoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int displeyOrder,
      String smallCategoryName,
      int totalExpenseBySmallCategory});
}

/// @nodoc
class __$$SmallCategoryEntityImplCopyWithImpl<$Res>
    extends _$SmallCategoryEntityCopyWithImpl<$Res, _$SmallCategoryEntityImpl>
    implements _$$SmallCategoryEntityImplCopyWith<$Res> {
  __$$SmallCategoryEntityImplCopyWithImpl(_$SmallCategoryEntityImpl _value,
      $Res Function(_$SmallCategoryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displeyOrder = null,
    Object? smallCategoryName = null,
    Object? totalExpenseBySmallCategory = null,
  }) {
    return _then(_$SmallCategoryEntityImpl(
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
class _$SmallCategoryEntityImpl implements _SmallCategoryEntity {
  const _$SmallCategoryEntityImpl(
      {this.id = 0,
      this.displeyOrder = 0,
      required this.smallCategoryName,
      this.totalExpenseBySmallCategory = 0});

  factory _$SmallCategoryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmallCategoryEntityImplFromJson(json);

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
    return 'SmallCategoryEntity(id: $id, displeyOrder: $displeyOrder, smallCategoryName: $smallCategoryName, totalExpenseBySmallCategory: $totalExpenseBySmallCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmallCategoryEntityImpl &&
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
  _$$SmallCategoryEntityImplCopyWith<_$SmallCategoryEntityImpl> get copyWith =>
      __$$SmallCategoryEntityImplCopyWithImpl<_$SmallCategoryEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmallCategoryEntityImplToJson(
      this,
    );
  }
}

abstract class _SmallCategoryEntity implements SmallCategoryEntity {
  const factory _SmallCategoryEntity(
      {final int id,
      final int displeyOrder,
      required final String smallCategoryName,
      final int totalExpenseBySmallCategory}) = _$SmallCategoryEntityImpl;

  factory _SmallCategoryEntity.fromJson(Map<String, dynamic> json) =
      _$SmallCategoryEntityImpl.fromJson;

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
  _$$SmallCategoryEntityImplCopyWith<_$SmallCategoryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
