// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_plan_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MonthlyPlanValue {
  int get monthlyIncome => throw _privateConstructorUsedError;
  int get monthlyBudget => throw _privateConstructorUsedError;
  int get expectedSavings => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MonthlyPlanValueCopyWith<MonthlyPlanValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyPlanValueCopyWith<$Res> {
  factory $MonthlyPlanValueCopyWith(
          MonthlyPlanValue value, $Res Function(MonthlyPlanValue) then) =
      _$MonthlyPlanValueCopyWithImpl<$Res, MonthlyPlanValue>;
  @useResult
  $Res call({int monthlyIncome, int monthlyBudget, int expectedSavings});
}

/// @nodoc
class _$MonthlyPlanValueCopyWithImpl<$Res, $Val extends MonthlyPlanValue>
    implements $MonthlyPlanValueCopyWith<$Res> {
  _$MonthlyPlanValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyIncome = null,
    Object? monthlyBudget = null,
    Object? expectedSavings = null,
  }) {
    return _then(_value.copyWith(
      monthlyIncome: null == monthlyIncome
          ? _value.monthlyIncome
          : monthlyIncome // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyBudget: null == monthlyBudget
          ? _value.monthlyBudget
          : monthlyBudget // ignore: cast_nullable_to_non_nullable
              as int,
      expectedSavings: null == expectedSavings
          ? _value.expectedSavings
          : expectedSavings // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlyPlanValueImplCopyWith<$Res>
    implements $MonthlyPlanValueCopyWith<$Res> {
  factory _$$MonthlyPlanValueImplCopyWith(_$MonthlyPlanValueImpl value,
          $Res Function(_$MonthlyPlanValueImpl) then) =
      __$$MonthlyPlanValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int monthlyIncome, int monthlyBudget, int expectedSavings});
}

/// @nodoc
class __$$MonthlyPlanValueImplCopyWithImpl<$Res>
    extends _$MonthlyPlanValueCopyWithImpl<$Res, _$MonthlyPlanValueImpl>
    implements _$$MonthlyPlanValueImplCopyWith<$Res> {
  __$$MonthlyPlanValueImplCopyWithImpl(_$MonthlyPlanValueImpl _value,
      $Res Function(_$MonthlyPlanValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyIncome = null,
    Object? monthlyBudget = null,
    Object? expectedSavings = null,
  }) {
    return _then(_$MonthlyPlanValueImpl(
      monthlyIncome: null == monthlyIncome
          ? _value.monthlyIncome
          : monthlyIncome // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyBudget: null == monthlyBudget
          ? _value.monthlyBudget
          : monthlyBudget // ignore: cast_nullable_to_non_nullable
              as int,
      expectedSavings: null == expectedSavings
          ? _value.expectedSavings
          : expectedSavings // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MonthlyPlanValueImpl implements _MonthlyPlanValue {
  const _$MonthlyPlanValueImpl(
      {required this.monthlyIncome,
      required this.monthlyBudget,
      required this.expectedSavings});

  @override
  final int monthlyIncome;
  @override
  final int monthlyBudget;
  @override
  final int expectedSavings;

  @override
  String toString() {
    return 'MonthlyPlanValue(monthlyIncome: $monthlyIncome, monthlyBudget: $monthlyBudget, expectedSavings: $expectedSavings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyPlanValueImpl &&
            (identical(other.monthlyIncome, monthlyIncome) ||
                other.monthlyIncome == monthlyIncome) &&
            (identical(other.monthlyBudget, monthlyBudget) ||
                other.monthlyBudget == monthlyBudget) &&
            (identical(other.expectedSavings, expectedSavings) ||
                other.expectedSavings == expectedSavings));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, monthlyIncome, monthlyBudget, expectedSavings);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyPlanValueImplCopyWith<_$MonthlyPlanValueImpl> get copyWith =>
      __$$MonthlyPlanValueImplCopyWithImpl<_$MonthlyPlanValueImpl>(
          this, _$identity);
}

abstract class _MonthlyPlanValue implements MonthlyPlanValue {
  const factory _MonthlyPlanValue(
      {required final int monthlyIncome,
      required final int monthlyBudget,
      required final int expectedSavings}) = _$MonthlyPlanValueImpl;

  @override
  int get monthlyIncome;
  @override
  int get monthlyBudget;
  @override
  int get expectedSavings;
  @override
  @JsonKey(ignore: true)
  _$$MonthlyPlanValueImplCopyWith<_$MonthlyPlanValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
