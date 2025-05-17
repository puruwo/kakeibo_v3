// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'date_scope_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DateScopeEntity {
  DateTime get selectedDate => throw _privateConstructorUsedError;
  MonthPeriodValue get monthPeriod => throw _privateConstructorUsedError;
  MonthValue get representativeMonth => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DateScopeEntityCopyWith<DateScopeEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DateScopeEntityCopyWith<$Res> {
  factory $DateScopeEntityCopyWith(
          DateScopeEntity value, $Res Function(DateScopeEntity) then) =
      _$DateScopeEntityCopyWithImpl<$Res, DateScopeEntity>;
  @useResult
  $Res call(
      {DateTime selectedDate,
      MonthPeriodValue monthPeriod,
      MonthValue representativeMonth});

  $MonthPeriodValueCopyWith<$Res> get monthPeriod;
  $MonthValueCopyWith<$Res> get representativeMonth;
}

/// @nodoc
class _$DateScopeEntityCopyWithImpl<$Res, $Val extends DateScopeEntity>
    implements $DateScopeEntityCopyWith<$Res> {
  _$DateScopeEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? monthPeriod = null,
    Object? representativeMonth = null,
  }) {
    return _then(_value.copyWith(
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      monthPeriod: null == monthPeriod
          ? _value.monthPeriod
          : monthPeriod // ignore: cast_nullable_to_non_nullable
              as MonthPeriodValue,
      representativeMonth: null == representativeMonth
          ? _value.representativeMonth
          : representativeMonth // ignore: cast_nullable_to_non_nullable
              as MonthValue,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MonthPeriodValueCopyWith<$Res> get monthPeriod {
    return $MonthPeriodValueCopyWith<$Res>(_value.monthPeriod, (value) {
      return _then(_value.copyWith(monthPeriod: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MonthValueCopyWith<$Res> get representativeMonth {
    return $MonthValueCopyWith<$Res>(_value.representativeMonth, (value) {
      return _then(_value.copyWith(representativeMonth: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DateScopeEntityImplCopyWith<$Res>
    implements $DateScopeEntityCopyWith<$Res> {
  factory _$$DateScopeEntityImplCopyWith(_$DateScopeEntityImpl value,
          $Res Function(_$DateScopeEntityImpl) then) =
      __$$DateScopeEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime selectedDate,
      MonthPeriodValue monthPeriod,
      MonthValue representativeMonth});

  @override
  $MonthPeriodValueCopyWith<$Res> get monthPeriod;
  @override
  $MonthValueCopyWith<$Res> get representativeMonth;
}

/// @nodoc
class __$$DateScopeEntityImplCopyWithImpl<$Res>
    extends _$DateScopeEntityCopyWithImpl<$Res, _$DateScopeEntityImpl>
    implements _$$DateScopeEntityImplCopyWith<$Res> {
  __$$DateScopeEntityImplCopyWithImpl(
      _$DateScopeEntityImpl _value, $Res Function(_$DateScopeEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? monthPeriod = null,
    Object? representativeMonth = null,
  }) {
    return _then(_$DateScopeEntityImpl(
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      monthPeriod: null == monthPeriod
          ? _value.monthPeriod
          : monthPeriod // ignore: cast_nullable_to_non_nullable
              as MonthPeriodValue,
      representativeMonth: null == representativeMonth
          ? _value.representativeMonth
          : representativeMonth // ignore: cast_nullable_to_non_nullable
              as MonthValue,
    ));
  }
}

/// @nodoc

class _$DateScopeEntityImpl implements _DateScopeEntity {
  const _$DateScopeEntityImpl(
      {required this.selectedDate,
      required this.monthPeriod,
      required this.representativeMonth});

  @override
  final DateTime selectedDate;
  @override
  final MonthPeriodValue monthPeriod;
  @override
  final MonthValue representativeMonth;

  @override
  String toString() {
    return 'DateScopeEntity(selectedDate: $selectedDate, monthPeriod: $monthPeriod, representativeMonth: $representativeMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DateScopeEntityImpl &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            (identical(other.monthPeriod, monthPeriod) ||
                other.monthPeriod == monthPeriod) &&
            (identical(other.representativeMonth, representativeMonth) ||
                other.representativeMonth == representativeMonth));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, selectedDate, monthPeriod, representativeMonth);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DateScopeEntityImplCopyWith<_$DateScopeEntityImpl> get copyWith =>
      __$$DateScopeEntityImplCopyWithImpl<_$DateScopeEntityImpl>(
          this, _$identity);
}

abstract class _DateScopeEntity implements DateScopeEntity {
  const factory _DateScopeEntity(
      {required final DateTime selectedDate,
      required final MonthPeriodValue monthPeriod,
      required final MonthValue representativeMonth}) = _$DateScopeEntityImpl;

  @override
  DateTime get selectedDate;
  @override
  MonthPeriodValue get monthPeriod;
  @override
  MonthValue get representativeMonth;
  @override
  @JsonKey(ignore: true)
  _$$DateScopeEntityImplCopyWith<_$DateScopeEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
