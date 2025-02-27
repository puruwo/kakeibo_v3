// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tbl001_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TBL001Record _$TBL001RecordFromJson(Map<String, dynamic> json) {
  return _TBL001Record.fromJson(json);
}

/// @nodoc
mixin _$TBL001Record {
  int get id => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  int get category => throw _privateConstructorUsedError;
  String get memo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TBL001RecordCopyWith<TBL001Record> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TBL001RecordCopyWith<$Res> {
  factory $TBL001RecordCopyWith(
          TBL001Record value, $Res Function(TBL001Record) then) =
      _$TBL001RecordCopyWithImpl<$Res, TBL001Record>;
  @useResult
  $Res call({int id, String date, int price, int category, String memo});
}

/// @nodoc
class _$TBL001RecordCopyWithImpl<$Res, $Val extends TBL001Record>
    implements $TBL001RecordCopyWith<$Res> {
  _$TBL001RecordCopyWithImpl(this._value, this._then);

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
    Object? category = null,
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      memo: null == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TBL001RecordImplCopyWith<$Res>
    implements $TBL001RecordCopyWith<$Res> {
  factory _$$TBL001RecordImplCopyWith(
          _$TBL001RecordImpl value, $Res Function(_$TBL001RecordImpl) then) =
      __$$TBL001RecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String date, int price, int category, String memo});
}

/// @nodoc
class __$$TBL001RecordImplCopyWithImpl<$Res>
    extends _$TBL001RecordCopyWithImpl<$Res, _$TBL001RecordImpl>
    implements _$$TBL001RecordImplCopyWith<$Res> {
  __$$TBL001RecordImplCopyWithImpl(
      _$TBL001RecordImpl _value, $Res Function(_$TBL001RecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? price = null,
    Object? category = null,
    Object? memo = null,
  }) {
    return _then(_$TBL001RecordImpl(
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
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
class _$TBL001RecordImpl extends _TBL001Record {
  const _$TBL001RecordImpl(
      {this.id = 0,
      required this.date,
      this.price = 0,
      this.category = 0,
      this.memo = ''})
      : super._();

  factory _$TBL001RecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$TBL001RecordImplFromJson(json);

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
  final int category;
  @override
  @JsonKey()
  final String memo;

  @override
  String toString() {
    return 'TBL001Record(id: $id, date: $date, price: $price, category: $category, memo: $memo)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TBL001RecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.memo, memo) || other.memo == memo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, date, price, category, memo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TBL001RecordImplCopyWith<_$TBL001RecordImpl> get copyWith =>
      __$$TBL001RecordImplCopyWithImpl<_$TBL001RecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TBL001RecordImplToJson(
      this,
    );
  }
}

abstract class _TBL001Record extends TBL001Record {
  const factory _TBL001Record(
      {final int id,
      required final String date,
      final int price,
      final int category,
      final String memo}) = _$TBL001RecordImpl;
  const _TBL001Record._() : super._();

  factory _TBL001Record.fromJson(Map<String, dynamic> json) =
      _$TBL001RecordImpl.fromJson;

  @override
  int get id;
  @override
  String get date;
  @override
  int get price;
  @override
  int get category;
  @override
  String get memo;
  @override
  @JsonKey(ignore: true)
  _$$TBL001RecordImplCopyWith<_$TBL001RecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
