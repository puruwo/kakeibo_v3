// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'torok_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TorokRecord _$TorokRecordFromJson(Map<String, dynamic> json) {
  return _TorokRecord.fromJson(json);
}

/// @nodoc
mixin _$TorokRecord {
  int get id => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  int get categoryOrderKey => throw _privateConstructorUsedError;
  String get memo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TorokRecordCopyWith<TorokRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TorokRecordCopyWith<$Res> {
  factory $TorokRecordCopyWith(
          TorokRecord value, $Res Function(TorokRecord) then) =
      _$TorokRecordCopyWithImpl<$Res, TorokRecord>;
  @useResult
  $Res call(
      {int id, String date, int price, int categoryOrderKey, String memo});
}

/// @nodoc
class _$TorokRecordCopyWithImpl<$Res, $Val extends TorokRecord>
    implements $TorokRecordCopyWith<$Res> {
  _$TorokRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? price = null,
    Object? categoryOrderKey = null,
    Object? memo = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      categoryOrderKey: null == categoryOrderKey
          ? _value.categoryOrderKey
          : categoryOrderKey // ignore: cast_nullable_to_non_nullable
              as int,
      memo: null == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TorokRecordImplCopyWith<$Res>
    implements $TorokRecordCopyWith<$Res> {
  factory _$$TorokRecordImplCopyWith(
          _$TorokRecordImpl value, $Res Function(_$TorokRecordImpl) then) =
      __$$TorokRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id, String date, int price, int categoryOrderKey, String memo});
}

/// @nodoc
class __$$TorokRecordImplCopyWithImpl<$Res>
    extends _$TorokRecordCopyWithImpl<$Res, _$TorokRecordImpl>
    implements _$$TorokRecordImplCopyWith<$Res> {
  __$$TorokRecordImplCopyWithImpl(
      _$TorokRecordImpl _value, $Res Function(_$TorokRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? price = null,
    Object? categoryOrderKey = null,
    Object? memo = null,
  }) {
    return _then(_$TorokRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      categoryOrderKey: null == categoryOrderKey
          ? _value.categoryOrderKey
          : categoryOrderKey // ignore: cast_nullable_to_non_nullable
              as int,
      memo: null == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TorokRecordImpl extends _TorokRecord {
  _$TorokRecordImpl(
      {this.id = 0,
      required this.date,
      this.price = 0,
      this.categoryOrderKey = 0,
      this.memo = ''})
      : super._();

  factory _$TorokRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$TorokRecordImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  final String date;
  @override
  @JsonKey()
  final int price;
  @override
  @JsonKey()
  final int categoryOrderKey;
  @override
  @JsonKey()
  final String memo;

  @override
  String toString() {
    return 'TorokRecord(id: $id, date: $date, price: $price, categoryOrderKey: $categoryOrderKey, memo: $memo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TorokRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.categoryOrderKey, categoryOrderKey) ||
                other.categoryOrderKey == categoryOrderKey) &&
            (identical(other.memo, memo) || other.memo == memo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, date, price, categoryOrderKey, memo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TorokRecordImplCopyWith<_$TorokRecordImpl> get copyWith =>
      __$$TorokRecordImplCopyWithImpl<_$TorokRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TorokRecordImplToJson(
      this,
    );
  }
}

abstract class _TorokRecord extends TorokRecord {
  factory _TorokRecord(
      {final int id,
      required final String date,
      final int price,
      final int categoryOrderKey,
      final String memo}) = _$TorokRecordImpl;
  _TorokRecord._() : super._();

  factory _TorokRecord.fromJson(Map<String, dynamic> json) =
      _$TorokRecordImpl.fromJson;

  @override
  int get id;
  @override
  String get date;
  @override
  int get price;
  @override
  int get categoryOrderKey;
  @override
  String get memo;
  @override
  @JsonKey(ignore: true)
  _$$TorokRecordImplCopyWith<_$TorokRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
