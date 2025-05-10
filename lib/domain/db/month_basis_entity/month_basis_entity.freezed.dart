// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'month_basis_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MonthBasisEntity {
  MonthBasis get monthBasis => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MonthBasisEntityCopyWith<MonthBasisEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthBasisEntityCopyWith<$Res> {
  factory $MonthBasisEntityCopyWith(
          MonthBasisEntity value, $Res Function(MonthBasisEntity) then) =
      _$MonthBasisEntityCopyWithImpl<$Res, MonthBasisEntity>;
  @useResult
  $Res call({MonthBasis monthBasis});
}

/// @nodoc
class _$MonthBasisEntityCopyWithImpl<$Res, $Val extends MonthBasisEntity>
    implements $MonthBasisEntityCopyWith<$Res> {
  _$MonthBasisEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthBasis = null,
  }) {
    return _then(_value.copyWith(
      monthBasis: null == monthBasis
          ? _value.monthBasis
          : monthBasis // ignore: cast_nullable_to_non_nullable
              as MonthBasis,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthBasisEntityImplCopyWith<$Res>
    implements $MonthBasisEntityCopyWith<$Res> {
  factory _$$MonthBasisEntityImplCopyWith(_$MonthBasisEntityImpl value,
          $Res Function(_$MonthBasisEntityImpl) then) =
      __$$MonthBasisEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({MonthBasis monthBasis});
}

/// @nodoc
class __$$MonthBasisEntityImplCopyWithImpl<$Res>
    extends _$MonthBasisEntityCopyWithImpl<$Res, _$MonthBasisEntityImpl>
    implements _$$MonthBasisEntityImplCopyWith<$Res> {
  __$$MonthBasisEntityImplCopyWithImpl(_$MonthBasisEntityImpl _value,
      $Res Function(_$MonthBasisEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthBasis = null,
  }) {
    return _then(_$MonthBasisEntityImpl(
      monthBasis: null == monthBasis
          ? _value.monthBasis
          : monthBasis // ignore: cast_nullable_to_non_nullable
              as MonthBasis,
    ));
  }
}

/// @nodoc

class _$MonthBasisEntityImpl implements _MonthBasisEntity {
  const _$MonthBasisEntityImpl({required this.monthBasis});

  @override
  final MonthBasis monthBasis;

  @override
  String toString() {
    return 'MonthBasisEntity(monthBasis: $monthBasis)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthBasisEntityImpl &&
            (identical(other.monthBasis, monthBasis) ||
                other.monthBasis == monthBasis));
  }

  @override
  int get hashCode => Object.hash(runtimeType, monthBasis);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthBasisEntityImplCopyWith<_$MonthBasisEntityImpl> get copyWith =>
      __$$MonthBasisEntityImplCopyWithImpl<_$MonthBasisEntityImpl>(
          this, _$identity);
}

abstract class _MonthBasisEntity implements MonthBasisEntity {
  const factory _MonthBasisEntity({required final MonthBasis monthBasis}) =
      _$MonthBasisEntityImpl;

  @override
  MonthBasis get monthBasis;
  @override
  @JsonKey(ignore: true)
  _$$MonthBasisEntityImplCopyWith<_$MonthBasisEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
