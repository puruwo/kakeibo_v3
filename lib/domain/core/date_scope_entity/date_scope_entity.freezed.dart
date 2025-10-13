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
  PeriodValue get monthPeriod => throw _privateConstructorUsedError;
  int get monthIndex => throw _privateConstructorUsedError;
  MonthValue get representativeMonth => throw _privateConstructorUsedError;
  PeriodValue get yearPeriod => throw _privateConstructorUsedError;
  YearValue get representativeYear => throw _privateConstructorUsedError;

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
      PeriodValue monthPeriod,
      int monthIndex,
      MonthValue representativeMonth,
      PeriodValue yearPeriod,
      YearValue representativeYear});

  $PeriodValueCopyWith<$Res> get monthPeriod;
  $MonthValueCopyWith<$Res> get representativeMonth;
  $PeriodValueCopyWith<$Res> get yearPeriod;
  $YearValueCopyWith<$Res> get representativeYear;
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
    Object? monthIndex = null,
    Object? representativeMonth = null,
    Object? yearPeriod = null,
    Object? representativeYear = null,
  }) {
    return _then(_value.copyWith(
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      monthPeriod: null == monthPeriod
          ? _value.monthPeriod
          : monthPeriod // ignore: cast_nullable_to_non_nullable
              as PeriodValue,
      monthIndex: null == monthIndex
          ? _value.monthIndex
          : monthIndex // ignore: cast_nullable_to_non_nullable
              as int,
      representativeMonth: null == representativeMonth
          ? _value.representativeMonth
          : representativeMonth // ignore: cast_nullable_to_non_nullable
              as MonthValue,
      yearPeriod: null == yearPeriod
          ? _value.yearPeriod
          : yearPeriod // ignore: cast_nullable_to_non_nullable
              as PeriodValue,
      representativeYear: null == representativeYear
          ? _value.representativeYear
          : representativeYear // ignore: cast_nullable_to_non_nullable
              as YearValue,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PeriodValueCopyWith<$Res> get monthPeriod {
    return $PeriodValueCopyWith<$Res>(_value.monthPeriod, (value) {
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

  @override
  @pragma('vm:prefer-inline')
  $PeriodValueCopyWith<$Res> get yearPeriod {
    return $PeriodValueCopyWith<$Res>(_value.yearPeriod, (value) {
      return _then(_value.copyWith(yearPeriod: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $YearValueCopyWith<$Res> get representativeYear {
    return $YearValueCopyWith<$Res>(_value.representativeYear, (value) {
      return _then(_value.copyWith(representativeYear: value) as $Val);
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
      PeriodValue monthPeriod,
      int monthIndex,
      MonthValue representativeMonth,
      PeriodValue yearPeriod,
      YearValue representativeYear});

  @override
  $PeriodValueCopyWith<$Res> get monthPeriod;
  @override
  $MonthValueCopyWith<$Res> get representativeMonth;
  @override
  $PeriodValueCopyWith<$Res> get yearPeriod;
  @override
  $YearValueCopyWith<$Res> get representativeYear;
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
    Object? monthIndex = null,
    Object? representativeMonth = null,
    Object? yearPeriod = null,
    Object? representativeYear = null,
  }) {
    return _then(_$DateScopeEntityImpl(
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      monthPeriod: null == monthPeriod
          ? _value.monthPeriod
          : monthPeriod // ignore: cast_nullable_to_non_nullable
              as PeriodValue,
      monthIndex: null == monthIndex
          ? _value.monthIndex
          : monthIndex // ignore: cast_nullable_to_non_nullable
              as int,
      representativeMonth: null == representativeMonth
          ? _value.representativeMonth
          : representativeMonth // ignore: cast_nullable_to_non_nullable
              as MonthValue,
      yearPeriod: null == yearPeriod
          ? _value.yearPeriod
          : yearPeriod // ignore: cast_nullable_to_non_nullable
              as PeriodValue,
      representativeYear: null == representativeYear
          ? _value.representativeYear
          : representativeYear // ignore: cast_nullable_to_non_nullable
              as YearValue,
    ));
  }
}

/// @nodoc

class _$DateScopeEntityImpl implements _DateScopeEntity {
  const _$DateScopeEntityImpl(
      {required this.selectedDate,
      required this.monthPeriod,
      required this.monthIndex,
      required this.representativeMonth,
      required this.yearPeriod,
      required this.representativeYear});

  @override
  final DateTime selectedDate;
  @override
  final PeriodValue monthPeriod;
  @override
  final int monthIndex;
  @override
  final MonthValue representativeMonth;
  @override
  final PeriodValue yearPeriod;
  @override
  final YearValue representativeYear;

  @override
  String toString() {
    return 'DateScopeEntity(selectedDate: $selectedDate, monthPeriod: $monthPeriod, monthIndex: $monthIndex, representativeMonth: $representativeMonth, yearPeriod: $yearPeriod, representativeYear: $representativeYear)';
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
            (identical(other.monthIndex, monthIndex) ||
                other.monthIndex == monthIndex) &&
            (identical(other.representativeMonth, representativeMonth) ||
                other.representativeMonth == representativeMonth) &&
            (identical(other.yearPeriod, yearPeriod) ||
                other.yearPeriod == yearPeriod) &&
            (identical(other.representativeYear, representativeYear) ||
                other.representativeYear == representativeYear));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedDate, monthPeriod,
      monthIndex, representativeMonth, yearPeriod, representativeYear);

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
      required final PeriodValue monthPeriod,
      required final int monthIndex,
      required final MonthValue representativeMonth,
      required final PeriodValue yearPeriod,
      required final YearValue representativeYear}) = _$DateScopeEntityImpl;

  @override
  DateTime get selectedDate;
  @override
  PeriodValue get monthPeriod;
  @override
  int get monthIndex;
  @override
  MonthValue get representativeMonth;
  @override
  PeriodValue get yearPeriod;
  @override
  YearValue get representativeYear;
  @override
  @JsonKey(ignore: true)
  _$$DateScopeEntityImplCopyWith<_$DateScopeEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
