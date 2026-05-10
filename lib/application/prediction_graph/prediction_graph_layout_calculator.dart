import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:kakeibo/application/prediction_graph/prediction_graph_constants.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/util/util.dart';

/// ラベル表示判定結果
class LabelDisplayDecision {
  final bool shouldShowIncomeLine;
  final bool shouldShowBudgetLine;
  final bool shouldShowExpenseLabel;

  LabelDisplayDecision({
    required this.shouldShowIncomeLine,
    required this.shouldShowBudgetLine,
    required this.shouldShowExpenseLabel,
  });
}

final predictionGraphLayoutCalculatorProvider =
    Provider<PredictionGraphLayoutCalculator>(
  (_) => PredictionGraphLayoutCalculator(),
);

/// 予測グラフのレイアウト計算
///
/// DBアクセスを行わない純粋計算のみを担う。
/// Y軸スケール / X軸ラベル / 収入・予算・支出ラベルの位置 / 表示判定など。
class PredictionGraphLayoutCalculator {
  /// グラフの最大値を計算
  /// 累積支出・予測支出・収入・予算のうち最大の値を返す（最低 100）
  double calculateMaxValue({
    required int latestPrice,
    required int? predictionPrice,
    required int income,
    required int budget,
  }) {
    double maxValue = latestPrice.toDouble();
    if (maxValue < (predictionPrice ?? 0)) {
      maxValue = predictionPrice?.toDouble() ?? maxValue;
    }
    if (maxValue < budget) {
      maxValue = budget.toDouble();
    }
    if (maxValue < income) {
      maxValue = income.toDouble();
    }
    // すべての値が0の場合は最低値として100を返す
    if (maxValue == 0) {
      maxValue = 100.0;
    }
    return maxValue;
  }

  /// 横軸のラベルを生成
  /// `xAxisLabelInterval` 日間隔で日付ラベルを生成する
  List<XAxisLabel> generateXAxisLabels({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    final labels = <XAxisLabel>[];
    final totalDays = toDate.difference(fromDate).inDays + 1;

    for (int i = 0;
        i < totalDays;
        i += PredictionGraphConstants.xAxisLabelInterval) {
      final date = fromDate.add(Duration(days: i));
      final label = DateFormat.Md().format(date);
      labels.add(XAxisLabel(date: date, label: label));
    }

    return labels;
  }

  /// ラベル表示判定（重なりを考慮）
  /// グラフの最大値に対する収入と予算の位置関係から、ラベルが重なるかを判定する
  LabelDisplayDecision decideLabelDisplay({
    required int income,
    required int budget,
    required double maxValue,
    required PredictionGraphLineType predictionGraphLineType,
  }) {
    // 支出ラベルは常に表示を試みる（実際の重なり判定はPainter側で実施）
    const shouldShowExpenseLabel = true;

    // どちらかが0の場合は、値がある方のみ表示
    if (income == 0 && budget == 0) {
      return LabelDisplayDecision(
        shouldShowIncomeLine: false,
        shouldShowBudgetLine: false,
        shouldShowExpenseLabel: shouldShowExpenseLabel,
      );
    }
    if (income == 0) {
      return LabelDisplayDecision(
        shouldShowIncomeLine: false,
        shouldShowBudgetLine: true,
        shouldShowExpenseLabel: shouldShowExpenseLabel,
      );
    }
    if (budget == 0) {
      return LabelDisplayDecision(
        shouldShowIncomeLine: true,
        shouldShowBudgetLine: false,
        shouldShowExpenseLabel: shouldShowExpenseLabel,
      );
    }

    // 両方とも値がある場合、グラフ上の位置の差を計算
    final incomePosition = income / maxValue;
    final budgetPosition = budget / maxValue;
    final positionDiff = (incomePosition - budgetPosition).abs();

    // 位置の差がしきい値未満の場合、ラベルが重なると判定
    if (positionDiff < PredictionGraphConstants.labelOverlapPositionThreshold) {
      if (income >= budget) {
        return LabelDisplayDecision(
          shouldShowIncomeLine: true,
          shouldShowBudgetLine: false,
          shouldShowExpenseLabel: shouldShowExpenseLabel,
        );
      } else {
        return LabelDisplayDecision(
          shouldShowIncomeLine: false,
          shouldShowBudgetLine: true,
          shouldShowExpenseLabel: shouldShowExpenseLabel,
        );
      }
    }

    // 位置の差が十分ある場合は両方表示
    return LabelDisplayDecision(
      shouldShowIncomeLine: true,
      shouldShowBudgetLine: true,
      shouldShowExpenseLabel: shouldShowExpenseLabel,
    );
  }

  /// 収入ラベルの表示位置を計算
  /// 予算との位置関係でラベル位置を調整（金額のみ返却）
  LabelPosition calculateIncomeLabel({
    required int income,
    required int budget,
    required bool shouldShowBudgetLine,
  }) {
    final priceLabel = yenFormattedPriceGetter(income);

    // 予算が表示されない場合は上に表示
    if (!shouldShowBudgetLine) {
      return LabelPosition(label: priceLabel, yOffset: -7.0);
    }

    // 収入が予算以下の場合は上に、予算より大きい場合はさらに上に表示
    final yOffset = income <= budget ? -7.0 : -25.0;

    return LabelPosition(label: priceLabel, yOffset: yOffset);
  }

  /// 予算ラベルの表示位置を計算（金額のみ返却）
  /// 収入との位置関係でラベル位置を調整
  LabelPosition calculateBudgetLabel({
    required int income,
    required int budget,
    required bool shouldShowIncomeLine,
  }) {
    final priceLabel = yenFormattedPriceGetter(budget);

    // 収入が表示されない場合は上に表示
    if (!shouldShowIncomeLine) {
      return LabelPosition(label: priceLabel, yOffset: -7.0);
    }

    // 収入が予算以下の場合は上に、収入が予算より大きい場合は下に表示
    final yOffset = income <= budget ? -23.0 : 0.0;

    return LabelPosition(label: priceLabel, yOffset: yOffset);
  }

  /// 支出ラベルの表示位置を計算（金額のみ返却）
  LabelPosition calculateExpenseLabel(int expense) {
    final priceLabel = yenFormattedPriceGetter(expense);
    // 特に他のラベルとの重なり考慮がなければデフォルト位置（少し上）
    // 過去月かつ収入・予算なしの場合のみ表示される前提なので、固定位置でOK
    return LabelPosition(label: priceLabel, yOffset: -7.0);
  }
}
