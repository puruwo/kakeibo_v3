// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prediction_graph_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PredictionGraphPoint {
  DateTime get date => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PredictionGraphPointCopyWith<PredictionGraphPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionGraphPointCopyWith<$Res> {
  factory $PredictionGraphPointCopyWith(PredictionGraphPoint value,
          $Res Function(PredictionGraphPoint) then) =
      _$PredictionGraphPointCopyWithImpl<$Res, PredictionGraphPoint>;
  @useResult
  $Res call({DateTime date, int price});
}

/// @nodoc
class _$PredictionGraphPointCopyWithImpl<$Res,
        $Val extends PredictionGraphPoint>
    implements $PredictionGraphPointCopyWith<$Res> {
  _$PredictionGraphPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? price = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PredictionGraphPointImplCopyWith<$Res>
    implements $PredictionGraphPointCopyWith<$Res> {
  factory _$$PredictionGraphPointImplCopyWith(_$PredictionGraphPointImpl value,
          $Res Function(_$PredictionGraphPointImpl) then) =
      __$$PredictionGraphPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int price});
}

/// @nodoc
class __$$PredictionGraphPointImplCopyWithImpl<$Res>
    extends _$PredictionGraphPointCopyWithImpl<$Res, _$PredictionGraphPointImpl>
    implements _$$PredictionGraphPointImplCopyWith<$Res> {
  __$$PredictionGraphPointImplCopyWithImpl(_$PredictionGraphPointImpl _value,
      $Res Function(_$PredictionGraphPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? price = null,
  }) {
    return _then(_$PredictionGraphPointImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PredictionGraphPointImpl implements _PredictionGraphPoint {
  const _$PredictionGraphPointImpl({required this.date, required this.price});

  @override
  final DateTime date;
  @override
  final int price;

  @override
  String toString() {
    return 'PredictionGraphPoint(date: $date, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictionGraphPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.price, price) || other.price == price));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, price);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictionGraphPointImplCopyWith<_$PredictionGraphPointImpl>
      get copyWith =>
          __$$PredictionGraphPointImplCopyWithImpl<_$PredictionGraphPointImpl>(
              this, _$identity);
}

abstract class _PredictionGraphPoint implements PredictionGraphPoint {
  const factory _PredictionGraphPoint(
      {required final DateTime date,
      required final int price}) = _$PredictionGraphPointImpl;

  @override
  DateTime get date;
  @override
  int get price;
  @override
  @JsonKey(ignore: true)
  _$$PredictionGraphPointImplCopyWith<_$PredictionGraphPointImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$XAxisLabel {
  DateTime get date => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $XAxisLabelCopyWith<XAxisLabel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $XAxisLabelCopyWith<$Res> {
  factory $XAxisLabelCopyWith(
          XAxisLabel value, $Res Function(XAxisLabel) then) =
      _$XAxisLabelCopyWithImpl<$Res, XAxisLabel>;
  @useResult
  $Res call({DateTime date, String label});
}

/// @nodoc
class _$XAxisLabelCopyWithImpl<$Res, $Val extends XAxisLabel>
    implements $XAxisLabelCopyWith<$Res> {
  _$XAxisLabelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? label = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$XAxisLabelImplCopyWith<$Res>
    implements $XAxisLabelCopyWith<$Res> {
  factory _$$XAxisLabelImplCopyWith(
          _$XAxisLabelImpl value, $Res Function(_$XAxisLabelImpl) then) =
      __$$XAxisLabelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, String label});
}

/// @nodoc
class __$$XAxisLabelImplCopyWithImpl<$Res>
    extends _$XAxisLabelCopyWithImpl<$Res, _$XAxisLabelImpl>
    implements _$$XAxisLabelImplCopyWith<$Res> {
  __$$XAxisLabelImplCopyWithImpl(
      _$XAxisLabelImpl _value, $Res Function(_$XAxisLabelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? label = null,
  }) {
    return _then(_$XAxisLabelImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$XAxisLabelImpl implements _XAxisLabel {
  const _$XAxisLabelImpl({required this.date, required this.label});

  @override
  final DateTime date;
  @override
  final String label;

  @override
  String toString() {
    return 'XAxisLabel(date: $date, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$XAxisLabelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.label, label) || other.label == label));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, label);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$XAxisLabelImplCopyWith<_$XAxisLabelImpl> get copyWith =>
      __$$XAxisLabelImplCopyWithImpl<_$XAxisLabelImpl>(this, _$identity);
}

abstract class _XAxisLabel implements XAxisLabel {
  const factory _XAxisLabel(
      {required final DateTime date,
      required final String label}) = _$XAxisLabelImpl;

  @override
  DateTime get date;
  @override
  String get label;
  @override
  @JsonKey(ignore: true)
  _$$XAxisLabelImplCopyWith<_$XAxisLabelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LabelPosition {
  String get label => throw _privateConstructorUsedError;
  double get yOffset => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LabelPositionCopyWith<LabelPosition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelPositionCopyWith<$Res> {
  factory $LabelPositionCopyWith(
          LabelPosition value, $Res Function(LabelPosition) then) =
      _$LabelPositionCopyWithImpl<$Res, LabelPosition>;
  @useResult
  $Res call({String label, double yOffset});
}

/// @nodoc
class _$LabelPositionCopyWithImpl<$Res, $Val extends LabelPosition>
    implements $LabelPositionCopyWith<$Res> {
  _$LabelPositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? yOffset = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      yOffset: null == yOffset
          ? _value.yOffset
          : yOffset // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelPositionImplCopyWith<$Res>
    implements $LabelPositionCopyWith<$Res> {
  factory _$$LabelPositionImplCopyWith(
          _$LabelPositionImpl value, $Res Function(_$LabelPositionImpl) then) =
      __$$LabelPositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, double yOffset});
}

/// @nodoc
class __$$LabelPositionImplCopyWithImpl<$Res>
    extends _$LabelPositionCopyWithImpl<$Res, _$LabelPositionImpl>
    implements _$$LabelPositionImplCopyWith<$Res> {
  __$$LabelPositionImplCopyWithImpl(
      _$LabelPositionImpl _value, $Res Function(_$LabelPositionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? yOffset = null,
  }) {
    return _then(_$LabelPositionImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      yOffset: null == yOffset
          ? _value.yOffset
          : yOffset // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$LabelPositionImpl implements _LabelPosition {
  const _$LabelPositionImpl({required this.label, required this.yOffset});

  @override
  final String label;
  @override
  final double yOffset;

  @override
  String toString() {
    return 'LabelPosition(label: $label, yOffset: $yOffset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelPositionImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.yOffset, yOffset) || other.yOffset == yOffset));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, yOffset);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelPositionImplCopyWith<_$LabelPositionImpl> get copyWith =>
      __$$LabelPositionImplCopyWithImpl<_$LabelPositionImpl>(this, _$identity);
}

abstract class _LabelPosition implements LabelPosition {
  const factory _LabelPosition(
      {required final String label,
      required final double yOffset}) = _$LabelPositionImpl;

  @override
  String get label;
  @override
  double get yOffset;
  @override
  @JsonKey(ignore: true)
  _$$LabelPositionImplCopyWith<_$LabelPositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PredictionGraphValue {
  PredictionGraphLineType get predictionGraphLineType =>
      throw _privateConstructorUsedError;
  DateTime get fromDate => throw _privateConstructorUsedError;
  DateTime get toDate => throw _privateConstructorUsedError;
  DateTime get today => throw _privateConstructorUsedError;
  List<PredictionGraphPoint>? get expensePoints =>
      throw _privateConstructorUsedError;
  List<PredictionGraphPoint>? get predictionPoints =>
      throw _privateConstructorUsedError;
  int? get income => throw _privateConstructorUsedError;
  int? get budget => throw _privateConstructorUsedError;
  double? get maxValue => throw _privateConstructorUsedError; // 表示用の最大値（バッファ込み）
  double? get displayMaxValue => throw _privateConstructorUsedError;
  int? get latestPrice => throw _privateConstructorUsedError;
  int? get predictionPrice => throw _privateConstructorUsedError;
  List<XAxisLabel>? get xAxisLabels => throw _privateConstructorUsedError;
  LabelPosition? get incomeLabelPosition => throw _privateConstructorUsedError;
  LabelPosition? get budgetLabelPosition => throw _privateConstructorUsedError;
  String? get predictionLabel => throw _privateConstructorUsedError;
  bool get shouldShowPredictionLine => throw _privateConstructorUsedError;
  bool get shouldShowBudgetLine => throw _privateConstructorUsedError;
  bool get shouldShowIncomeLine =>
      throw _privateConstructorUsedError; // 棒グラフ用データ
  List<DailyBarData>? get dailyBarDataList =>
      throw _privateConstructorUsedError;
  int? get barMaxValue =>
      throw _privateConstructorUsedError; // 固定費合計（確定+未確定推測値）※ツールチップ表示用
  int? get totalFixedCostExpense => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PredictionGraphValueCopyWith<PredictionGraphValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionGraphValueCopyWith<$Res> {
  factory $PredictionGraphValueCopyWith(PredictionGraphValue value,
          $Res Function(PredictionGraphValue) then) =
      _$PredictionGraphValueCopyWithImpl<$Res, PredictionGraphValue>;
  @useResult
  $Res call(
      {PredictionGraphLineType predictionGraphLineType,
      DateTime fromDate,
      DateTime toDate,
      DateTime today,
      List<PredictionGraphPoint>? expensePoints,
      List<PredictionGraphPoint>? predictionPoints,
      int? income,
      int? budget,
      double? maxValue,
      double? displayMaxValue,
      int? latestPrice,
      int? predictionPrice,
      List<XAxisLabel>? xAxisLabels,
      LabelPosition? incomeLabelPosition,
      LabelPosition? budgetLabelPosition,
      String? predictionLabel,
      bool shouldShowPredictionLine,
      bool shouldShowBudgetLine,
      bool shouldShowIncomeLine,
      List<DailyBarData>? dailyBarDataList,
      int? barMaxValue,
      int? totalFixedCostExpense});

  $LabelPositionCopyWith<$Res>? get incomeLabelPosition;
  $LabelPositionCopyWith<$Res>? get budgetLabelPosition;
}

/// @nodoc
class _$PredictionGraphValueCopyWithImpl<$Res,
        $Val extends PredictionGraphValue>
    implements $PredictionGraphValueCopyWith<$Res> {
  _$PredictionGraphValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? predictionGraphLineType = null,
    Object? fromDate = null,
    Object? toDate = null,
    Object? today = null,
    Object? expensePoints = freezed,
    Object? predictionPoints = freezed,
    Object? income = freezed,
    Object? budget = freezed,
    Object? maxValue = freezed,
    Object? displayMaxValue = freezed,
    Object? latestPrice = freezed,
    Object? predictionPrice = freezed,
    Object? xAxisLabels = freezed,
    Object? incomeLabelPosition = freezed,
    Object? budgetLabelPosition = freezed,
    Object? predictionLabel = freezed,
    Object? shouldShowPredictionLine = null,
    Object? shouldShowBudgetLine = null,
    Object? shouldShowIncomeLine = null,
    Object? dailyBarDataList = freezed,
    Object? barMaxValue = freezed,
    Object? totalFixedCostExpense = freezed,
  }) {
    return _then(_value.copyWith(
      predictionGraphLineType: null == predictionGraphLineType
          ? _value.predictionGraphLineType
          : predictionGraphLineType // ignore: cast_nullable_to_non_nullable
              as PredictionGraphLineType,
      fromDate: null == fromDate
          ? _value.fromDate
          : fromDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      toDate: null == toDate
          ? _value.toDate
          : toDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      today: null == today
          ? _value.today
          : today // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expensePoints: freezed == expensePoints
          ? _value.expensePoints
          : expensePoints // ignore: cast_nullable_to_non_nullable
              as List<PredictionGraphPoint>?,
      predictionPoints: freezed == predictionPoints
          ? _value.predictionPoints
          : predictionPoints // ignore: cast_nullable_to_non_nullable
              as List<PredictionGraphPoint>?,
      income: freezed == income
          ? _value.income
          : income // ignore: cast_nullable_to_non_nullable
              as int?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as int?,
      maxValue: freezed == maxValue
          ? _value.maxValue
          : maxValue // ignore: cast_nullable_to_non_nullable
              as double?,
      displayMaxValue: freezed == displayMaxValue
          ? _value.displayMaxValue
          : displayMaxValue // ignore: cast_nullable_to_non_nullable
              as double?,
      latestPrice: freezed == latestPrice
          ? _value.latestPrice
          : latestPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      predictionPrice: freezed == predictionPrice
          ? _value.predictionPrice
          : predictionPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      xAxisLabels: freezed == xAxisLabels
          ? _value.xAxisLabels
          : xAxisLabels // ignore: cast_nullable_to_non_nullable
              as List<XAxisLabel>?,
      incomeLabelPosition: freezed == incomeLabelPosition
          ? _value.incomeLabelPosition
          : incomeLabelPosition // ignore: cast_nullable_to_non_nullable
              as LabelPosition?,
      budgetLabelPosition: freezed == budgetLabelPosition
          ? _value.budgetLabelPosition
          : budgetLabelPosition // ignore: cast_nullable_to_non_nullable
              as LabelPosition?,
      predictionLabel: freezed == predictionLabel
          ? _value.predictionLabel
          : predictionLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      shouldShowPredictionLine: null == shouldShowPredictionLine
          ? _value.shouldShowPredictionLine
          : shouldShowPredictionLine // ignore: cast_nullable_to_non_nullable
              as bool,
      shouldShowBudgetLine: null == shouldShowBudgetLine
          ? _value.shouldShowBudgetLine
          : shouldShowBudgetLine // ignore: cast_nullable_to_non_nullable
              as bool,
      shouldShowIncomeLine: null == shouldShowIncomeLine
          ? _value.shouldShowIncomeLine
          : shouldShowIncomeLine // ignore: cast_nullable_to_non_nullable
              as bool,
      dailyBarDataList: freezed == dailyBarDataList
          ? _value.dailyBarDataList
          : dailyBarDataList // ignore: cast_nullable_to_non_nullable
              as List<DailyBarData>?,
      barMaxValue: freezed == barMaxValue
          ? _value.barMaxValue
          : barMaxValue // ignore: cast_nullable_to_non_nullable
              as int?,
      totalFixedCostExpense: freezed == totalFixedCostExpense
          ? _value.totalFixedCostExpense
          : totalFixedCostExpense // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LabelPositionCopyWith<$Res>? get incomeLabelPosition {
    if (_value.incomeLabelPosition == null) {
      return null;
    }

    return $LabelPositionCopyWith<$Res>(_value.incomeLabelPosition!, (value) {
      return _then(_value.copyWith(incomeLabelPosition: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LabelPositionCopyWith<$Res>? get budgetLabelPosition {
    if (_value.budgetLabelPosition == null) {
      return null;
    }

    return $LabelPositionCopyWith<$Res>(_value.budgetLabelPosition!, (value) {
      return _then(_value.copyWith(budgetLabelPosition: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PredictionGraphValueImplCopyWith<$Res>
    implements $PredictionGraphValueCopyWith<$Res> {
  factory _$$PredictionGraphValueImplCopyWith(_$PredictionGraphValueImpl value,
          $Res Function(_$PredictionGraphValueImpl) then) =
      __$$PredictionGraphValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PredictionGraphLineType predictionGraphLineType,
      DateTime fromDate,
      DateTime toDate,
      DateTime today,
      List<PredictionGraphPoint>? expensePoints,
      List<PredictionGraphPoint>? predictionPoints,
      int? income,
      int? budget,
      double? maxValue,
      double? displayMaxValue,
      int? latestPrice,
      int? predictionPrice,
      List<XAxisLabel>? xAxisLabels,
      LabelPosition? incomeLabelPosition,
      LabelPosition? budgetLabelPosition,
      String? predictionLabel,
      bool shouldShowPredictionLine,
      bool shouldShowBudgetLine,
      bool shouldShowIncomeLine,
      List<DailyBarData>? dailyBarDataList,
      int? barMaxValue,
      int? totalFixedCostExpense});

  @override
  $LabelPositionCopyWith<$Res>? get incomeLabelPosition;
  @override
  $LabelPositionCopyWith<$Res>? get budgetLabelPosition;
}

/// @nodoc
class __$$PredictionGraphValueImplCopyWithImpl<$Res>
    extends _$PredictionGraphValueCopyWithImpl<$Res, _$PredictionGraphValueImpl>
    implements _$$PredictionGraphValueImplCopyWith<$Res> {
  __$$PredictionGraphValueImplCopyWithImpl(_$PredictionGraphValueImpl _value,
      $Res Function(_$PredictionGraphValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? predictionGraphLineType = null,
    Object? fromDate = null,
    Object? toDate = null,
    Object? today = null,
    Object? expensePoints = freezed,
    Object? predictionPoints = freezed,
    Object? income = freezed,
    Object? budget = freezed,
    Object? maxValue = freezed,
    Object? displayMaxValue = freezed,
    Object? latestPrice = freezed,
    Object? predictionPrice = freezed,
    Object? xAxisLabels = freezed,
    Object? incomeLabelPosition = freezed,
    Object? budgetLabelPosition = freezed,
    Object? predictionLabel = freezed,
    Object? shouldShowPredictionLine = null,
    Object? shouldShowBudgetLine = null,
    Object? shouldShowIncomeLine = null,
    Object? dailyBarDataList = freezed,
    Object? barMaxValue = freezed,
    Object? totalFixedCostExpense = freezed,
  }) {
    return _then(_$PredictionGraphValueImpl(
      predictionGraphLineType: null == predictionGraphLineType
          ? _value.predictionGraphLineType
          : predictionGraphLineType // ignore: cast_nullable_to_non_nullable
              as PredictionGraphLineType,
      fromDate: null == fromDate
          ? _value.fromDate
          : fromDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      toDate: null == toDate
          ? _value.toDate
          : toDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      today: null == today
          ? _value.today
          : today // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expensePoints: freezed == expensePoints
          ? _value._expensePoints
          : expensePoints // ignore: cast_nullable_to_non_nullable
              as List<PredictionGraphPoint>?,
      predictionPoints: freezed == predictionPoints
          ? _value._predictionPoints
          : predictionPoints // ignore: cast_nullable_to_non_nullable
              as List<PredictionGraphPoint>?,
      income: freezed == income
          ? _value.income
          : income // ignore: cast_nullable_to_non_nullable
              as int?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as int?,
      maxValue: freezed == maxValue
          ? _value.maxValue
          : maxValue // ignore: cast_nullable_to_non_nullable
              as double?,
      displayMaxValue: freezed == displayMaxValue
          ? _value.displayMaxValue
          : displayMaxValue // ignore: cast_nullable_to_non_nullable
              as double?,
      latestPrice: freezed == latestPrice
          ? _value.latestPrice
          : latestPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      predictionPrice: freezed == predictionPrice
          ? _value.predictionPrice
          : predictionPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      xAxisLabels: freezed == xAxisLabels
          ? _value._xAxisLabels
          : xAxisLabels // ignore: cast_nullable_to_non_nullable
              as List<XAxisLabel>?,
      incomeLabelPosition: freezed == incomeLabelPosition
          ? _value.incomeLabelPosition
          : incomeLabelPosition // ignore: cast_nullable_to_non_nullable
              as LabelPosition?,
      budgetLabelPosition: freezed == budgetLabelPosition
          ? _value.budgetLabelPosition
          : budgetLabelPosition // ignore: cast_nullable_to_non_nullable
              as LabelPosition?,
      predictionLabel: freezed == predictionLabel
          ? _value.predictionLabel
          : predictionLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      shouldShowPredictionLine: null == shouldShowPredictionLine
          ? _value.shouldShowPredictionLine
          : shouldShowPredictionLine // ignore: cast_nullable_to_non_nullable
              as bool,
      shouldShowBudgetLine: null == shouldShowBudgetLine
          ? _value.shouldShowBudgetLine
          : shouldShowBudgetLine // ignore: cast_nullable_to_non_nullable
              as bool,
      shouldShowIncomeLine: null == shouldShowIncomeLine
          ? _value.shouldShowIncomeLine
          : shouldShowIncomeLine // ignore: cast_nullable_to_non_nullable
              as bool,
      dailyBarDataList: freezed == dailyBarDataList
          ? _value._dailyBarDataList
          : dailyBarDataList // ignore: cast_nullable_to_non_nullable
              as List<DailyBarData>?,
      barMaxValue: freezed == barMaxValue
          ? _value.barMaxValue
          : barMaxValue // ignore: cast_nullable_to_non_nullable
              as int?,
      totalFixedCostExpense: freezed == totalFixedCostExpense
          ? _value.totalFixedCostExpense
          : totalFixedCostExpense // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$PredictionGraphValueImpl implements _PredictionGraphValue {
  const _$PredictionGraphValueImpl(
      {required this.predictionGraphLineType,
      required this.fromDate,
      required this.toDate,
      required this.today,
      final List<PredictionGraphPoint>? expensePoints,
      final List<PredictionGraphPoint>? predictionPoints,
      required this.income,
      required this.budget,
      required this.maxValue,
      required this.displayMaxValue,
      required this.latestPrice,
      required this.predictionPrice,
      required final List<XAxisLabel>? xAxisLabels,
      required this.incomeLabelPosition,
      required this.budgetLabelPosition,
      required this.predictionLabel,
      required this.shouldShowPredictionLine,
      required this.shouldShowBudgetLine,
      required this.shouldShowIncomeLine,
      final List<DailyBarData>? dailyBarDataList,
      this.barMaxValue,
      this.totalFixedCostExpense})
      : _expensePoints = expensePoints,
        _predictionPoints = predictionPoints,
        _xAxisLabels = xAxisLabels,
        _dailyBarDataList = dailyBarDataList;

  @override
  final PredictionGraphLineType predictionGraphLineType;
  @override
  final DateTime fromDate;
  @override
  final DateTime toDate;
  @override
  final DateTime today;
  final List<PredictionGraphPoint>? _expensePoints;
  @override
  List<PredictionGraphPoint>? get expensePoints {
    final value = _expensePoints;
    if (value == null) return null;
    if (_expensePoints is EqualUnmodifiableListView) return _expensePoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<PredictionGraphPoint>? _predictionPoints;
  @override
  List<PredictionGraphPoint>? get predictionPoints {
    final value = _predictionPoints;
    if (value == null) return null;
    if (_predictionPoints is EqualUnmodifiableListView)
      return _predictionPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? income;
  @override
  final int? budget;
  @override
  final double? maxValue;
// 表示用の最大値（バッファ込み）
  @override
  final double? displayMaxValue;
  @override
  final int? latestPrice;
  @override
  final int? predictionPrice;
  final List<XAxisLabel>? _xAxisLabels;
  @override
  List<XAxisLabel>? get xAxisLabels {
    final value = _xAxisLabels;
    if (value == null) return null;
    if (_xAxisLabels is EqualUnmodifiableListView) return _xAxisLabels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final LabelPosition? incomeLabelPosition;
  @override
  final LabelPosition? budgetLabelPosition;
  @override
  final String? predictionLabel;
  @override
  final bool shouldShowPredictionLine;
  @override
  final bool shouldShowBudgetLine;
  @override
  final bool shouldShowIncomeLine;
// 棒グラフ用データ
  final List<DailyBarData>? _dailyBarDataList;
// 棒グラフ用データ
  @override
  List<DailyBarData>? get dailyBarDataList {
    final value = _dailyBarDataList;
    if (value == null) return null;
    if (_dailyBarDataList is EqualUnmodifiableListView)
      return _dailyBarDataList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? barMaxValue;
// 固定費合計（確定+未確定推測値）※ツールチップ表示用
  @override
  final int? totalFixedCostExpense;

  @override
  String toString() {
    return 'PredictionGraphValue(predictionGraphLineType: $predictionGraphLineType, fromDate: $fromDate, toDate: $toDate, today: $today, expensePoints: $expensePoints, predictionPoints: $predictionPoints, income: $income, budget: $budget, maxValue: $maxValue, displayMaxValue: $displayMaxValue, latestPrice: $latestPrice, predictionPrice: $predictionPrice, xAxisLabels: $xAxisLabels, incomeLabelPosition: $incomeLabelPosition, budgetLabelPosition: $budgetLabelPosition, predictionLabel: $predictionLabel, shouldShowPredictionLine: $shouldShowPredictionLine, shouldShowBudgetLine: $shouldShowBudgetLine, shouldShowIncomeLine: $shouldShowIncomeLine, dailyBarDataList: $dailyBarDataList, barMaxValue: $barMaxValue, totalFixedCostExpense: $totalFixedCostExpense)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictionGraphValueImpl &&
            (identical(
                    other.predictionGraphLineType, predictionGraphLineType) ||
                other.predictionGraphLineType == predictionGraphLineType) &&
            (identical(other.fromDate, fromDate) ||
                other.fromDate == fromDate) &&
            (identical(other.toDate, toDate) || other.toDate == toDate) &&
            (identical(other.today, today) || other.today == today) &&
            const DeepCollectionEquality()
                .equals(other._expensePoints, _expensePoints) &&
            const DeepCollectionEquality()
                .equals(other._predictionPoints, _predictionPoints) &&
            (identical(other.income, income) || other.income == income) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.maxValue, maxValue) ||
                other.maxValue == maxValue) &&
            (identical(other.displayMaxValue, displayMaxValue) ||
                other.displayMaxValue == displayMaxValue) &&
            (identical(other.latestPrice, latestPrice) ||
                other.latestPrice == latestPrice) &&
            (identical(other.predictionPrice, predictionPrice) ||
                other.predictionPrice == predictionPrice) &&
            const DeepCollectionEquality()
                .equals(other._xAxisLabels, _xAxisLabels) &&
            (identical(other.incomeLabelPosition, incomeLabelPosition) ||
                other.incomeLabelPosition == incomeLabelPosition) &&
            (identical(other.budgetLabelPosition, budgetLabelPosition) ||
                other.budgetLabelPosition == budgetLabelPosition) &&
            (identical(other.predictionLabel, predictionLabel) ||
                other.predictionLabel == predictionLabel) &&
            (identical(
                    other.shouldShowPredictionLine, shouldShowPredictionLine) ||
                other.shouldShowPredictionLine == shouldShowPredictionLine) &&
            (identical(other.shouldShowBudgetLine, shouldShowBudgetLine) ||
                other.shouldShowBudgetLine == shouldShowBudgetLine) &&
            (identical(other.shouldShowIncomeLine, shouldShowIncomeLine) ||
                other.shouldShowIncomeLine == shouldShowIncomeLine) &&
            const DeepCollectionEquality()
                .equals(other._dailyBarDataList, _dailyBarDataList) &&
            (identical(other.barMaxValue, barMaxValue) ||
                other.barMaxValue == barMaxValue) &&
            (identical(other.totalFixedCostExpense, totalFixedCostExpense) ||
                other.totalFixedCostExpense == totalFixedCostExpense));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        predictionGraphLineType,
        fromDate,
        toDate,
        today,
        const DeepCollectionEquality().hash(_expensePoints),
        const DeepCollectionEquality().hash(_predictionPoints),
        income,
        budget,
        maxValue,
        displayMaxValue,
        latestPrice,
        predictionPrice,
        const DeepCollectionEquality().hash(_xAxisLabels),
        incomeLabelPosition,
        budgetLabelPosition,
        predictionLabel,
        shouldShowPredictionLine,
        shouldShowBudgetLine,
        shouldShowIncomeLine,
        const DeepCollectionEquality().hash(_dailyBarDataList),
        barMaxValue,
        totalFixedCostExpense
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictionGraphValueImplCopyWith<_$PredictionGraphValueImpl>
      get copyWith =>
          __$$PredictionGraphValueImplCopyWithImpl<_$PredictionGraphValueImpl>(
              this, _$identity);
}

abstract class _PredictionGraphValue implements PredictionGraphValue {
  const factory _PredictionGraphValue(
      {required final PredictionGraphLineType predictionGraphLineType,
      required final DateTime fromDate,
      required final DateTime toDate,
      required final DateTime today,
      final List<PredictionGraphPoint>? expensePoints,
      final List<PredictionGraphPoint>? predictionPoints,
      required final int? income,
      required final int? budget,
      required final double? maxValue,
      required final double? displayMaxValue,
      required final int? latestPrice,
      required final int? predictionPrice,
      required final List<XAxisLabel>? xAxisLabels,
      required final LabelPosition? incomeLabelPosition,
      required final LabelPosition? budgetLabelPosition,
      required final String? predictionLabel,
      required final bool shouldShowPredictionLine,
      required final bool shouldShowBudgetLine,
      required final bool shouldShowIncomeLine,
      final List<DailyBarData>? dailyBarDataList,
      final int? barMaxValue,
      final int? totalFixedCostExpense}) = _$PredictionGraphValueImpl;

  @override
  PredictionGraphLineType get predictionGraphLineType;
  @override
  DateTime get fromDate;
  @override
  DateTime get toDate;
  @override
  DateTime get today;
  @override
  List<PredictionGraphPoint>? get expensePoints;
  @override
  List<PredictionGraphPoint>? get predictionPoints;
  @override
  int? get income;
  @override
  int? get budget;
  @override
  double? get maxValue;
  @override // 表示用の最大値（バッファ込み）
  double? get displayMaxValue;
  @override
  int? get latestPrice;
  @override
  int? get predictionPrice;
  @override
  List<XAxisLabel>? get xAxisLabels;
  @override
  LabelPosition? get incomeLabelPosition;
  @override
  LabelPosition? get budgetLabelPosition;
  @override
  String? get predictionLabel;
  @override
  bool get shouldShowPredictionLine;
  @override
  bool get shouldShowBudgetLine;
  @override
  bool get shouldShowIncomeLine;
  @override // 棒グラフ用データ
  List<DailyBarData>? get dailyBarDataList;
  @override
  int? get barMaxValue;
  @override // 固定費合計（確定+未確定推測値）※ツールチップ表示用
  int? get totalFixedCostExpense;
  @override
  @JsonKey(ignore: true)
  _$$PredictionGraphValueImplCopyWith<_$PredictionGraphValueImpl>
      get copyWith => throw _privateConstructorUsedError;
}
