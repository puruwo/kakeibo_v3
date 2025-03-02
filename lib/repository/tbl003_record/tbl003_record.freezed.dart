// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tbl003_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TBL003Record _$TBL003RecordFromJson(Map<String, dynamic> json) {
  return _TBL003Record.fromJson(json);
}

/// @nodoc
mixin _$TBL003Record {
  int get id => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get bigCategory => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TBL003RecordCopyWith<TBL003Record> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TBL003RecordCopyWith<$Res> {
  factory $TBL003RecordCopyWith(
          TBL003Record value, $Res Function(TBL003Record) then) =
      _$TBL003RecordCopyWithImpl<$Res, TBL003Record>;
  @useResult
  $Res call({int id, String date, int bigCategory, int price});
}

/// @nodoc
class _$TBL003RecordCopyWithImpl<$Res, $Val extends TBL003Record>
    implements $TBL003RecordCopyWith<$Res> {
  _$TBL003RecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? bigCategory = null,
    Object? price = null,
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
      bigCategory: null == bigCategory
          ? _value.bigCategory
          : bigCategory // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TBL003RecordImplCopyWith<$Res>
    implements $TBL003RecordCopyWith<$Res> {
  factory _$$TBL003RecordImplCopyWith(
          _$TBL003RecordImpl value, $Res Function(_$TBL003RecordImpl) then) =
      __$$TBL003RecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String date, int bigCategory, int price});
}

/// @nodoc
class __$$TBL003RecordImplCopyWithImpl<$Res>
    extends _$TBL003RecordCopyWithImpl<$Res, _$TBL003RecordImpl>
    implements _$$TBL003RecordImplCopyWith<$Res> {
  __$$TBL003RecordImplCopyWithImpl(
      _$TBL003RecordImpl _value, $Res Function(_$TBL003RecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? bigCategory = null,
    Object? price = null,
  }) {
    return _then(_$TBL003RecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      bigCategory: null == bigCategory
          ? _value.bigCategory
          : bigCategory // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TBL003RecordImpl extends _TBL003Record {
  const _$TBL003RecordImpl(
      {this.id = 0,
      required this.date,
      required this.bigCategory,
      required this.price})
      : super._();

  factory _$TBL003RecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$TBL003RecordImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  final String date;
  @override
  final int bigCategory;
  @override
  final int price;

  @override
  String toString() {
    return 'TBL003Record(id: $id, date: $date, bigCategory: $bigCategory, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TBL003RecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.bigCategory, bigCategory) ||
                other.bigCategory == bigCategory) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, date, bigCategory, price);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TBL003RecordImplCopyWith<_$TBL003RecordImpl> get copyWith =>
      __$$TBL003RecordImplCopyWithImpl<_$TBL003RecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TBL003RecordImplToJson(
      this,
    );
  }
}

abstract class _TBL003Record extends TBL003Record {
  const factory _TBL003Record(
      {final int id,
      required final String date,
      required final int bigCategory,
      required final int price}) = _$TBL003RecordImpl;
  const _TBL003Record._() : super._();

  factory _TBL003Record.fromJson(Map<String, dynamic> json) =
      _$TBL003RecordImpl.fromJson;

  @override
  int get id;
  @override
  String get date;
  @override
  int get bigCategory;
  @override
  int get price;
  @override
  @JsonKey(ignore: true)
  _$$TBL003RecordImplCopyWith<_$TBL003RecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
