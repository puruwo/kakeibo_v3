// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_frequency_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PaymentFrequencyValue {
  int get intervalNumber => throw _privateConstructorUsedError;
  PaymentFrequencyIntervalUnit get intervalUnit =>
      throw _privateConstructorUsedError;
  String get dateLabel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PaymentFrequencyValueCopyWith<PaymentFrequencyValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentFrequencyValueCopyWith<$Res> {
  factory $PaymentFrequencyValueCopyWith(PaymentFrequencyValue value,
          $Res Function(PaymentFrequencyValue) then) =
      _$PaymentFrequencyValueCopyWithImpl<$Res, PaymentFrequencyValue>;
  @useResult
  $Res call(
      {int intervalNumber,
      PaymentFrequencyIntervalUnit intervalUnit,
      String dateLabel});
}

/// @nodoc
class _$PaymentFrequencyValueCopyWithImpl<$Res,
        $Val extends PaymentFrequencyValue>
    implements $PaymentFrequencyValueCopyWith<$Res> {
  _$PaymentFrequencyValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? intervalNumber = null,
    Object? intervalUnit = null,
    Object? dateLabel = null,
  }) {
    return _then(_value.copyWith(
      intervalNumber: null == intervalNumber
          ? _value.intervalNumber
          : intervalNumber // ignore: cast_nullable_to_non_nullable
              as int,
      intervalUnit: null == intervalUnit
          ? _value.intervalUnit
          : intervalUnit // ignore: cast_nullable_to_non_nullable
              as PaymentFrequencyIntervalUnit,
      dateLabel: null == dateLabel
          ? _value.dateLabel
          : dateLabel // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentFrequencyValueImplCopyWith<$Res>
    implements $PaymentFrequencyValueCopyWith<$Res> {
  factory _$$PaymentFrequencyValueImplCopyWith(
          _$PaymentFrequencyValueImpl value,
          $Res Function(_$PaymentFrequencyValueImpl) then) =
      __$$PaymentFrequencyValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int intervalNumber,
      PaymentFrequencyIntervalUnit intervalUnit,
      String dateLabel});
}

/// @nodoc
class __$$PaymentFrequencyValueImplCopyWithImpl<$Res>
    extends _$PaymentFrequencyValueCopyWithImpl<$Res,
        _$PaymentFrequencyValueImpl>
    implements _$$PaymentFrequencyValueImplCopyWith<$Res> {
  __$$PaymentFrequencyValueImplCopyWithImpl(_$PaymentFrequencyValueImpl _value,
      $Res Function(_$PaymentFrequencyValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? intervalNumber = null,
    Object? intervalUnit = null,
    Object? dateLabel = null,
  }) {
    return _then(_$PaymentFrequencyValueImpl(
      intervalNumber: null == intervalNumber
          ? _value.intervalNumber
          : intervalNumber // ignore: cast_nullable_to_non_nullable
              as int,
      intervalUnit: null == intervalUnit
          ? _value.intervalUnit
          : intervalUnit // ignore: cast_nullable_to_non_nullable
              as PaymentFrequencyIntervalUnit,
      dateLabel: null == dateLabel
          ? _value.dateLabel
          : dateLabel // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PaymentFrequencyValueImpl implements _PaymentFrequencyValue {
  const _$PaymentFrequencyValueImpl(
      {required this.intervalNumber,
      required this.intervalUnit,
      required this.dateLabel});

  @override
  final int intervalNumber;
  @override
  final PaymentFrequencyIntervalUnit intervalUnit;
  @override
  final String dateLabel;

  @override
  String toString() {
    return 'PaymentFrequencyValue(intervalNumber: $intervalNumber, intervalUnit: $intervalUnit, dateLabel: $dateLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentFrequencyValueImpl &&
            (identical(other.intervalNumber, intervalNumber) ||
                other.intervalNumber == intervalNumber) &&
            (identical(other.intervalUnit, intervalUnit) ||
                other.intervalUnit == intervalUnit) &&
            (identical(other.dateLabel, dateLabel) ||
                other.dateLabel == dateLabel));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, intervalNumber, intervalUnit, dateLabel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentFrequencyValueImplCopyWith<_$PaymentFrequencyValueImpl>
      get copyWith => __$$PaymentFrequencyValueImplCopyWithImpl<
          _$PaymentFrequencyValueImpl>(this, _$identity);
}

abstract class _PaymentFrequencyValue implements PaymentFrequencyValue {
  const factory _PaymentFrequencyValue(
      {required final int intervalNumber,
      required final PaymentFrequencyIntervalUnit intervalUnit,
      required final String dateLabel}) = _$PaymentFrequencyValueImpl;

  @override
  int get intervalNumber;
  @override
  PaymentFrequencyIntervalUnit get intervalUnit;
  @override
  String get dateLabel;
  @override
  @JsonKey(ignore: true)
  _$$PaymentFrequencyValueImplCopyWith<_$PaymentFrequencyValueImpl>
      get copyWith => throw _privateConstructorUsedError;
}
