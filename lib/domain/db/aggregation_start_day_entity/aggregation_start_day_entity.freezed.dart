// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aggregation_start_day_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AggregationStartDayEntity {
  int get day => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AggregationStartDayEntityCopyWith<AggregationStartDayEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AggregationStartDayEntityCopyWith<$Res> {
  factory $AggregationStartDayEntityCopyWith(AggregationStartDayEntity value,
          $Res Function(AggregationStartDayEntity) then) =
      _$AggregationStartDayEntityCopyWithImpl<$Res, AggregationStartDayEntity>;
  @useResult
  $Res call({int day});
}

/// @nodoc
class _$AggregationStartDayEntityCopyWithImpl<$Res,
        $Val extends AggregationStartDayEntity>
    implements $AggregationStartDayEntityCopyWith<$Res> {
  _$AggregationStartDayEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
  }) {
    return _then(_value.copyWith(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AggregationStartDayEntityImplCopyWith<$Res>
    implements $AggregationStartDayEntityCopyWith<$Res> {
  factory _$$AggregationStartDayEntityImplCopyWith(
          _$AggregationStartDayEntityImpl value,
          $Res Function(_$AggregationStartDayEntityImpl) then) =
      __$$AggregationStartDayEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int day});
}

/// @nodoc
class __$$AggregationStartDayEntityImplCopyWithImpl<$Res>
    extends _$AggregationStartDayEntityCopyWithImpl<$Res,
        _$AggregationStartDayEntityImpl>
    implements _$$AggregationStartDayEntityImplCopyWith<$Res> {
  __$$AggregationStartDayEntityImplCopyWithImpl(
      _$AggregationStartDayEntityImpl _value,
      $Res Function(_$AggregationStartDayEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
  }) {
    return _then(_$AggregationStartDayEntityImpl(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$AggregationStartDayEntityImpl implements _AggregationStartDayEntity {
  const _$AggregationStartDayEntityImpl({required this.day});

  @override
  final int day;

  @override
  String toString() {
    return 'AggregationStartDayEntity(day: $day)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AggregationStartDayEntityImpl &&
            (identical(other.day, day) || other.day == day));
  }

  @override
  int get hashCode => Object.hash(runtimeType, day);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AggregationStartDayEntityImplCopyWith<_$AggregationStartDayEntityImpl>
      get copyWith => __$$AggregationStartDayEntityImplCopyWithImpl<
          _$AggregationStartDayEntityImpl>(this, _$identity);
}

abstract class _AggregationStartDayEntity implements AggregationStartDayEntity {
  const factory _AggregationStartDayEntity({required final int day}) =
      _$AggregationStartDayEntityImpl;

  @override
  int get day;
  @override
  @JsonKey(ignore: true)
  _$$AggregationStartDayEntityImplCopyWith<_$AggregationStartDayEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
