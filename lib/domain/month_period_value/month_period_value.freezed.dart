// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'month_period_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MonthPeriodValue {
  DateTime get startDatetime => throw _privateConstructorUsedError;
  DateTime get endDatetime => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MonthPeriodValueCopyWith<MonthPeriodValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthPeriodValueCopyWith<$Res> {
  factory $MonthPeriodValueCopyWith(
          MonthPeriodValue value, $Res Function(MonthPeriodValue) then) =
      _$MonthPeriodValueCopyWithImpl<$Res, MonthPeriodValue>;
  @useResult
  $Res call({DateTime startDatetime, DateTime endDatetime});
}

/// @nodoc
class _$MonthPeriodValueCopyWithImpl<$Res, $Val extends MonthPeriodValue>
    implements $MonthPeriodValueCopyWith<$Res> {
  _$MonthPeriodValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDatetime = null,
    Object? endDatetime = null,
  }) {
    return _then(_value.copyWith(
      startDatetime: null == startDatetime
          ? _value.startDatetime
          : startDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDatetime: null == endDatetime
          ? _value.endDatetime
          : endDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthPeriodValueImplCopyWith<$Res>
    implements $MonthPeriodValueCopyWith<$Res> {
  factory _$$MonthPeriodValueImplCopyWith(_$MonthPeriodValueImpl value,
          $Res Function(_$MonthPeriodValueImpl) then) =
      __$$MonthPeriodValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime startDatetime, DateTime endDatetime});
}

/// @nodoc
class __$$MonthPeriodValueImplCopyWithImpl<$Res>
    extends _$MonthPeriodValueCopyWithImpl<$Res, _$MonthPeriodValueImpl>
    implements _$$MonthPeriodValueImplCopyWith<$Res> {
  __$$MonthPeriodValueImplCopyWithImpl(_$MonthPeriodValueImpl _value,
      $Res Function(_$MonthPeriodValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDatetime = null,
    Object? endDatetime = null,
  }) {
    return _then(_$MonthPeriodValueImpl(
      startDatetime: null == startDatetime
          ? _value.startDatetime
          : startDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDatetime: null == endDatetime
          ? _value.endDatetime
          : endDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$MonthPeriodValueImpl implements _MonthPeriodValue {
  const _$MonthPeriodValueImpl(
      {required this.startDatetime, required this.endDatetime});

  @override
  final DateTime startDatetime;
  @override
  final DateTime endDatetime;

  @override
  String toString() {
    return 'MonthPeriodValue(startDatetime: $startDatetime, endDatetime: $endDatetime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthPeriodValueImpl &&
            (identical(other.startDatetime, startDatetime) ||
                other.startDatetime == startDatetime) &&
            (identical(other.endDatetime, endDatetime) ||
                other.endDatetime == endDatetime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startDatetime, endDatetime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthPeriodValueImplCopyWith<_$MonthPeriodValueImpl> get copyWith =>
      __$$MonthPeriodValueImplCopyWithImpl<_$MonthPeriodValueImpl>(
          this, _$identity);
}

abstract class _MonthPeriodValue implements MonthPeriodValue {
  const factory _MonthPeriodValue(
      {required final DateTime startDatetime,
      required final DateTime endDatetime}) = _$MonthPeriodValueImpl;

  @override
  DateTime get startDatetime;
  @override
  DateTime get endDatetime;
  @override
  @JsonKey(ignore: true)
  _$$MonthPeriodValueImplCopyWith<_$MonthPeriodValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
