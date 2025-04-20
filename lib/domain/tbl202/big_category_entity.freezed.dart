// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'big_category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BigCategoryEntity _$BigCategoryEntityFromJson(Map<String, dynamic> json) {
  return _BigCategoryEntity.fromJson(json);
}

/// @nodoc
mixin _$BigCategoryEntity {
  int get id => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get bigCategoryName => throw _privateConstructorUsedError;
  String get resourcePath => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;
  int get isDisplayed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BigCategoryEntityCopyWith<BigCategoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BigCategoryEntityCopyWith<$Res> {
  factory $BigCategoryEntityCopyWith(
          BigCategoryEntity value, $Res Function(BigCategoryEntity) then) =
      _$BigCategoryEntityCopyWithImpl<$Res, BigCategoryEntity>;
  @useResult
  $Res call(
      {int id,
      String colorCode,
      String bigCategoryName,
      String resourcePath,
      int displayOrder,
      int isDisplayed});
}

/// @nodoc
class _$BigCategoryEntityCopyWithImpl<$Res, $Val extends BigCategoryEntity>
    implements $BigCategoryEntityCopyWith<$Res> {
  _$BigCategoryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? colorCode = null,
    Object? bigCategoryName = null,
    Object? resourcePath = null,
    Object? displayOrder = null,
    Object? isDisplayed = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String,
      bigCategoryName: null == bigCategoryName
          ? _value.bigCategoryName
          : bigCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      resourcePath: null == resourcePath
          ? _value.resourcePath
          : resourcePath // ignore: cast_nullable_to_non_nullable
              as String,
      displayOrder: null == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isDisplayed: null == isDisplayed
          ? _value.isDisplayed
          : isDisplayed // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BigCategoryEntityImplCopyWith<$Res>
    implements $BigCategoryEntityCopyWith<$Res> {
  factory _$$BigCategoryEntityImplCopyWith(_$BigCategoryEntityImpl value,
          $Res Function(_$BigCategoryEntityImpl) then) =
      __$$BigCategoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String colorCode,
      String bigCategoryName,
      String resourcePath,
      int displayOrder,
      int isDisplayed});
}

/// @nodoc
class __$$BigCategoryEntityImplCopyWithImpl<$Res>
    extends _$BigCategoryEntityCopyWithImpl<$Res, _$BigCategoryEntityImpl>
    implements _$$BigCategoryEntityImplCopyWith<$Res> {
  __$$BigCategoryEntityImplCopyWithImpl(_$BigCategoryEntityImpl _value,
      $Res Function(_$BigCategoryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? colorCode = null,
    Object? bigCategoryName = null,
    Object? resourcePath = null,
    Object? displayOrder = null,
    Object? isDisplayed = null,
  }) {
    return _then(_$BigCategoryEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String,
      bigCategoryName: null == bigCategoryName
          ? _value.bigCategoryName
          : bigCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      resourcePath: null == resourcePath
          ? _value.resourcePath
          : resourcePath // ignore: cast_nullable_to_non_nullable
              as String,
      displayOrder: null == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isDisplayed: null == isDisplayed
          ? _value.isDisplayed
          : isDisplayed // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BigCategoryEntityImpl extends _BigCategoryEntity {
  const _$BigCategoryEntityImpl(
      {required this.id,
      required this.colorCode,
      required this.bigCategoryName,
      required this.resourcePath,
      required this.displayOrder,
      required this.isDisplayed})
      : super._();

  factory _$BigCategoryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$BigCategoryEntityImplFromJson(json);

  @override
  final int id;
  @override
  final String colorCode;
  @override
  final String bigCategoryName;
  @override
  final String resourcePath;
  @override
  final int displayOrder;
  @override
  final int isDisplayed;

  @override
  String toString() {
    return 'BigCategoryEntity(id: $id, colorCode: $colorCode, bigCategoryName: $bigCategoryName, resourcePath: $resourcePath, displayOrder: $displayOrder, isDisplayed: $isDisplayed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BigCategoryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.bigCategoryName, bigCategoryName) ||
                other.bigCategoryName == bigCategoryName) &&
            (identical(other.resourcePath, resourcePath) ||
                other.resourcePath == resourcePath) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.isDisplayed, isDisplayed) ||
                other.isDisplayed == isDisplayed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, colorCode, bigCategoryName,
      resourcePath, displayOrder, isDisplayed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BigCategoryEntityImplCopyWith<_$BigCategoryEntityImpl> get copyWith =>
      __$$BigCategoryEntityImplCopyWithImpl<_$BigCategoryEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BigCategoryEntityImplToJson(
      this,
    );
  }
}

abstract class _BigCategoryEntity extends BigCategoryEntity {
  const factory _BigCategoryEntity(
      {required final int id,
      required final String colorCode,
      required final String bigCategoryName,
      required final String resourcePath,
      required final int displayOrder,
      required final int isDisplayed}) = _$BigCategoryEntityImpl;
  const _BigCategoryEntity._() : super._();

  factory _BigCategoryEntity.fromJson(Map<String, dynamic> json) =
      _$BigCategoryEntityImpl.fromJson;

  @override
  int get id;
  @override
  String get colorCode;
  @override
  String get bigCategoryName;
  @override
  String get resourcePath;
  @override
  int get displayOrder;
  @override
  int get isDisplayed;
  @override
  @JsonKey(ignore: true)
  _$$BigCategoryEntityImplCopyWith<_$BigCategoryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
