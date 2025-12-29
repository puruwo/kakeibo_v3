import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/daily_bar_data.dart';

part 'prediction_graph_value.freezed.dart';

enum PredictionGraphLineType {
  lastMonth,
  thisMonth,
  futureMonth,
}

/// 予測グラフのデータポイント
@freezed
class PredictionGraphPoint with _$PredictionGraphPoint {
  const factory PredictionGraphPoint({
    required DateTime date,
    required int price,
  }) = _PredictionGraphPoint;
}

/// 横軸ラベルの情報
@freezed
class XAxisLabel with _$XAxisLabel {
  const factory XAxisLabel({
    required DateTime date,
    required String label,
  }) = _XAxisLabel;
}

/// ラベルの表示位置情報
@freezed
class LabelPosition with _$LabelPosition {
  const factory LabelPosition({
    required String label,
    required double yOffset,
  }) = _LabelPosition;
}

/// 予測グラフ全体のデータ
@freezed
class PredictionGraphValue with _$PredictionGraphValue {
  const factory PredictionGraphValue({
    required PredictionGraphLineType predictionGraphLineType,
    required DateTime fromDate,
    required DateTime toDate,
    required DateTime today,
    List<PredictionGraphPoint>? expensePoints,
    List<PredictionGraphPoint>? predictionPoints,
    required int? income,
    required int? budget,
    required double? maxValue,
    required int? latestPrice,
    required int? predictionPrice,
    required List<XAxisLabel>? xAxisLabels,
    required LabelPosition? incomeLabelPosition,
    required LabelPosition? budgetLabelPosition,
    required String? predictionLabel,
    required bool shouldShowPredictionLine,
    required bool shouldShowBudgetLine,
    required bool shouldShowIncomeLine,
    // 棒グラフ用データ
    List<DailyBarData>? dailyBarDataList,
    int? barMaxValue,
    // 固定費合計（確定+未確定推測値）※ツールチップ表示用
    int? totalFixedCostExpense,
  }) = _PredictionGraphValue;
}
