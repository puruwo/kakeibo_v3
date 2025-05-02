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
  int get smallCategoryOrderKey => throw _privateConstructorUsedError;
  int get bigCategoryKey => throw _privateConstructorUsedError;
  int get displaydOrderInBig => throw _privateConstructorUsedError;
  String get smallCategoryName => throw _privateConstructorUsedError;
  int get defaultDisplayed => throw _privateConstructorUsedError;
  ExpenseBigCategoryEntity get bigCategoryEntity =>
      throw _privateConstructorUsedError;

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
      int smallCategoryOrderKey,
      int bigCategoryKey,
      int displaydOrderInBig,
      String smallCategoryName,
      int defaultDisplayed,
      ExpenseBigCategoryEntity bigCategoryEntity});

  $ExpenseBigCategoryEntityCopyWith<$Res> get bigCategoryEntity;
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
    Object? smallCategoryOrderKey = null,
    Object? bigCategoryKey = null,
    Object? displaydOrderInBig = null,
    Object? smallCategoryName = null,
    Object? defaultDisplayed = null,
    Object? bigCategoryEntity = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryOrderKey: null == smallCategoryOrderKey
          ? _value.smallCategoryOrderKey
          : smallCategoryOrderKey // ignore: cast_nullable_to_non_nullable
              as int,
      bigCategoryKey: null == bigCategoryKey
          ? _value.bigCategoryKey
          : bigCategoryKey // ignore: cast_nullable_to_non_nullable
              as int,
      displaydOrderInBig: null == displaydOrderInBig
          ? _value.displaydOrderInBig
          : displaydOrderInBig // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryName: null == smallCategoryName
          ? _value.smallCategoryName
          : smallCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      defaultDisplayed: null == defaultDisplayed
          ? _value.defaultDisplayed
          : defaultDisplayed // ignore: cast_nullable_to_non_nullable
              as int,
      bigCategoryEntity: null == bigCategoryEntity
          ? _value.bigCategoryEntity
          : bigCategoryEntity // ignore: cast_nullable_to_non_nullable
              as ExpenseBigCategoryEntity,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ExpenseBigCategoryEntityCopyWith<$Res> get bigCategoryEntity {
    return $ExpenseBigCategoryEntityCopyWith<$Res>(_value.bigCategoryEntity,
        (value) {
      return _then(_value.copyWith(bigCategoryEntity: value) as $Val);
    });
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
      int smallCategoryOrderKey,
      int bigCategoryKey,
      int displaydOrderInBig,
      String smallCategoryName,
      int defaultDisplayed,
      ExpenseBigCategoryEntity bigCategoryEntity});

  @override
  $ExpenseBigCategoryEntityCopyWith<$Res> get bigCategoryEntity;
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
    Object? smallCategoryOrderKey = null,
    Object? bigCategoryKey = null,
    Object? displaydOrderInBig = null,
    Object? smallCategoryName = null,
    Object? defaultDisplayed = null,
    Object? bigCategoryEntity = null,
  }) {
    return _then(_$CategoryEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryOrderKey: null == smallCategoryOrderKey
          ? _value.smallCategoryOrderKey
          : smallCategoryOrderKey // ignore: cast_nullable_to_non_nullable
              as int,
      bigCategoryKey: null == bigCategoryKey
          ? _value.bigCategoryKey
          : bigCategoryKey // ignore: cast_nullable_to_non_nullable
              as int,
      displaydOrderInBig: null == displaydOrderInBig
          ? _value.displaydOrderInBig
          : displaydOrderInBig // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryName: null == smallCategoryName
          ? _value.smallCategoryName
          : smallCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      defaultDisplayed: null == defaultDisplayed
          ? _value.defaultDisplayed
          : defaultDisplayed // ignore: cast_nullable_to_non_nullable
              as int,
      bigCategoryEntity: null == bigCategoryEntity
          ? _value.bigCategoryEntity
          : bigCategoryEntity // ignore: cast_nullable_to_non_nullable
              as ExpenseBigCategoryEntity,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryEntityImpl implements _CategoryEntity {
  const _$CategoryEntityImpl(
      {this.id = 0,
      required this.smallCategoryOrderKey,
      required this.bigCategoryKey,
      required this.displaydOrderInBig,
      required this.smallCategoryName,
      required this.defaultDisplayed,
      required this.bigCategoryEntity});

  factory _$CategoryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryEntityImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  final int smallCategoryOrderKey;
  @override
  final int bigCategoryKey;
  @override
  final int displaydOrderInBig;
  @override
  final String smallCategoryName;
  @override
  final int defaultDisplayed;
  @override
  final ExpenseBigCategoryEntity bigCategoryEntity;

  @override
  String toString() {
    return 'CategoryEntity(id: $id, smallCategoryOrderKey: $smallCategoryOrderKey, bigCategoryKey: $bigCategoryKey, displaydOrderInBig: $displaydOrderInBig, smallCategoryName: $smallCategoryName, defaultDisplayed: $defaultDisplayed, bigCategoryEntity: $bigCategoryEntity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.smallCategoryOrderKey, smallCategoryOrderKey) ||
                other.smallCategoryOrderKey == smallCategoryOrderKey) &&
            (identical(other.bigCategoryKey, bigCategoryKey) ||
                other.bigCategoryKey == bigCategoryKey) &&
            (identical(other.displaydOrderInBig, displaydOrderInBig) ||
                other.displaydOrderInBig == displaydOrderInBig) &&
            (identical(other.smallCategoryName, smallCategoryName) ||
                other.smallCategoryName == smallCategoryName) &&
            (identical(other.defaultDisplayed, defaultDisplayed) ||
                other.defaultDisplayed == defaultDisplayed) &&
            (identical(other.bigCategoryEntity, bigCategoryEntity) ||
                other.bigCategoryEntity == bigCategoryEntity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      smallCategoryOrderKey,
      bigCategoryKey,
      displaydOrderInBig,
      smallCategoryName,
      defaultDisplayed,
      bigCategoryEntity);

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
          required final int smallCategoryOrderKey,
          required final int bigCategoryKey,
          required final int displaydOrderInBig,
          required final String smallCategoryName,
          required final int defaultDisplayed,
          required final ExpenseBigCategoryEntity bigCategoryEntity}) =
      _$CategoryEntityImpl;

  factory _CategoryEntity.fromJson(Map<String, dynamic> json) =
      _$CategoryEntityImpl.fromJson;

  @override
  int get id;
  @override
  int get smallCategoryOrderKey;
  @override
  int get bigCategoryKey;
  @override
  int get displaydOrderInBig;
  @override
  String get smallCategoryName;
  @override
  int get defaultDisplayed;
  @override
  ExpenseBigCategoryEntity get bigCategoryEntity;
  @override
  @JsonKey(ignore: true)
  _$$CategoryEntityImplCopyWith<_$CategoryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
