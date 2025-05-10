// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'month_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MonthValue {
// ex)202504
  String get month => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MonthValueCopyWith<MonthValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthValueCopyWith<$Res> {
  factory $MonthValueCopyWith(
          MonthValue value, $Res Function(MonthValue) then) =
      _$MonthValueCopyWithImpl<$Res, MonthValue>;
  @useResult
  $Res call({String month});
}

/// @nodoc
class _$MonthValueCopyWithImpl<$Res, $Val extends MonthValue>
    implements $MonthValueCopyWith<$Res> {
  _$MonthValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthValueImplCopyWith<$Res>
    implements $MonthValueCopyWith<$Res> {
  factory _$$MonthValueImplCopyWith(
          _$MonthValueImpl value, $Res Function(_$MonthValueImpl) then) =
      __$$MonthValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String month});
}

/// @nodoc
class __$$MonthValueImplCopyWithImpl<$Res>
    extends _$MonthValueCopyWithImpl<$Res, _$MonthValueImpl>
    implements _$$MonthValueImplCopyWith<$Res> {
  __$$MonthValueImplCopyWithImpl(
      _$MonthValueImpl _value, $Res Function(_$MonthValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
  }) {
    return _then(_$MonthValueImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MonthValueImpl implements _MonthValue {
  const _$MonthValueImpl({required this.month});

// ex)202504
  @override
  final String month;

  @override
  String toString() {
    return 'MonthValue(month: $month)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthValueImpl &&
            (identical(other.month, month) || other.month == month));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthValueImplCopyWith<_$MonthValueImpl> get copyWith =>
      __$$MonthValueImplCopyWithImpl<_$MonthValueImpl>(this, _$identity);
}

abstract class _MonthValue implements MonthValue {
  const factory _MonthValue({required final String month}) = _$MonthValueImpl;

  @override // ex)202504
  String get month;
  @override
  @JsonKey(ignore: true)
  _$$MonthValueImplCopyWith<_$MonthValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
