// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aggregation_start_month_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AggregationStartMonthEntity {
  int get month => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AggregationStartMonthEntityCopyWith<AggregationStartMonthEntity>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AggregationStartMonthEntityCopyWith<$Res> {
  factory $AggregationStartMonthEntityCopyWith(
          AggregationStartMonthEntity value,
          $Res Function(AggregationStartMonthEntity) then) =
      _$AggregationStartMonthEntityCopyWithImpl<$Res,
          AggregationStartMonthEntity>;
  @useResult
  $Res call({int month});
}

/// @nodoc
class _$AggregationStartMonthEntityCopyWithImpl<$Res,
        $Val extends AggregationStartMonthEntity>
    implements $AggregationStartMonthEntityCopyWith<$Res> {
  _$AggregationStartMonthEntityCopyWithImpl(this._value, this._then);

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
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AggregationStartMonthEntityImplCopyWith<$Res>
    implements $AggregationStartMonthEntityCopyWith<$Res> {
  factory _$$AggregationStartMonthEntityImplCopyWith(
          _$AggregationStartMonthEntityImpl value,
          $Res Function(_$AggregationStartMonthEntityImpl) then) =
      __$$AggregationStartMonthEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int month});
}

/// @nodoc
class __$$AggregationStartMonthEntityImplCopyWithImpl<$Res>
    extends _$AggregationStartMonthEntityCopyWithImpl<$Res,
        _$AggregationStartMonthEntityImpl>
    implements _$$AggregationStartMonthEntityImplCopyWith<$Res> {
  __$$AggregationStartMonthEntityImplCopyWithImpl(
      _$AggregationStartMonthEntityImpl _value,
      $Res Function(_$AggregationStartMonthEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
  }) {
    return _then(_$AggregationStartMonthEntityImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$AggregationStartMonthEntityImpl
    implements _AggregationStartMonthEntity {
  const _$AggregationStartMonthEntityImpl({required this.month});

  @override
  final int month;

  @override
  String toString() {
    return 'AggregationStartMonthEntity(month: $month)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AggregationStartMonthEntityImpl &&
            (identical(other.month, month) || other.month == month));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AggregationStartMonthEntityImplCopyWith<_$AggregationStartMonthEntityImpl>
      get copyWith => __$$AggregationStartMonthEntityImplCopyWithImpl<
          _$AggregationStartMonthEntityImpl>(this, _$identity);
}

abstract class _AggregationStartMonthEntity
    implements AggregationStartMonthEntity {
  const factory _AggregationStartMonthEntity({required final int month}) =
      _$AggregationStartMonthEntityImpl;

  @override
  int get month;
  @override
  @JsonKey(ignore: true)
  _$$AggregationStartMonthEntityImplCopyWith<_$AggregationStartMonthEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
