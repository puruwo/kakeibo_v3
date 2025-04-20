// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExpenseEntity _$ExpenseEntityFromJson(Map<String, dynamic> json) {
  return _ExpenseEntity.fromJson(json);
}

/// @nodoc
mixin _$ExpenseEntity {
  int get id => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  int get paymentCategoryId => throw _privateConstructorUsedError;
  String get memo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExpenseEntityCopyWith<ExpenseEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseEntityCopyWith<$Res> {
  factory $ExpenseEntityCopyWith(
          ExpenseEntity value, $Res Function(ExpenseEntity) then) =
      _$ExpenseEntityCopyWithImpl<$Res, ExpenseEntity>;
  @useResult
  $Res call(
      {int id, String date, int price, int paymentCategoryId, String memo});
}

/// @nodoc
class _$ExpenseEntityCopyWithImpl<$Res, $Val extends ExpenseEntity>
    implements $ExpenseEntityCopyWith<$Res> {
  _$ExpenseEntityCopyWithImpl(this._value, this._then);

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
    Object? paymentCategoryId = null,
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
      paymentCategoryId: null == paymentCategoryId
          ? _value.paymentCategoryId
          : paymentCategoryId // ignore: cast_nullable_to_non_nullable
              as int,
      memo: null == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpenseEntityImplCopyWith<$Res>
    implements $ExpenseEntityCopyWith<$Res> {
  factory _$$ExpenseEntityImplCopyWith(
          _$ExpenseEntityImpl value, $Res Function(_$ExpenseEntityImpl) then) =
      __$$ExpenseEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id, String date, int price, int paymentCategoryId, String memo});
}

/// @nodoc
class __$$ExpenseEntityImplCopyWithImpl<$Res>
    extends _$ExpenseEntityCopyWithImpl<$Res, _$ExpenseEntityImpl>
    implements _$$ExpenseEntityImplCopyWith<$Res> {
  __$$ExpenseEntityImplCopyWithImpl(
      _$ExpenseEntityImpl _value, $Res Function(_$ExpenseEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? price = null,
    Object? paymentCategoryId = null,
    Object? memo = null,
  }) {
    return _then(_$ExpenseEntityImpl(
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
      paymentCategoryId: null == paymentCategoryId
          ? _value.paymentCategoryId
          : paymentCategoryId // ignore: cast_nullable_to_non_nullable
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
class _$ExpenseEntityImpl implements _ExpenseEntity {
  const _$ExpenseEntityImpl(
      {required this.id,
      required this.date,
      required this.price,
      required this.paymentCategoryId,
      this.memo = ''});

  factory _$ExpenseEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseEntityImplFromJson(json);

  @override
  final int id;
  @override
  final String date;
  @override
  final int price;
  @override
  final int paymentCategoryId;
  @override
  @JsonKey()
  final String memo;

  @override
  String toString() {
    return 'ExpenseEntity(id: $id, date: $date, price: $price, paymentCategoryId: $paymentCategoryId, memo: $memo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.paymentCategoryId, paymentCategoryId) ||
                other.paymentCategoryId == paymentCategoryId) &&
            (identical(other.memo, memo) || other.memo == memo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, date, price, paymentCategoryId, memo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseEntityImplCopyWith<_$ExpenseEntityImpl> get copyWith =>
      __$$ExpenseEntityImplCopyWithImpl<_$ExpenseEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseEntityImplToJson(
      this,
    );
  }
}

abstract class _ExpenseEntity implements ExpenseEntity {
  const factory _ExpenseEntity(
      {required final int id,
      required final String date,
      required final int price,
      required final int paymentCategoryId,
      final String memo}) = _$ExpenseEntityImpl;

  factory _ExpenseEntity.fromJson(Map<String, dynamic> json) =
      _$ExpenseEntityImpl.fromJson;

  @override
  int get id;
  @override
  String get date;
  @override
  int get price;
  @override
  int get paymentCategoryId;
  @override
  String get memo;
  @override
  @JsonKey(ignore: true)
  _$$ExpenseEntityImplCopyWith<_$ExpenseEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
