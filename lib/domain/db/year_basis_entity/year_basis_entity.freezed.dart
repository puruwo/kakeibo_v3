// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'year_basis_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$YearBasisEntity {
  YearBasis get monthBasis => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $YearBasisEntityCopyWith<YearBasisEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearBasisEntityCopyWith<$Res> {
  factory $YearBasisEntityCopyWith(
          YearBasisEntity value, $Res Function(YearBasisEntity) then) =
      _$YearBasisEntityCopyWithImpl<$Res, YearBasisEntity>;
  @useResult
  $Res call({YearBasis monthBasis});
}

/// @nodoc
class _$YearBasisEntityCopyWithImpl<$Res, $Val extends YearBasisEntity>
    implements $YearBasisEntityCopyWith<$Res> {
  _$YearBasisEntityCopyWithImpl(this._value, this._then);

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
              as YearBasis,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YearBasisEntityImplCopyWith<$Res>
    implements $YearBasisEntityCopyWith<$Res> {
  factory _$$YearBasisEntityImplCopyWith(_$YearBasisEntityImpl value,
          $Res Function(_$YearBasisEntityImpl) then) =
      __$$YearBasisEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({YearBasis monthBasis});
}

/// @nodoc
class __$$YearBasisEntityImplCopyWithImpl<$Res>
    extends _$YearBasisEntityCopyWithImpl<$Res, _$YearBasisEntityImpl>
    implements _$$YearBasisEntityImplCopyWith<$Res> {
  __$$YearBasisEntityImplCopyWithImpl(
      _$YearBasisEntityImpl _value, $Res Function(_$YearBasisEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthBasis = null,
  }) {
    return _then(_$YearBasisEntityImpl(
      monthBasis: null == monthBasis
          ? _value.monthBasis
          : monthBasis // ignore: cast_nullable_to_non_nullable
              as YearBasis,
    ));
  }
}

/// @nodoc

class _$YearBasisEntityImpl implements _YearBasisEntity {
  const _$YearBasisEntityImpl({required this.monthBasis});

  @override
  final YearBasis monthBasis;

  @override
  String toString() {
    return 'YearBasisEntity(monthBasis: $monthBasis)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearBasisEntityImpl &&
            (identical(other.monthBasis, monthBasis) ||
                other.monthBasis == monthBasis));
  }

  @override
  int get hashCode => Object.hash(runtimeType, monthBasis);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YearBasisEntityImplCopyWith<_$YearBasisEntityImpl> get copyWith =>
      __$$YearBasisEntityImplCopyWithImpl<_$YearBasisEntityImpl>(
          this, _$identity);
}

abstract class _YearBasisEntity implements YearBasisEntity {
  const factory _YearBasisEntity({required final YearBasis monthBasis}) =
      _$YearBasisEntityImpl;

  @override
  YearBasis get monthBasis;
  @override
  @JsonKey(ignore: true)
  _$$YearBasisEntityImplCopyWith<_$YearBasisEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
