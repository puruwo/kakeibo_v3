// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'year_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$YearValue {
// ex)2025
  String get year => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $YearValueCopyWith<YearValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearValueCopyWith<$Res> {
  factory $YearValueCopyWith(YearValue value, $Res Function(YearValue) then) =
      _$YearValueCopyWithImpl<$Res, YearValue>;
  @useResult
  $Res call({String year});
}

/// @nodoc
class _$YearValueCopyWithImpl<$Res, $Val extends YearValue>
    implements $YearValueCopyWith<$Res> {
  _$YearValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
  }) {
    return _then(_value.copyWith(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YearValueImplCopyWith<$Res>
    implements $YearValueCopyWith<$Res> {
  factory _$$YearValueImplCopyWith(
          _$YearValueImpl value, $Res Function(_$YearValueImpl) then) =
      __$$YearValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String year});
}

/// @nodoc
class __$$YearValueImplCopyWithImpl<$Res>
    extends _$YearValueCopyWithImpl<$Res, _$YearValueImpl>
    implements _$$YearValueImplCopyWith<$Res> {
  __$$YearValueImplCopyWithImpl(
      _$YearValueImpl _value, $Res Function(_$YearValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
  }) {
    return _then(_$YearValueImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$YearValueImpl implements _YearValue {
  const _$YearValueImpl({required this.year});

// ex)2025
  @override
  final String year;

  @override
  String toString() {
    return 'YearValue(year: $year)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearValueImpl &&
            (identical(other.year, year) || other.year == year));
  }

  @override
  int get hashCode => Object.hash(runtimeType, year);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YearValueImplCopyWith<_$YearValueImpl> get copyWith =>
      __$$YearValueImplCopyWithImpl<_$YearValueImpl>(this, _$identity);
}

abstract class _YearValue implements YearValue {
  const factory _YearValue({required final String year}) = _$YearValueImpl;

  @override // ex)2025
  String get year;
  @override
  @JsonKey(ignore: true)
  _$$YearValueImplCopyWith<_$YearValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
