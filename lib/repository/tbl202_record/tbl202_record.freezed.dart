// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tbl202_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TBL202Record _$TBL202RecordFromJson(Map<String, dynamic> json) {
  return _TBL202Record.fromJson(json);
}

/// @nodoc
mixin _$TBL202Record {
  int get id => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get bigCategoryName => throw _privateConstructorUsedError;
  String get resourcePath => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;
  int get isDisplayed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TBL202RecordCopyWith<TBL202Record> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TBL202RecordCopyWith<$Res> {
  factory $TBL202RecordCopyWith(
          TBL202Record value, $Res Function(TBL202Record) then) =
      _$TBL202RecordCopyWithImpl<$Res, TBL202Record>;
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
class _$TBL202RecordCopyWithImpl<$Res, $Val extends TBL202Record>
    implements $TBL202RecordCopyWith<$Res> {
  _$TBL202RecordCopyWithImpl(this._value, this._then);

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
abstract class _$$TBL202RecordImplCopyWith<$Res>
    implements $TBL202RecordCopyWith<$Res> {
  factory _$$TBL202RecordImplCopyWith(
          _$TBL202RecordImpl value, $Res Function(_$TBL202RecordImpl) then) =
      __$$TBL202RecordImplCopyWithImpl<$Res>;
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
class __$$TBL202RecordImplCopyWithImpl<$Res>
    extends _$TBL202RecordCopyWithImpl<$Res, _$TBL202RecordImpl>
    implements _$$TBL202RecordImplCopyWith<$Res> {
  __$$TBL202RecordImplCopyWithImpl(
      _$TBL202RecordImpl _value, $Res Function(_$TBL202RecordImpl) _then)
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
    return _then(_$TBL202RecordImpl(
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
class _$TBL202RecordImpl extends _TBL202Record {
  const _$TBL202RecordImpl(
      {required this.id,
      required this.colorCode,
      required this.bigCategoryName,
      required this.resourcePath,
      required this.displayOrder,
      required this.isDisplayed})
      : super._();

  factory _$TBL202RecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$TBL202RecordImplFromJson(json);

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
    return 'TBL202Record(id: $id, colorCode: $colorCode, bigCategoryName: $bigCategoryName, resourcePath: $resourcePath, displayOrder: $displayOrder, isDisplayed: $isDisplayed)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TBL202RecordImpl &&
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
  _$$TBL202RecordImplCopyWith<_$TBL202RecordImpl> get copyWith =>
      __$$TBL202RecordImplCopyWithImpl<_$TBL202RecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TBL202RecordImplToJson(
      this,
    );
  }
}

abstract class _TBL202Record extends TBL202Record {
  const factory _TBL202Record(
      {required final int id,
      required final String colorCode,
      required final String bigCategoryName,
      required final String resourcePath,
      required final int displayOrder,
      required final int isDisplayed}) = _$TBL202RecordImpl;
  const _TBL202Record._() : super._();

  factory _TBL202Record.fromJson(Map<String, dynamic> json) =
      _$TBL202RecordImpl.fromJson;

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
  _$$TBL202RecordImplCopyWith<_$TBL202RecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
