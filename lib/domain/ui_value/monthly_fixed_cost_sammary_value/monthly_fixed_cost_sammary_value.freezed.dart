// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_fixed_cost_sammary_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MonthlyFixedCostSummaryValue {
  int get fixedCostSum => throw _privateConstructorUsedError;
  int get unconfirmedFixedCostSum => throw _privateConstructorUsedError;
  int get scheduledPaymentAmount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MonthlyFixedCostSummaryValueCopyWith<MonthlyFixedCostSummaryValue>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyFixedCostSummaryValueCopyWith<$Res> {
  factory $MonthlyFixedCostSummaryValueCopyWith(
          MonthlyFixedCostSummaryValue value,
          $Res Function(MonthlyFixedCostSummaryValue) then) =
      _$MonthlyFixedCostSummaryValueCopyWithImpl<$Res,
          MonthlyFixedCostSummaryValue>;
  @useResult
  $Res call(
      {int fixedCostSum,
      int unconfirmedFixedCostSum,
      int scheduledPaymentAmount});
}

/// @nodoc
class _$MonthlyFixedCostSummaryValueCopyWithImpl<$Res,
        $Val extends MonthlyFixedCostSummaryValue>
    implements $MonthlyFixedCostSummaryValueCopyWith<$Res> {
  _$MonthlyFixedCostSummaryValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fixedCostSum = null,
    Object? unconfirmedFixedCostSum = null,
    Object? scheduledPaymentAmount = null,
  }) {
    return _then(_value.copyWith(
      fixedCostSum: null == fixedCostSum
          ? _value.fixedCostSum
          : fixedCostSum // ignore: cast_nullable_to_non_nullable
              as int,
      unconfirmedFixedCostSum: null == unconfirmedFixedCostSum
          ? _value.unconfirmedFixedCostSum
          : unconfirmedFixedCostSum // ignore: cast_nullable_to_non_nullable
              as int,
      scheduledPaymentAmount: null == scheduledPaymentAmount
          ? _value.scheduledPaymentAmount
          : scheduledPaymentAmount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlyFixedCostSummaryValueImplCopyWith<$Res>
    implements $MonthlyFixedCostSummaryValueCopyWith<$Res> {
  factory _$$MonthlyFixedCostSummaryValueImplCopyWith(
          _$MonthlyFixedCostSummaryValueImpl value,
          $Res Function(_$MonthlyFixedCostSummaryValueImpl) then) =
      __$$MonthlyFixedCostSummaryValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int fixedCostSum,
      int unconfirmedFixedCostSum,
      int scheduledPaymentAmount});
}

/// @nodoc
class __$$MonthlyFixedCostSummaryValueImplCopyWithImpl<$Res>
    extends _$MonthlyFixedCostSummaryValueCopyWithImpl<$Res,
        _$MonthlyFixedCostSummaryValueImpl>
    implements _$$MonthlyFixedCostSummaryValueImplCopyWith<$Res> {
  __$$MonthlyFixedCostSummaryValueImplCopyWithImpl(
      _$MonthlyFixedCostSummaryValueImpl _value,
      $Res Function(_$MonthlyFixedCostSummaryValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fixedCostSum = null,
    Object? unconfirmedFixedCostSum = null,
    Object? scheduledPaymentAmount = null,
  }) {
    return _then(_$MonthlyFixedCostSummaryValueImpl(
      fixedCostSum: null == fixedCostSum
          ? _value.fixedCostSum
          : fixedCostSum // ignore: cast_nullable_to_non_nullable
              as int,
      unconfirmedFixedCostSum: null == unconfirmedFixedCostSum
          ? _value.unconfirmedFixedCostSum
          : unconfirmedFixedCostSum // ignore: cast_nullable_to_non_nullable
              as int,
      scheduledPaymentAmount: null == scheduledPaymentAmount
          ? _value.scheduledPaymentAmount
          : scheduledPaymentAmount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MonthlyFixedCostSummaryValueImpl
    implements _MonthlyFixedCostSummaryValue {
  const _$MonthlyFixedCostSummaryValueImpl(
      {required this.fixedCostSum,
      required this.unconfirmedFixedCostSum,
      required this.scheduledPaymentAmount});

  @override
  final int fixedCostSum;
  @override
  final int unconfirmedFixedCostSum;
  @override
  final int scheduledPaymentAmount;

  @override
  String toString() {
    return 'MonthlyFixedCostSummaryValue(fixedCostSum: $fixedCostSum, unconfirmedFixedCostSum: $unconfirmedFixedCostSum, scheduledPaymentAmount: $scheduledPaymentAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyFixedCostSummaryValueImpl &&
            (identical(other.fixedCostSum, fixedCostSum) ||
                other.fixedCostSum == fixedCostSum) &&
            (identical(
                    other.unconfirmedFixedCostSum, unconfirmedFixedCostSum) ||
                other.unconfirmedFixedCostSum == unconfirmedFixedCostSum) &&
            (identical(other.scheduledPaymentAmount, scheduledPaymentAmount) ||
                other.scheduledPaymentAmount == scheduledPaymentAmount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fixedCostSum,
      unconfirmedFixedCostSum, scheduledPaymentAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyFixedCostSummaryValueImplCopyWith<
          _$MonthlyFixedCostSummaryValueImpl>
      get copyWith => __$$MonthlyFixedCostSummaryValueImplCopyWithImpl<
          _$MonthlyFixedCostSummaryValueImpl>(this, _$identity);
}

abstract class _MonthlyFixedCostSummaryValue
    implements MonthlyFixedCostSummaryValue {
  const factory _MonthlyFixedCostSummaryValue(
          {required final int fixedCostSum,
          required final int unconfirmedFixedCostSum,
          required final int scheduledPaymentAmount}) =
      _$MonthlyFixedCostSummaryValueImpl;

  @override
  int get fixedCostSum;
  @override
  int get unconfirmedFixedCostSum;
  @override
  int get scheduledPaymentAmount;
  @override
  @JsonKey(ignore: true)
  _$$MonthlyFixedCostSummaryValueImplCopyWith<
          _$MonthlyFixedCostSummaryValueImpl>
      get copyWith => throw _privateConstructorUsedError;
}
