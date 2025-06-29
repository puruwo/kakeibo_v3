// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_balance_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MonthlyBalanceValue {
  int get month => throw _privateConstructorUsedError;
  int get monthlyIncome => throw _privateConstructorUsedError;
  int get monthlyExpense => throw _privateConstructorUsedError;
  int get savings => throw _privateConstructorUsedError;
  MonthlyBalanceType get monthlyBalanceType =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MonthlyBalanceValueCopyWith<MonthlyBalanceValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyBalanceValueCopyWith<$Res> {
  factory $MonthlyBalanceValueCopyWith(
          MonthlyBalanceValue value, $Res Function(MonthlyBalanceValue) then) =
      _$MonthlyBalanceValueCopyWithImpl<$Res, MonthlyBalanceValue>;
  @useResult
  $Res call(
      {int month,
      int monthlyIncome,
      int monthlyExpense,
      int savings,
      MonthlyBalanceType monthlyBalanceType});
}

/// @nodoc
class _$MonthlyBalanceValueCopyWithImpl<$Res, $Val extends MonthlyBalanceValue>
    implements $MonthlyBalanceValueCopyWith<$Res> {
  _$MonthlyBalanceValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? monthlyIncome = null,
    Object? monthlyExpense = null,
    Object? savings = null,
    Object? monthlyBalanceType = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyIncome: null == monthlyIncome
          ? _value.monthlyIncome
          : monthlyIncome // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyExpense: null == monthlyExpense
          ? _value.monthlyExpense
          : monthlyExpense // ignore: cast_nullable_to_non_nullable
              as int,
      savings: null == savings
          ? _value.savings
          : savings // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyBalanceType: null == monthlyBalanceType
          ? _value.monthlyBalanceType
          : monthlyBalanceType // ignore: cast_nullable_to_non_nullable
              as MonthlyBalanceType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlyBalanceValueImplCopyWith<$Res>
    implements $MonthlyBalanceValueCopyWith<$Res> {
  factory _$$MonthlyBalanceValueImplCopyWith(_$MonthlyBalanceValueImpl value,
          $Res Function(_$MonthlyBalanceValueImpl) then) =
      __$$MonthlyBalanceValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int month,
      int monthlyIncome,
      int monthlyExpense,
      int savings,
      MonthlyBalanceType monthlyBalanceType});
}

/// @nodoc
class __$$MonthlyBalanceValueImplCopyWithImpl<$Res>
    extends _$MonthlyBalanceValueCopyWithImpl<$Res, _$MonthlyBalanceValueImpl>
    implements _$$MonthlyBalanceValueImplCopyWith<$Res> {
  __$$MonthlyBalanceValueImplCopyWithImpl(_$MonthlyBalanceValueImpl _value,
      $Res Function(_$MonthlyBalanceValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? monthlyIncome = null,
    Object? monthlyExpense = null,
    Object? savings = null,
    Object? monthlyBalanceType = null,
  }) {
    return _then(_$MonthlyBalanceValueImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyIncome: null == monthlyIncome
          ? _value.monthlyIncome
          : monthlyIncome // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyExpense: null == monthlyExpense
          ? _value.monthlyExpense
          : monthlyExpense // ignore: cast_nullable_to_non_nullable
              as int,
      savings: null == savings
          ? _value.savings
          : savings // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyBalanceType: null == monthlyBalanceType
          ? _value.monthlyBalanceType
          : monthlyBalanceType // ignore: cast_nullable_to_non_nullable
              as MonthlyBalanceType,
    ));
  }
}

/// @nodoc

class _$MonthlyBalanceValueImpl implements _MonthlyBalanceValue {
  const _$MonthlyBalanceValueImpl(
      {required this.month,
      required this.monthlyIncome,
      required this.monthlyExpense,
      required this.savings,
      required this.monthlyBalanceType});

  @override
  final int month;
  @override
  final int monthlyIncome;
  @override
  final int monthlyExpense;
  @override
  final int savings;
  @override
  final MonthlyBalanceType monthlyBalanceType;

  @override
  String toString() {
    return 'MonthlyBalanceValue(month: $month, monthlyIncome: $monthlyIncome, monthlyExpense: $monthlyExpense, savings: $savings, monthlyBalanceType: $monthlyBalanceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyBalanceValueImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.monthlyIncome, monthlyIncome) ||
                other.monthlyIncome == monthlyIncome) &&
            (identical(other.monthlyExpense, monthlyExpense) ||
                other.monthlyExpense == monthlyExpense) &&
            (identical(other.savings, savings) || other.savings == savings) &&
            (identical(other.monthlyBalanceType, monthlyBalanceType) ||
                other.monthlyBalanceType == monthlyBalanceType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month, monthlyIncome,
      monthlyExpense, savings, monthlyBalanceType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyBalanceValueImplCopyWith<_$MonthlyBalanceValueImpl> get copyWith =>
      __$$MonthlyBalanceValueImplCopyWithImpl<_$MonthlyBalanceValueImpl>(
          this, _$identity);
}

abstract class _MonthlyBalanceValue implements MonthlyBalanceValue {
  const factory _MonthlyBalanceValue(
          {required final int month,
          required final int monthlyIncome,
          required final int monthlyExpense,
          required final int savings,
          required final MonthlyBalanceType monthlyBalanceType}) =
      _$MonthlyBalanceValueImpl;

  @override
  int get month;
  @override
  int get monthlyIncome;
  @override
  int get monthlyExpense;
  @override
  int get savings;
  @override
  MonthlyBalanceType get monthlyBalanceType;
  @override
  @JsonKey(ignore: true)
  _$$MonthlyBalanceValueImplCopyWith<_$MonthlyBalanceValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
