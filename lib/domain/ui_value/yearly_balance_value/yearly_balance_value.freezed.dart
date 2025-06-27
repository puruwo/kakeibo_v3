// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'yearly_balance_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$YearlyBalanceValue {
  int get yearlyIncome => throw _privateConstructorUsedError;
  int get yearlyExpense => throw _privateConstructorUsedError;
  int get savings => throw _privateConstructorUsedError;
  YearlyBalanceType get yearlyBalanceType => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $YearlyBalanceValueCopyWith<YearlyBalanceValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearlyBalanceValueCopyWith<$Res> {
  factory $YearlyBalanceValueCopyWith(
          YearlyBalanceValue value, $Res Function(YearlyBalanceValue) then) =
      _$YearlyBalanceValueCopyWithImpl<$Res, YearlyBalanceValue>;
  @useResult
  $Res call(
      {int yearlyIncome,
      int yearlyExpense,
      int savings,
      YearlyBalanceType yearlyBalanceType});
}

/// @nodoc
class _$YearlyBalanceValueCopyWithImpl<$Res, $Val extends YearlyBalanceValue>
    implements $YearlyBalanceValueCopyWith<$Res> {
  _$YearlyBalanceValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? yearlyIncome = null,
    Object? yearlyExpense = null,
    Object? savings = null,
    Object? yearlyBalanceType = null,
  }) {
    return _then(_value.copyWith(
      yearlyIncome: null == yearlyIncome
          ? _value.yearlyIncome
          : yearlyIncome // ignore: cast_nullable_to_non_nullable
              as int,
      yearlyExpense: null == yearlyExpense
          ? _value.yearlyExpense
          : yearlyExpense // ignore: cast_nullable_to_non_nullable
              as int,
      savings: null == savings
          ? _value.savings
          : savings // ignore: cast_nullable_to_non_nullable
              as int,
      yearlyBalanceType: null == yearlyBalanceType
          ? _value.yearlyBalanceType
          : yearlyBalanceType // ignore: cast_nullable_to_non_nullable
              as YearlyBalanceType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YearlyBalanceValueImplCopyWith<$Res>
    implements $YearlyBalanceValueCopyWith<$Res> {
  factory _$$YearlyBalanceValueImplCopyWith(_$YearlyBalanceValueImpl value,
          $Res Function(_$YearlyBalanceValueImpl) then) =
      __$$YearlyBalanceValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int yearlyIncome,
      int yearlyExpense,
      int savings,
      YearlyBalanceType yearlyBalanceType});
}

/// @nodoc
class __$$YearlyBalanceValueImplCopyWithImpl<$Res>
    extends _$YearlyBalanceValueCopyWithImpl<$Res, _$YearlyBalanceValueImpl>
    implements _$$YearlyBalanceValueImplCopyWith<$Res> {
  __$$YearlyBalanceValueImplCopyWithImpl(_$YearlyBalanceValueImpl _value,
      $Res Function(_$YearlyBalanceValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? yearlyIncome = null,
    Object? yearlyExpense = null,
    Object? savings = null,
    Object? yearlyBalanceType = null,
  }) {
    return _then(_$YearlyBalanceValueImpl(
      yearlyIncome: null == yearlyIncome
          ? _value.yearlyIncome
          : yearlyIncome // ignore: cast_nullable_to_non_nullable
              as int,
      yearlyExpense: null == yearlyExpense
          ? _value.yearlyExpense
          : yearlyExpense // ignore: cast_nullable_to_non_nullable
              as int,
      savings: null == savings
          ? _value.savings
          : savings // ignore: cast_nullable_to_non_nullable
              as int,
      yearlyBalanceType: null == yearlyBalanceType
          ? _value.yearlyBalanceType
          : yearlyBalanceType // ignore: cast_nullable_to_non_nullable
              as YearlyBalanceType,
    ));
  }
}

/// @nodoc

class _$YearlyBalanceValueImpl implements _YearlyBalanceValue {
  const _$YearlyBalanceValueImpl(
      {required this.yearlyIncome,
      required this.yearlyExpense,
      required this.savings,
      required this.yearlyBalanceType});

  @override
  final int yearlyIncome;
  @override
  final int yearlyExpense;
  @override
  final int savings;
  @override
  final YearlyBalanceType yearlyBalanceType;

  @override
  String toString() {
    return 'YearlyBalanceValue(yearlyIncome: $yearlyIncome, yearlyExpense: $yearlyExpense, savings: $savings, yearlyBalanceType: $yearlyBalanceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearlyBalanceValueImpl &&
            (identical(other.yearlyIncome, yearlyIncome) ||
                other.yearlyIncome == yearlyIncome) &&
            (identical(other.yearlyExpense, yearlyExpense) ||
                other.yearlyExpense == yearlyExpense) &&
            (identical(other.savings, savings) || other.savings == savings) &&
            (identical(other.yearlyBalanceType, yearlyBalanceType) ||
                other.yearlyBalanceType == yearlyBalanceType));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, yearlyIncome, yearlyExpense, savings, yearlyBalanceType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YearlyBalanceValueImplCopyWith<_$YearlyBalanceValueImpl> get copyWith =>
      __$$YearlyBalanceValueImplCopyWithImpl<_$YearlyBalanceValueImpl>(
          this, _$identity);
}

abstract class _YearlyBalanceValue implements YearlyBalanceValue {
  const factory _YearlyBalanceValue(
          {required final int yearlyIncome,
          required final int yearlyExpense,
          required final int savings,
          required final YearlyBalanceType yearlyBalanceType}) =
      _$YearlyBalanceValueImpl;

  @override
  int get yearlyIncome;
  @override
  int get yearlyExpense;
  @override
  int get savings;
  @override
  YearlyBalanceType get yearlyBalanceType;
  @override
  @JsonKey(ignore: true)
  _$$YearlyBalanceValueImplCopyWith<_$YearlyBalanceValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
