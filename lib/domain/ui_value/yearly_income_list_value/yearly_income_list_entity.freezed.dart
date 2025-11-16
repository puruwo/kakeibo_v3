// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'yearly_income_list_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$YearlyIncomeListValue {
  List<MonthlyIncomeGroup> get monthlyGroups =>
      throw _privateConstructorUsedError;
  int get totalIncome => throw _privateConstructorUsedError;
  List<IncomeCategorySummaryValue> get categorySummaries =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $YearlyIncomeListValueCopyWith<YearlyIncomeListValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearlyIncomeListValueCopyWith<$Res> {
  factory $YearlyIncomeListValueCopyWith(YearlyIncomeListValue value,
          $Res Function(YearlyIncomeListValue) then) =
      _$YearlyIncomeListValueCopyWithImpl<$Res, YearlyIncomeListValue>;
  @useResult
  $Res call(
      {List<MonthlyIncomeGroup> monthlyGroups,
      int totalIncome,
      List<IncomeCategorySummaryValue> categorySummaries});
}

/// @nodoc
class _$YearlyIncomeListValueCopyWithImpl<$Res,
        $Val extends YearlyIncomeListValue>
    implements $YearlyIncomeListValueCopyWith<$Res> {
  _$YearlyIncomeListValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyGroups = null,
    Object? totalIncome = null,
    Object? categorySummaries = null,
  }) {
    return _then(_value.copyWith(
      monthlyGroups: null == monthlyGroups
          ? _value.monthlyGroups
          : monthlyGroups // ignore: cast_nullable_to_non_nullable
              as List<MonthlyIncomeGroup>,
      totalIncome: null == totalIncome
          ? _value.totalIncome
          : totalIncome // ignore: cast_nullable_to_non_nullable
              as int,
      categorySummaries: null == categorySummaries
          ? _value.categorySummaries
          : categorySummaries // ignore: cast_nullable_to_non_nullable
              as List<IncomeCategorySummaryValue>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YearlyIncomeListValueImplCopyWith<$Res>
    implements $YearlyIncomeListValueCopyWith<$Res> {
  factory _$$YearlyIncomeListValueImplCopyWith(
          _$YearlyIncomeListValueImpl value,
          $Res Function(_$YearlyIncomeListValueImpl) then) =
      __$$YearlyIncomeListValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<MonthlyIncomeGroup> monthlyGroups,
      int totalIncome,
      List<IncomeCategorySummaryValue> categorySummaries});
}

/// @nodoc
class __$$YearlyIncomeListValueImplCopyWithImpl<$Res>
    extends _$YearlyIncomeListValueCopyWithImpl<$Res,
        _$YearlyIncomeListValueImpl>
    implements _$$YearlyIncomeListValueImplCopyWith<$Res> {
  __$$YearlyIncomeListValueImplCopyWithImpl(_$YearlyIncomeListValueImpl _value,
      $Res Function(_$YearlyIncomeListValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyGroups = null,
    Object? totalIncome = null,
    Object? categorySummaries = null,
  }) {
    return _then(_$YearlyIncomeListValueImpl(
      monthlyGroups: null == monthlyGroups
          ? _value._monthlyGroups
          : monthlyGroups // ignore: cast_nullable_to_non_nullable
              as List<MonthlyIncomeGroup>,
      totalIncome: null == totalIncome
          ? _value.totalIncome
          : totalIncome // ignore: cast_nullable_to_non_nullable
              as int,
      categorySummaries: null == categorySummaries
          ? _value._categorySummaries
          : categorySummaries // ignore: cast_nullable_to_non_nullable
              as List<IncomeCategorySummaryValue>,
    ));
  }
}

/// @nodoc

class _$YearlyIncomeListValueImpl implements _YearlyIncomeListValue {
  const _$YearlyIncomeListValueImpl(
      {required final List<MonthlyIncomeGroup> monthlyGroups,
      required this.totalIncome,
      required final List<IncomeCategorySummaryValue> categorySummaries})
      : _monthlyGroups = monthlyGroups,
        _categorySummaries = categorySummaries;

  final List<MonthlyIncomeGroup> _monthlyGroups;
  @override
  List<MonthlyIncomeGroup> get monthlyGroups {
    if (_monthlyGroups is EqualUnmodifiableListView) return _monthlyGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthlyGroups);
  }

  @override
  final int totalIncome;
  final List<IncomeCategorySummaryValue> _categorySummaries;
  @override
  List<IncomeCategorySummaryValue> get categorySummaries {
    if (_categorySummaries is EqualUnmodifiableListView)
      return _categorySummaries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categorySummaries);
  }

  @override
  String toString() {
    return 'YearlyIncomeListValue(monthlyGroups: $monthlyGroups, totalIncome: $totalIncome, categorySummaries: $categorySummaries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearlyIncomeListValueImpl &&
            const DeepCollectionEquality()
                .equals(other._monthlyGroups, _monthlyGroups) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            const DeepCollectionEquality()
                .equals(other._categorySummaries, _categorySummaries));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_monthlyGroups),
      totalIncome,
      const DeepCollectionEquality().hash(_categorySummaries));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YearlyIncomeListValueImplCopyWith<_$YearlyIncomeListValueImpl>
      get copyWith => __$$YearlyIncomeListValueImplCopyWithImpl<
          _$YearlyIncomeListValueImpl>(this, _$identity);
}

abstract class _YearlyIncomeListValue implements YearlyIncomeListValue {
  const factory _YearlyIncomeListValue(
          {required final List<MonthlyIncomeGroup> monthlyGroups,
          required final int totalIncome,
          required final List<IncomeCategorySummaryValue> categorySummaries}) =
      _$YearlyIncomeListValueImpl;

  @override
  List<MonthlyIncomeGroup> get monthlyGroups;
  @override
  int get totalIncome;
  @override
  List<IncomeCategorySummaryValue> get categorySummaries;
  @override
  @JsonKey(ignore: true)
  _$$YearlyIncomeListValueImplCopyWith<_$YearlyIncomeListValueImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MonthlyIncomeGroup {
  String get monthLabel => throw _privateConstructorUsedError; // 例: "2023年 12月"
  List<IncomeHistoryTileValue> get incomes =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MonthlyIncomeGroupCopyWith<MonthlyIncomeGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyIncomeGroupCopyWith<$Res> {
  factory $MonthlyIncomeGroupCopyWith(
          MonthlyIncomeGroup value, $Res Function(MonthlyIncomeGroup) then) =
      _$MonthlyIncomeGroupCopyWithImpl<$Res, MonthlyIncomeGroup>;
  @useResult
  $Res call({String monthLabel, List<IncomeHistoryTileValue> incomes});
}

/// @nodoc
class _$MonthlyIncomeGroupCopyWithImpl<$Res, $Val extends MonthlyIncomeGroup>
    implements $MonthlyIncomeGroupCopyWith<$Res> {
  _$MonthlyIncomeGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthLabel = null,
    Object? incomes = null,
  }) {
    return _then(_value.copyWith(
      monthLabel: null == monthLabel
          ? _value.monthLabel
          : monthLabel // ignore: cast_nullable_to_non_nullable
              as String,
      incomes: null == incomes
          ? _value.incomes
          : incomes // ignore: cast_nullable_to_non_nullable
              as List<IncomeHistoryTileValue>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlyIncomeGroupImplCopyWith<$Res>
    implements $MonthlyIncomeGroupCopyWith<$Res> {
  factory _$$MonthlyIncomeGroupImplCopyWith(_$MonthlyIncomeGroupImpl value,
          $Res Function(_$MonthlyIncomeGroupImpl) then) =
      __$$MonthlyIncomeGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String monthLabel, List<IncomeHistoryTileValue> incomes});
}

/// @nodoc
class __$$MonthlyIncomeGroupImplCopyWithImpl<$Res>
    extends _$MonthlyIncomeGroupCopyWithImpl<$Res, _$MonthlyIncomeGroupImpl>
    implements _$$MonthlyIncomeGroupImplCopyWith<$Res> {
  __$$MonthlyIncomeGroupImplCopyWithImpl(_$MonthlyIncomeGroupImpl _value,
      $Res Function(_$MonthlyIncomeGroupImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthLabel = null,
    Object? incomes = null,
  }) {
    return _then(_$MonthlyIncomeGroupImpl(
      monthLabel: null == monthLabel
          ? _value.monthLabel
          : monthLabel // ignore: cast_nullable_to_non_nullable
              as String,
      incomes: null == incomes
          ? _value._incomes
          : incomes // ignore: cast_nullable_to_non_nullable
              as List<IncomeHistoryTileValue>,
    ));
  }
}

/// @nodoc

class _$MonthlyIncomeGroupImpl implements _MonthlyIncomeGroup {
  const _$MonthlyIncomeGroupImpl(
      {required this.monthLabel,
      required final List<IncomeHistoryTileValue> incomes})
      : _incomes = incomes;

  @override
  final String monthLabel;
// 例: "2023年 12月"
  final List<IncomeHistoryTileValue> _incomes;
// 例: "2023年 12月"
  @override
  List<IncomeHistoryTileValue> get incomes {
    if (_incomes is EqualUnmodifiableListView) return _incomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_incomes);
  }

  @override
  String toString() {
    return 'MonthlyIncomeGroup(monthLabel: $monthLabel, incomes: $incomes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyIncomeGroupImpl &&
            (identical(other.monthLabel, monthLabel) ||
                other.monthLabel == monthLabel) &&
            const DeepCollectionEquality().equals(other._incomes, _incomes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, monthLabel, const DeepCollectionEquality().hash(_incomes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyIncomeGroupImplCopyWith<_$MonthlyIncomeGroupImpl> get copyWith =>
      __$$MonthlyIncomeGroupImplCopyWithImpl<_$MonthlyIncomeGroupImpl>(
          this, _$identity);
}

abstract class _MonthlyIncomeGroup implements MonthlyIncomeGroup {
  const factory _MonthlyIncomeGroup(
          {required final String monthLabel,
          required final List<IncomeHistoryTileValue> incomes}) =
      _$MonthlyIncomeGroupImpl;

  @override
  String get monthLabel;
  @override // 例: "2023年 12月"
  List<IncomeHistoryTileValue> get incomes;
  @override
  @JsonKey(ignore: true)
  _$$MonthlyIncomeGroupImplCopyWith<_$MonthlyIncomeGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
