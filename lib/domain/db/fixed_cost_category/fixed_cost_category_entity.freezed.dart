// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fixed_cost_category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FixedCostCategoryEntity _$FixedCostCategoryEntityFromJson(
    Map<String, dynamic> json) {
  return _FixedCostCategoryEntity.fromJson(json);
}

/// @nodoc
mixin _$FixedCostCategoryEntity {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get resourcePath => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;
  int get isDisplayed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FixedCostCategoryEntityCopyWith<FixedCostCategoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FixedCostCategoryEntityCopyWith<$Res> {
  factory $FixedCostCategoryEntityCopyWith(FixedCostCategoryEntity value,
          $Res Function(FixedCostCategoryEntity) then) =
      _$FixedCostCategoryEntityCopyWithImpl<$Res, FixedCostCategoryEntity>;
  @useResult
  $Res call(
      {int id,
      String name,
      String colorCode,
      String resourcePath,
      int displayOrder,
      int isDisplayed});
}

/// @nodoc
class _$FixedCostCategoryEntityCopyWithImpl<$Res,
        $Val extends FixedCostCategoryEntity>
    implements $FixedCostCategoryEntityCopyWith<$Res> {
  _$FixedCostCategoryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorCode = null,
    Object? resourcePath = null,
    Object? displayOrder = null,
    Object? isDisplayed = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
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
abstract class _$$FixedCostCategoryEntityImplCopyWith<$Res>
    implements $FixedCostCategoryEntityCopyWith<$Res> {
  factory _$$FixedCostCategoryEntityImplCopyWith(
          _$FixedCostCategoryEntityImpl value,
          $Res Function(_$FixedCostCategoryEntityImpl) then) =
      __$$FixedCostCategoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String colorCode,
      String resourcePath,
      int displayOrder,
      int isDisplayed});
}

/// @nodoc
class __$$FixedCostCategoryEntityImplCopyWithImpl<$Res>
    extends _$FixedCostCategoryEntityCopyWithImpl<$Res,
        _$FixedCostCategoryEntityImpl>
    implements _$$FixedCostCategoryEntityImplCopyWith<$Res> {
  __$$FixedCostCategoryEntityImplCopyWithImpl(
      _$FixedCostCategoryEntityImpl _value,
      $Res Function(_$FixedCostCategoryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorCode = null,
    Object? resourcePath = null,
    Object? displayOrder = null,
    Object? isDisplayed = null,
  }) {
    return _then(_$FixedCostCategoryEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
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
class _$FixedCostCategoryEntityImpl implements _FixedCostCategoryEntity {
  const _$FixedCostCategoryEntityImpl(
      {this.id = 0,
      required this.name,
      required this.colorCode,
      required this.resourcePath,
      this.displayOrder = 0,
      this.isDisplayed = 1});

  factory _$FixedCostCategoryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$FixedCostCategoryEntityImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  final String name;
  @override
  final String colorCode;
  @override
  final String resourcePath;
  @override
  @JsonKey()
  final int displayOrder;
  @override
  @JsonKey()
  final int isDisplayed;

  @override
  String toString() {
    return 'FixedCostCategoryEntity(id: $id, name: $name, colorCode: $colorCode, resourcePath: $resourcePath, displayOrder: $displayOrder, isDisplayed: $isDisplayed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FixedCostCategoryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.resourcePath, resourcePath) ||
                other.resourcePath == resourcePath) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.isDisplayed, isDisplayed) ||
                other.isDisplayed == isDisplayed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, colorCode,
      resourcePath, displayOrder, isDisplayed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FixedCostCategoryEntityImplCopyWith<_$FixedCostCategoryEntityImpl>
      get copyWith => __$$FixedCostCategoryEntityImplCopyWithImpl<
          _$FixedCostCategoryEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FixedCostCategoryEntityImplToJson(
      this,
    );
  }
}

abstract class _FixedCostCategoryEntity implements FixedCostCategoryEntity {
  const factory _FixedCostCategoryEntity(
      {final int id,
      required final String name,
      required final String colorCode,
      required final String resourcePath,
      final int displayOrder,
      final int isDisplayed}) = _$FixedCostCategoryEntityImpl;

  factory _FixedCostCategoryEntity.fromJson(Map<String, dynamic> json) =
      _$FixedCostCategoryEntityImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get colorCode;
  @override
  String get resourcePath;
  @override
  int get displayOrder;
  @override
  int get isDisplayed;
  @override
  @JsonKey(ignore: true)
  _$$FixedCostCategoryEntityImplCopyWith<_$FixedCostCategoryEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
