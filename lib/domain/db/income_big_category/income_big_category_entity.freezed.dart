// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'income_big_category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IncomeBigCategoryEntity _$IncomeBigCategoryEntityFromJson(
    Map<String, dynamic> json) {
  return _IncomeBigCategoryEntity.fromJson(json);
}

/// @nodoc
mixin _$IncomeBigCategoryEntity {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get iconPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IncomeBigCategoryEntityCopyWith<IncomeBigCategoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeBigCategoryEntityCopyWith<$Res> {
  factory $IncomeBigCategoryEntityCopyWith(IncomeBigCategoryEntity value,
          $Res Function(IncomeBigCategoryEntity) then) =
      _$IncomeBigCategoryEntityCopyWithImpl<$Res, IncomeBigCategoryEntity>;
  @useResult
  $Res call({int id, String name, String colorCode, String iconPath});
}

/// @nodoc
class _$IncomeBigCategoryEntityCopyWithImpl<$Res,
        $Val extends IncomeBigCategoryEntity>
    implements $IncomeBigCategoryEntityCopyWith<$Res> {
  _$IncomeBigCategoryEntityCopyWithImpl(this._value, this._then);

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
    Object? iconPath = null,
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
      iconPath: null == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IncomeBigCategoryEntityImplCopyWith<$Res>
    implements $IncomeBigCategoryEntityCopyWith<$Res> {
  factory _$$IncomeBigCategoryEntityImplCopyWith(
          _$IncomeBigCategoryEntityImpl value,
          $Res Function(_$IncomeBigCategoryEntityImpl) then) =
      __$$IncomeBigCategoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String colorCode, String iconPath});
}

/// @nodoc
class __$$IncomeBigCategoryEntityImplCopyWithImpl<$Res>
    extends _$IncomeBigCategoryEntityCopyWithImpl<$Res,
        _$IncomeBigCategoryEntityImpl>
    implements _$$IncomeBigCategoryEntityImplCopyWith<$Res> {
  __$$IncomeBigCategoryEntityImplCopyWithImpl(
      _$IncomeBigCategoryEntityImpl _value,
      $Res Function(_$IncomeBigCategoryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorCode = null,
    Object? iconPath = null,
  }) {
    return _then(_$IncomeBigCategoryEntityImpl(
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
      iconPath: null == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IncomeBigCategoryEntityImpl extends _IncomeBigCategoryEntity {
  const _$IncomeBigCategoryEntityImpl(
      {required this.id,
      required this.name,
      required this.colorCode,
      required this.iconPath})
      : super._();

  factory _$IncomeBigCategoryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$IncomeBigCategoryEntityImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String colorCode;
  @override
  final String iconPath;

  @override
  String toString() {
    return 'IncomeBigCategoryEntity(id: $id, name: $name, colorCode: $colorCode, iconPath: $iconPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeBigCategoryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, colorCode, iconPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomeBigCategoryEntityImplCopyWith<_$IncomeBigCategoryEntityImpl>
      get copyWith => __$$IncomeBigCategoryEntityImplCopyWithImpl<
          _$IncomeBigCategoryEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IncomeBigCategoryEntityImplToJson(
      this,
    );
  }
}

abstract class _IncomeBigCategoryEntity extends IncomeBigCategoryEntity {
  const factory _IncomeBigCategoryEntity(
      {required final int id,
      required final String name,
      required final String colorCode,
      required final String iconPath}) = _$IncomeBigCategoryEntityImpl;
  const _IncomeBigCategoryEntity._() : super._();

  factory _IncomeBigCategoryEntity.fromJson(Map<String, dynamic> json) =
      _$IncomeBigCategoryEntityImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get colorCode;
  @override
  String get iconPath;
  @override
  @JsonKey(ignore: true)
  _$$IncomeBigCategoryEntityImplCopyWith<_$IncomeBigCategoryEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
