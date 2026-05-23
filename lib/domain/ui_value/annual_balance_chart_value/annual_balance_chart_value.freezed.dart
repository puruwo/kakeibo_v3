// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'annual_balance_chart_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AnnualBalanceChartValue {
  int get monthIndex => throw _privateConstructorUsedError; // 現在の月のインデックス
  int get currentMonth => throw _privateConstructorUsedError; // 現在の月
  List<MonthlyBalanceValue> get monthlyBalanceValues =>
      throw _privateConstructorUsedError;
  bool get hasNoRecord => throw _privateConstructorUsedError; // 未来の月のみの収支かどうか
  YAxisScale get yAxisScale => throw _privateConstructorUsedError;

  /// Create a copy of AnnualBalanceChartValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnnualBalanceChartValueCopyWith<AnnualBalanceChartValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnualBalanceChartValueCopyWith<$Res> {
  factory $AnnualBalanceChartValueCopyWith(
    AnnualBalanceChartValue value,
    $Res Function(AnnualBalanceChartValue) then,
  ) = _$AnnualBalanceChartValueCopyWithImpl<$Res, AnnualBalanceChartValue>;
  @useResult
  $Res call({
    int monthIndex,
    int currentMonth,
    List<MonthlyBalanceValue> monthlyBalanceValues,
    bool hasNoRecord,
    YAxisScale yAxisScale,
  });

  $YAxisScaleCopyWith<$Res> get yAxisScale;
}

/// @nodoc
class _$AnnualBalanceChartValueCopyWithImpl<
  $Res,
  $Val extends AnnualBalanceChartValue
>
    implements $AnnualBalanceChartValueCopyWith<$Res> {
  _$AnnualBalanceChartValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnnualBalanceChartValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthIndex = null,
    Object? currentMonth = null,
    Object? monthlyBalanceValues = null,
    Object? hasNoRecord = null,
    Object? yAxisScale = null,
  }) {
    return _then(
      _value.copyWith(
            monthIndex: null == monthIndex
                ? _value.monthIndex
                : monthIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            currentMonth: null == currentMonth
                ? _value.currentMonth
                : currentMonth // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyBalanceValues: null == monthlyBalanceValues
                ? _value.monthlyBalanceValues
                : monthlyBalanceValues // ignore: cast_nullable_to_non_nullable
                      as List<MonthlyBalanceValue>,
            hasNoRecord: null == hasNoRecord
                ? _value.hasNoRecord
                : hasNoRecord // ignore: cast_nullable_to_non_nullable
                      as bool,
            yAxisScale: null == yAxisScale
                ? _value.yAxisScale
                : yAxisScale // ignore: cast_nullable_to_non_nullable
                      as YAxisScale,
          )
          as $Val,
    );
  }

  /// Create a copy of AnnualBalanceChartValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $YAxisScaleCopyWith<$Res> get yAxisScale {
    return $YAxisScaleCopyWith<$Res>(_value.yAxisScale, (value) {
      return _then(_value.copyWith(yAxisScale: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnnualBalanceChartValueImplCopyWith<$Res>
    implements $AnnualBalanceChartValueCopyWith<$Res> {
  factory _$$AnnualBalanceChartValueImplCopyWith(
    _$AnnualBalanceChartValueImpl value,
    $Res Function(_$AnnualBalanceChartValueImpl) then,
  ) = __$$AnnualBalanceChartValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int monthIndex,
    int currentMonth,
    List<MonthlyBalanceValue> monthlyBalanceValues,
    bool hasNoRecord,
    YAxisScale yAxisScale,
  });

  @override
  $YAxisScaleCopyWith<$Res> get yAxisScale;
}

/// @nodoc
class __$$AnnualBalanceChartValueImplCopyWithImpl<$Res>
    extends
        _$AnnualBalanceChartValueCopyWithImpl<
          $Res,
          _$AnnualBalanceChartValueImpl
        >
    implements _$$AnnualBalanceChartValueImplCopyWith<$Res> {
  __$$AnnualBalanceChartValueImplCopyWithImpl(
    _$AnnualBalanceChartValueImpl _value,
    $Res Function(_$AnnualBalanceChartValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnnualBalanceChartValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthIndex = null,
    Object? currentMonth = null,
    Object? monthlyBalanceValues = null,
    Object? hasNoRecord = null,
    Object? yAxisScale = null,
  }) {
    return _then(
      _$AnnualBalanceChartValueImpl(
        monthIndex: null == monthIndex
            ? _value.monthIndex
            : monthIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        currentMonth: null == currentMonth
            ? _value.currentMonth
            : currentMonth // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyBalanceValues: null == monthlyBalanceValues
            ? _value._monthlyBalanceValues
            : monthlyBalanceValues // ignore: cast_nullable_to_non_nullable
                  as List<MonthlyBalanceValue>,
        hasNoRecord: null == hasNoRecord
            ? _value.hasNoRecord
            : hasNoRecord // ignore: cast_nullable_to_non_nullable
                  as bool,
        yAxisScale: null == yAxisScale
            ? _value.yAxisScale
            : yAxisScale // ignore: cast_nullable_to_non_nullable
                  as YAxisScale,
      ),
    );
  }
}

/// @nodoc

class _$AnnualBalanceChartValueImpl implements _AnnualBalanceChartValue {
  const _$AnnualBalanceChartValueImpl({
    required this.monthIndex,
    required this.currentMonth,
    required final List<MonthlyBalanceValue> monthlyBalanceValues,
    required this.hasNoRecord,
    required this.yAxisScale,
  }) : _monthlyBalanceValues = monthlyBalanceValues;

  @override
  final int monthIndex;
  // 現在の月のインデックス
  @override
  final int currentMonth;
  // 現在の月
  final List<MonthlyBalanceValue> _monthlyBalanceValues;
  // 現在の月
  @override
  List<MonthlyBalanceValue> get monthlyBalanceValues {
    if (_monthlyBalanceValues is EqualUnmodifiableListView)
      return _monthlyBalanceValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthlyBalanceValues);
  }

  @override
  final bool hasNoRecord;
  // 未来の月のみの収支かどうか
  @override
  final YAxisScale yAxisScale;

  @override
  String toString() {
    return 'AnnualBalanceChartValue(monthIndex: $monthIndex, currentMonth: $currentMonth, monthlyBalanceValues: $monthlyBalanceValues, hasNoRecord: $hasNoRecord, yAxisScale: $yAxisScale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnnualBalanceChartValueImpl &&
            (identical(other.monthIndex, monthIndex) ||
                other.monthIndex == monthIndex) &&
            (identical(other.currentMonth, currentMonth) ||
                other.currentMonth == currentMonth) &&
            const DeepCollectionEquality().equals(
              other._monthlyBalanceValues,
              _monthlyBalanceValues,
            ) &&
            (identical(other.hasNoRecord, hasNoRecord) ||
                other.hasNoRecord == hasNoRecord) &&
            (identical(other.yAxisScale, yAxisScale) ||
                other.yAxisScale == yAxisScale));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    monthIndex,
    currentMonth,
    const DeepCollectionEquality().hash(_monthlyBalanceValues),
    hasNoRecord,
    yAxisScale,
  );

  /// Create a copy of AnnualBalanceChartValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnnualBalanceChartValueImplCopyWith<_$AnnualBalanceChartValueImpl>
  get copyWith =>
      __$$AnnualBalanceChartValueImplCopyWithImpl<
        _$AnnualBalanceChartValueImpl
      >(this, _$identity);
}

abstract class _AnnualBalanceChartValue implements AnnualBalanceChartValue {
  const factory _AnnualBalanceChartValue({
    required final int monthIndex,
    required final int currentMonth,
    required final List<MonthlyBalanceValue> monthlyBalanceValues,
    required final bool hasNoRecord,
    required final YAxisScale yAxisScale,
  }) = _$AnnualBalanceChartValueImpl;

  @override
  int get monthIndex; // 現在の月のインデックス
  @override
  int get currentMonth; // 現在の月
  @override
  List<MonthlyBalanceValue> get monthlyBalanceValues;
  @override
  bool get hasNoRecord; // 未来の月のみの収支かどうか
  @override
  YAxisScale get yAxisScale;

  /// Create a copy of AnnualBalanceChartValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnnualBalanceChartValueImplCopyWith<_$AnnualBalanceChartValueImpl>
  get copyWith => throw _privateConstructorUsedError;
}
