// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bonus_plan_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BonusPlanValue {
  int get yearlyBonusExpense => throw _privateConstructorUsedError;
  int get yearlyBonusIncome => throw _privateConstructorUsedError;
  int get lastBonusPrice => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BonusPlanValueCopyWith<BonusPlanValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BonusPlanValueCopyWith<$Res> {
  factory $BonusPlanValueCopyWith(
          BonusPlanValue value, $Res Function(BonusPlanValue) then) =
      _$BonusPlanValueCopyWithImpl<$Res, BonusPlanValue>;
  @useResult
  $Res call(
      {int yearlyBonusExpense, int yearlyBonusIncome, int lastBonusPrice});
}

/// @nodoc
class _$BonusPlanValueCopyWithImpl<$Res, $Val extends BonusPlanValue>
    implements $BonusPlanValueCopyWith<$Res> {
  _$BonusPlanValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? yearlyBonusExpense = null,
    Object? yearlyBonusIncome = null,
    Object? lastBonusPrice = null,
  }) {
    return _then(_value.copyWith(
      yearlyBonusExpense: null == yearlyBonusExpense
          ? _value.yearlyBonusExpense
          : yearlyBonusExpense // ignore: cast_nullable_to_non_nullable
              as int,
      yearlyBonusIncome: null == yearlyBonusIncome
          ? _value.yearlyBonusIncome
          : yearlyBonusIncome // ignore: cast_nullable_to_non_nullable
              as int,
      lastBonusPrice: null == lastBonusPrice
          ? _value.lastBonusPrice
          : lastBonusPrice // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BonusPlanValueImplCopyWith<$Res>
    implements $BonusPlanValueCopyWith<$Res> {
  factory _$$BonusPlanValueImplCopyWith(_$BonusPlanValueImpl value,
          $Res Function(_$BonusPlanValueImpl) then) =
      __$$BonusPlanValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int yearlyBonusExpense, int yearlyBonusIncome, int lastBonusPrice});
}

/// @nodoc
class __$$BonusPlanValueImplCopyWithImpl<$Res>
    extends _$BonusPlanValueCopyWithImpl<$Res, _$BonusPlanValueImpl>
    implements _$$BonusPlanValueImplCopyWith<$Res> {
  __$$BonusPlanValueImplCopyWithImpl(
      _$BonusPlanValueImpl _value, $Res Function(_$BonusPlanValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? yearlyBonusExpense = null,
    Object? yearlyBonusIncome = null,
    Object? lastBonusPrice = null,
  }) {
    return _then(_$BonusPlanValueImpl(
      yearlyBonusExpense: null == yearlyBonusExpense
          ? _value.yearlyBonusExpense
          : yearlyBonusExpense // ignore: cast_nullable_to_non_nullable
              as int,
      yearlyBonusIncome: null == yearlyBonusIncome
          ? _value.yearlyBonusIncome
          : yearlyBonusIncome // ignore: cast_nullable_to_non_nullable
              as int,
      lastBonusPrice: null == lastBonusPrice
          ? _value.lastBonusPrice
          : lastBonusPrice // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$BonusPlanValueImpl implements _BonusPlanValue {
  const _$BonusPlanValueImpl(
      {required this.yearlyBonusExpense,
      required this.yearlyBonusIncome,
      required this.lastBonusPrice});

  @override
  final int yearlyBonusExpense;
  @override
  final int yearlyBonusIncome;
  @override
  final int lastBonusPrice;

  @override
  String toString() {
    return 'BonusPlanValue(yearlyBonusExpense: $yearlyBonusExpense, yearlyBonusIncome: $yearlyBonusIncome, lastBonusPrice: $lastBonusPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BonusPlanValueImpl &&
            (identical(other.yearlyBonusExpense, yearlyBonusExpense) ||
                other.yearlyBonusExpense == yearlyBonusExpense) &&
            (identical(other.yearlyBonusIncome, yearlyBonusIncome) ||
                other.yearlyBonusIncome == yearlyBonusIncome) &&
            (identical(other.lastBonusPrice, lastBonusPrice) ||
                other.lastBonusPrice == lastBonusPrice));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, yearlyBonusExpense, yearlyBonusIncome, lastBonusPrice);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BonusPlanValueImplCopyWith<_$BonusPlanValueImpl> get copyWith =>
      __$$BonusPlanValueImplCopyWithImpl<_$BonusPlanValueImpl>(
          this, _$identity);
}

abstract class _BonusPlanValue implements BonusPlanValue {
  const factory _BonusPlanValue(
      {required final int yearlyBonusExpense,
      required final int yearlyBonusIncome,
      required final int lastBonusPrice}) = _$BonusPlanValueImpl;

  @override
  int get yearlyBonusExpense;
  @override
  int get yearlyBonusIncome;
  @override
  int get lastBonusPrice;
  @override
  @JsonKey(ignore: true)
  _$$BonusPlanValueImplCopyWith<_$BonusPlanValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
