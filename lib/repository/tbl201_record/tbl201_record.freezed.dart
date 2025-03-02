// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tbl201_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TBL201Record _$TBL201RecordFromJson(Map<String, dynamic> json) {
  return _TBL201Record.fromJson(json);
}

/// @nodoc
mixin _$TBL201Record {
  int get id => throw _privateConstructorUsedError;
  int get smallCategoryOrderKey => throw _privateConstructorUsedError;
  int get bigCategoryKey => throw _privateConstructorUsedError;
  int get displayedOrderInBig => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  int get defaultDisplayed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TBL201RecordCopyWith<TBL201Record> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TBL201RecordCopyWith<$Res> {
  factory $TBL201RecordCopyWith(
          TBL201Record value, $Res Function(TBL201Record) then) =
      _$TBL201RecordCopyWithImpl<$Res, TBL201Record>;
  @useResult
  $Res call(
      {int id,
      int smallCategoryOrderKey,
      int bigCategoryKey,
      int displayedOrderInBig,
      String categoryName,
      int defaultDisplayed});
}

/// @nodoc
class _$TBL201RecordCopyWithImpl<$Res, $Val extends TBL201Record>
    implements $TBL201RecordCopyWith<$Res> {
  _$TBL201RecordCopyWithImpl(this._value, this._then);

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
    Object? displayedOrderInBig = null,
    Object? categoryName = null,
    Object? defaultDisplayed = null,
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
      displayedOrderInBig: null == displayedOrderInBig
          ? _value.displayedOrderInBig
          : displayedOrderInBig // ignore: cast_nullable_to_non_nullable
              as int,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      defaultDisplayed: null == defaultDisplayed
          ? _value.defaultDisplayed
          : defaultDisplayed // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TBL201RecordImplCopyWith<$Res>
    implements $TBL201RecordCopyWith<$Res> {
  factory _$$TBL201RecordImplCopyWith(
          _$TBL201RecordImpl value, $Res Function(_$TBL201RecordImpl) then) =
      __$$TBL201RecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int smallCategoryOrderKey,
      int bigCategoryKey,
      int displayedOrderInBig,
      String categoryName,
      int defaultDisplayed});
}

/// @nodoc
class __$$TBL201RecordImplCopyWithImpl<$Res>
    extends _$TBL201RecordCopyWithImpl<$Res, _$TBL201RecordImpl>
    implements _$$TBL201RecordImplCopyWith<$Res> {
  __$$TBL201RecordImplCopyWithImpl(
      _$TBL201RecordImpl _value, $Res Function(_$TBL201RecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smallCategoryOrderKey = null,
    Object? bigCategoryKey = null,
    Object? displayedOrderInBig = null,
    Object? categoryName = null,
    Object? defaultDisplayed = null,
  }) {
    return _then(_$TBL201RecordImpl(
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
      displayedOrderInBig: null == displayedOrderInBig
          ? _value.displayedOrderInBig
          : displayedOrderInBig // ignore: cast_nullable_to_non_nullable
              as int,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      defaultDisplayed: null == defaultDisplayed
          ? _value.defaultDisplayed
          : defaultDisplayed // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TBL201RecordImpl extends _TBL201Record {
  const _$TBL201RecordImpl(
      {required this.id,
      required this.smallCategoryOrderKey,
      required this.bigCategoryKey,
      required this.displayedOrderInBig,
      required this.categoryName,
      required this.defaultDisplayed})
      : super._();

  factory _$TBL201RecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$TBL201RecordImplFromJson(json);

  @override
  final int id;
  @override
  final int smallCategoryOrderKey;
  @override
  final int bigCategoryKey;
  @override
  final int displayedOrderInBig;
  @override
  final String categoryName;
  @override
  final int defaultDisplayed;

  @override
  String toString() {
    return 'TBL201Record(id: $id, smallCategoryOrderKey: $smallCategoryOrderKey, bigCategoryKey: $bigCategoryKey, displayedOrderInBig: $displayedOrderInBig, categoryName: $categoryName, defaultDisplayed: $defaultDisplayed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TBL201RecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.smallCategoryOrderKey, smallCategoryOrderKey) ||
                other.smallCategoryOrderKey == smallCategoryOrderKey) &&
            (identical(other.bigCategoryKey, bigCategoryKey) ||
                other.bigCategoryKey == bigCategoryKey) &&
            (identical(other.displayedOrderInBig, displayedOrderInBig) ||
                other.displayedOrderInBig == displayedOrderInBig) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.defaultDisplayed, defaultDisplayed) ||
                other.defaultDisplayed == defaultDisplayed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, smallCategoryOrderKey,
      bigCategoryKey, displayedOrderInBig, categoryName, defaultDisplayed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TBL201RecordImplCopyWith<_$TBL201RecordImpl> get copyWith =>
      __$$TBL201RecordImplCopyWithImpl<_$TBL201RecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TBL201RecordImplToJson(
      this,
    );
  }
}

abstract class _TBL201Record extends TBL201Record {
  const factory _TBL201Record(
      {required final int id,
      required final int smallCategoryOrderKey,
      required final int bigCategoryKey,
      required final int displayedOrderInBig,
      required final String categoryName,
      required final int defaultDisplayed}) = _$TBL201RecordImpl;
  const _TBL201Record._() : super._();

  factory _TBL201Record.fromJson(Map<String, dynamic> json) =
      _$TBL201RecordImpl.fromJson;

  @override
  int get id;
  @override
  int get smallCategoryOrderKey;
  @override
  int get bigCategoryKey;
  @override
  int get displayedOrderInBig;
  @override
  String get categoryName;
  @override
  int get defaultDisplayed;
  @override
  @JsonKey(ignore: true)
  _$$TBL201RecordImplCopyWith<_$TBL201RecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
