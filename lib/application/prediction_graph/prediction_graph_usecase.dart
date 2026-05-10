import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:kakeibo/application/fixed_cost/fixed_cost_service.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_constants.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_data_source.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/util/util.dart';

final predictionGraphUsecaseProvider = Provider<PredictionGraphUsecase>(
  PredictionGraphUsecase.new,
);

class PredictionGraphUsecase {
  PredictionGraphUsecase(this.ref);

  final Ref ref;

  late final IncomeRepository _incomeRepo = ref.read(incomeRepositoryProvider);
  late final BudgetRepository _budgetRepo = ref.read(budgetRepositoryProvider);
  late final PredictionGraphDataSource _dataSource =
      ref.read(predictionGraphDataSourceProvider);

  /// 予測グラフのデータを取得
  Future<PredictionGraphValue> fetchPredictionGraphData(
      DateScopeEntity dateScope) async {
    // 期間を取得
    final fromDate = dateScope.aggregationMonthPeriod.startDatetime;
    final toDate = dateScope.aggregationMonthPeriod.endDatetime;
    final today = ref.read(systemDatetimeNotifierProvider);

    // 予測グラフの種類を判定
    PredictionGraphLineType predictionGraphLineType;
    if (toDate.isBefore(today)) {
      predictionGraphLineType = PredictionGraphLineType.lastMonth;
    } else if (fromDate.isAfter(today)) {
      predictionGraphLineType = PredictionGraphLineType.futureMonth;
      return PredictionGraphValue(
        predictionGraphLineType: predictionGraphLineType,
        fromDate: fromDate,
        toDate: toDate,
        today: today,
        expensePoints: null,
        predictionPoints: null,
        income: null,
        budget: null,
        maxValue: null,
        latestPrice: null,
        predictionPrice: null,
        xAxisLabels: null,
        incomeLabelPosition: null,
        budgetLabelPosition: null,
        predictionLabel: null,
        shouldShowPredictionLine: false,
        shouldShowBudgetLine: false,
        shouldShowIncomeLine: false,
        shouldShowExpenseLabel: false,
        expenseLabelPosition: null, // 追加
        displayMaxValue: 100.0, // デフォルト値
      );
    } else {
      predictionGraphLineType = PredictionGraphLineType.thisMonth;
    }

    // 累積支出データを取得
    final cumulativePriceData =
        predictionGraphLineType == PredictionGraphLineType.lastMonth
            ? await _dataSource.fetchCumulativeByDate(
                fromDate: fromDate, toDate: toDate)
            : predictionGraphLineType == PredictionGraphLineType.thisMonth
                ? await _dataSource.fetchCumulativeByDate(
                    fromDate: fromDate, toDate: today)
                : [];

    // 収入を取得
    final income = await _incomeRepo.calcurateSumWithBigCategoryAndPeriod(
        period: dateScope.aggregationMonthPeriod,
        bigCategoryId: IncomeBigCategoryConstants.incomeSourceIdSalary);

    // 予算を取得
    final budget =
        await _budgetRepo.fetchMonthlyAll(month: dateScope.representativeMonth);

    // 今月の固定費支出を取得
    final fixedCostExpenseTotal =
        await FixedCostService().getFixedCostTotal(ref, dateScope);

    // 予算と固定費を合算
    final budgetIncludeFixedCost =
        budget == 0 ? 0 : budget + fixedCostExpenseTotal;

    // 支出なし・予算なし・収入なしの場合はグラフ表示不要
    if (cumulativePriceData.isEmpty && income == 0 && budgetIncludeFixedCost == 0) {
      return PredictionGraphValue(
        predictionGraphLineType: PredictionGraphLineType.noData,
        fromDate: fromDate,
        toDate: toDate,
        today: today,
        expensePoints: null,
        predictionPoints: null,
        income: null,
        budget: null,
        maxValue: null,
        latestPrice: null,
        predictionPrice: null,
        xAxisLabels: null,
        incomeLabelPosition: null,
        budgetLabelPosition: null,
        predictionLabel: null,
        shouldShowPredictionLine: false,
        shouldShowBudgetLine: false,
        shouldShowIncomeLine: false,
        shouldShowExpenseLabel: false,
        expenseLabelPosition: null,
        displayMaxValue: 100.0,
      );
    }

    // 累積支出データをチャート用に変換
    final expensePoints = <PredictionGraphPoint>[];
    int lastPrice = 0;
    DateTime lastDate = predictionGraphLineType == PredictionGraphLineType.thisMonth ? today : toDate;
    if (cumulativePriceData.isNotEmpty) {
      for (final data in cumulativePriceData) {
        final dateTime = data['date'] as DateTime;
        final price = data['sum_price_daily'] as int;
        expensePoints.add(PredictionGraphPoint(date: dateTime, price: price));
      }
      // 最後のデータから経過情報を取得
      final lastData = cumulativePriceData.last;
      lastDate = lastData['date'] as DateTime;
      lastPrice = lastData['sum_price_daily'] as int;
    }

    // 経過日数と総日数を計算
    final elapsedDays = lastDate.difference(fromDate).inDays + 1;
    final totalDays = toDate.difference(fromDate).inDays + 1;

    ///予想支出額を計算するロジック
    int? predictionPrice;
    bool shouldShowPredictionLine;
    List<PredictionGraphPoint>? predictionPoints;
    String? predictionPriceLabel;
    // 予測支出額を表示しない条件（過去月、未来月、経過日数が最小しきい値以下、データなし）
    if (elapsedDays <= PredictionGraphConstants.minElapsedDaysForPrediction ||
        predictionGraphLineType == PredictionGraphLineType.lastMonth ||
        predictionGraphLineType == PredictionGraphLineType.futureMonth ||
        cumulativePriceData.isEmpty) {
      predictionPrice = null;
      shouldShowPredictionLine = false;
    } else {
      // 支出データがあり、かつ経過日数が5日未満でも総日数でもない場合に予測ポイントを作成
      predictionPrice = ((lastPrice / elapsedDays) * totalDays).toInt();
      shouldShowPredictionLine = true;
      predictionPoints = <PredictionGraphPoint>[
        PredictionGraphPoint(date: lastDate, price: lastPrice),
        PredictionGraphPoint(date: toDate, price: predictionPrice),
      ];
      // 予想支出ラベルを生成
      predictionPriceLabel = _generatePredictionLabel(predictionPrice);
    }

    // グラフの最大値を計算
    final maxValue = _calculateMaxValue(
      lastPrice,
      predictionPrice,
      income,
      budgetIncludeFixedCost,
    );
    final displayMaxValue = maxValue * 1.2;

    // 横軸ラベルを生成
    final xAxisLabels = _generateXAxisLabels(fromDate, toDate);

    // ラベル表示ロジック（重なりを考慮）
    final labelDisplayDecision = _decideLabelDisplay(
        income, budgetIncludeFixedCost, maxValue, predictionGraphLineType);
    final shouldShowIncomeLine = labelDisplayDecision.shouldShowIncomeLine;
    final shouldShowBudgetLine = labelDisplayDecision.shouldShowBudgetLine;
    final shouldShowExpenseLabel = labelDisplayDecision.shouldShowExpenseLabel;

    // 収入ラベルの位置を計算
    final incomeLabelPosition = shouldShowIncomeLine
        ? _calculateIncomeLabelPosition(
            income, budgetIncludeFixedCost, shouldShowBudgetLine)
        : null;

    // 予算ラベルの位置を計算
    final budgetLabelPosition = shouldShowBudgetLine
        ? _calculateBudgetLabelPosition(
            income, budgetIncludeFixedCost, shouldShowIncomeLine)
        : null;

    // 支出ラベルの位置を計算
    final expenseLabelPosition = shouldShowExpenseLabel
        ? _calculateExpenseLabelPosition(lastPrice)
        : null;

    // 棒グラフデータを取得
    final dailyBarResult = await _dataSource.fetchDailyBarData(
        fromDate: fromDate, toDate: toDate, today: today);
    final dailyBarDataList = dailyBarResult.dailyBarDataList;
    final barMaxValue = dailyBarResult.barMaxValue;

    return PredictionGraphValue(
      predictionGraphLineType: predictionGraphLineType,
      fromDate: fromDate,
      toDate: toDate,
      today: today,
      expensePoints: expensePoints,
      predictionPoints: predictionPoints,
      income: income,
      budget: budgetIncludeFixedCost,
      maxValue: maxValue,
      displayMaxValue: displayMaxValue,
      latestPrice: lastPrice,
      predictionPrice: predictionPrice,
      xAxisLabels: xAxisLabels,
      incomeLabelPosition: incomeLabelPosition,
      budgetLabelPosition: budgetLabelPosition,
      predictionLabel: predictionPriceLabel,
      shouldShowPredictionLine: shouldShowPredictionLine,
      shouldShowBudgetLine: shouldShowBudgetLine,
      shouldShowIncomeLine: shouldShowIncomeLine,
      shouldShowExpenseLabel: shouldShowExpenseLabel,
      expenseLabelPosition: expenseLabelPosition,
      dailyBarDataList: dailyBarDataList,
      barMaxValue: barMaxValue,
      totalFixedCostExpense: fixedCostExpenseTotal,
    );
  }

  /// グラフの最大値を計算
  double _calculateMaxValue(
    int latestPrice,
    int? predictionPrice,
    int income,
    int budget,
  ) {
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
  /// 7日間隔で日付ラベルを生成する
  List<XAxisLabel> _generateXAxisLabels(DateTime fromDate, DateTime toDate) {
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

  /// 収入ラベルの表示位置を計算
  /// 予算との位置関係でラベル位置を調整（金額のみ返却）
  LabelPosition _calculateIncomeLabelPosition(
      int income, int budget, bool shouldShowBudgetLine) {
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
  LabelPosition _calculateBudgetLabelPosition(
      int income, int budget, bool shouldShowIncomeLine) {
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
  LabelPosition _calculateExpenseLabelPosition(int expense) {
    final priceLabel = yenFormattedPriceGetter(expense);
    // 特に他のラベルとの重なり考慮がなければデフォルト位置（少し上）
    // 過去月かつ収入・予算なしの場合のみ表示される前提なので、固定位置でOK
    return LabelPosition(label: priceLabel, yOffset: -7.0);
  }

  /// 予想支出ラベルを生成
  String _generatePredictionLabel(int predictionPrice) {
    final priceLabel = yenFormattedPriceGetter(predictionPrice);
    return priceLabel;
  }

  /// ラベル表示判定（重なりを考慮）
  /// グラフの最大値に対する収入と予算の位置関係から、ラベルが重なるかを判定
  _LabelDisplayDecision _decideLabelDisplay(
    int income,
    int budget,
    double maxValue,
    PredictionGraphLineType predictionGraphLineType,
  ) {
    // 支出ラベルは常に表示を試みる（実際の重なり判定はPainter側で実施）
    const shouldShowExpenseLabel = true;

    // どちらかが0の場合は、値がある方のみ表示
    if (income == 0 && budget == 0) {
      return _LabelDisplayDecision(
        shouldShowIncomeLine: false,
        shouldShowBudgetLine: false,
        shouldShowExpenseLabel: shouldShowExpenseLabel,
      );
    }
    if (income == 0) {
      return _LabelDisplayDecision(
        shouldShowIncomeLine: false,
        shouldShowBudgetLine: true,
        shouldShowExpenseLabel: shouldShowExpenseLabel,
      );
    }
    if (budget == 0) {
      return _LabelDisplayDecision(
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
        return _LabelDisplayDecision(
          shouldShowIncomeLine: true,
          shouldShowBudgetLine: false,
          shouldShowExpenseLabel: shouldShowExpenseLabel,
        );
      } else {
        return _LabelDisplayDecision(
          shouldShowIncomeLine: false,
          shouldShowBudgetLine: true,
          shouldShowExpenseLabel: shouldShowExpenseLabel,
        );
      }
    }

    // 位置の差が十分ある場合は両方表示
    return _LabelDisplayDecision(
      shouldShowIncomeLine: true,
      shouldShowBudgetLine: true,
      shouldShowExpenseLabel: shouldShowExpenseLabel,
    );
  }

}

/// ラベル表示判定結果
class _LabelDisplayDecision {
  final bool shouldShowIncomeLine;
  final bool shouldShowBudgetLine;
  final bool shouldShowExpenseLabel;

  _LabelDisplayDecision({
    required this.shouldShowIncomeLine,
    required this.shouldShowBudgetLine,
    required this.shouldShowExpenseLabel,
  });
}
