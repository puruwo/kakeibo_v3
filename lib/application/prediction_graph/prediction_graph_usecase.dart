import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_occurrence_service.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_data_source.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_layout_calculator.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_predictor.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';

final predictionGraphUsecaseProvider = Provider<PredictionGraphUsecase>(
  PredictionGraphUsecase.new,
);

class PredictionGraphUsecase {
  PredictionGraphUsecase(this.ref);

  final Ref ref;

  late final IncomeRepository _incomeRepo = ref.read(incomeRepositoryProvider);
  late final BudgetRepository _budgetRepo = ref.read(budgetRepositoryProvider);
  late final PredictionGraphDataSource _dataSource = ref.read(
    predictionGraphDataSourceProvider,
  );
  late final PredictionGraphLayoutCalculator _layoutCalc = ref.read(
    predictionGraphLayoutCalculatorProvider,
  );
  late final PredictionGraphPredictor _predictor = ref.read(
    predictionGraphPredictorProvider,
  );
  late final FixedCostOccurrenceService _fixedCostOccurrenceService = ref.read(
    fixedCostOccurrenceServiceProvider,
  );

  /// 予測グラフのデータを取得
  Future<PredictionGraphValue> fetchPredictionGraphData(
    DateScopeEntity dateScope,
  ) async {
    // 期間を取得
    final fromDate = dateScope.aggregationMonthPeriod.startDatetime;
    final toDate = dateScope.aggregationMonthPeriod.endDatetime;
    final today = ref.read(systemDatetimeNotifierProvider);

    // 予測グラフの種類を判定
    final predictionGraphLineType = _predictor.resolveGraphType(
      fromDate: fromDate,
      toDate: toDate,
      today: today,
    );

    // 未来月は計算不要のため早期リターン
    if (predictionGraphLineType == PredictionGraphLineType.futureMonth) {
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
    }

    // 累積支出データを取得（thisMonthは today まで、lastMonth は月末まで）
    final cumulativeToDate =
        predictionGraphLineType == PredictionGraphLineType.thisMonth
        ? today
        : toDate;
    final cumulativePriceData = await _dataSource.fetchCumulativeByDate(
      fromDate: fromDate,
      toDate: cumulativeToDate,
    );

    // 会計種別=生活収支の収入を取得（ADR-025: 特別枠系カテゴリーを除く全収入）
    final income = await _incomeRepo.calcurateSumWithAccountTypeAndPeriod(
      period: dateScope.aggregationMonthPeriod,
      accountType: AccountTypeConstants.living,
    );

    // 予算を取得
    final budget = await _budgetRepo.fetchMonthlyAll(
      month: dateScope.representativeMonth,
    );

    // 今月の固定費（実績行＋未生成の支払日ぶん）の合計をツールチップ用に取得する
    // 予算への加算は廃止した（仕様 §7.3）ので、この値は表示にのみ使う
    final fixedCostOccurrences = await _fixedCostOccurrenceService
        .fetchOccurrences(period: dateScope.aggregationMonthPeriod);
    final fixedCostExpenseTotal = fixedCostOccurrences.fold<int>(
      0,
      (sum, occurrence) => sum + occurrence.amount,
    );

    // 支出なし・予算なし・収入なしの場合はグラフ表示不要
    // isEmpty ではなく実際の合計値で判定する（最終日に0エントリーが追加されるケースに対応）
    final hasActualExpense = cumulativePriceData.any(
      (e) => (e['sum_price_daily'] as int) > 0,
    );
    if (!hasActualExpense && income == 0 && budget == 0) {
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

    // 折れ線・予測線を計算
    final predictionResult = _predictor.calculatePrediction(
      graphType: predictionGraphLineType,
      cumulativePriceData: cumulativePriceData,
      fromDate: fromDate,
      toDate: toDate,
      today: today,
    );

    // グラフの最大値を計算
    final maxValue = _layoutCalc.calculateMaxValue(
      latestPrice: predictionResult.lastPrice,
      predictionPrice: predictionResult.predictionPrice,
      income: income,
      budget: budget,
    );
    final displayMaxValue = maxValue * 1.2;

    // 横軸ラベルを生成
    final xAxisLabels = _layoutCalc.generateXAxisLabels(
      fromDate: fromDate,
      toDate: toDate,
    );

    // ラベル表示ロジック（重なりを考慮）
    final labelDisplayDecision = _layoutCalc.decideLabelDisplay(
      income: income,
      budget: budget,
      maxValue: maxValue,
      predictionGraphLineType: predictionGraphLineType,
    );
    final shouldShowIncomeLine = labelDisplayDecision.shouldShowIncomeLine;
    final shouldShowBudgetLine = labelDisplayDecision.shouldShowBudgetLine;
    final shouldShowExpenseLabel = labelDisplayDecision.shouldShowExpenseLabel;

    // 収入ラベルの位置を計算
    final incomeLabelPosition = shouldShowIncomeLine
        ? _layoutCalc.calculateIncomeLabel(
            income: income,
            budget: budget,
            shouldShowBudgetLine: shouldShowBudgetLine,
          )
        : null;

    // 予算ラベルの位置を計算
    final budgetLabelPosition = shouldShowBudgetLine
        ? _layoutCalc.calculateBudgetLabel(
            income: income,
            budget: budget,
            shouldShowIncomeLine: shouldShowIncomeLine,
          )
        : null;

    // 支出ラベルの位置を計算
    final expenseLabelPosition = shouldShowExpenseLabel
        ? _layoutCalc.calculateExpenseLabel(predictionResult.lastPrice)
        : null;

    // 棒グラフデータを取得
    final dailyBarResult = await _dataSource.fetchDailyBarData(
      fromDate: fromDate,
      toDate: toDate,
      today: today,
    );
    final dailyBarDataList = dailyBarResult.dailyBarDataList;
    final barMaxValue = dailyBarResult.barMaxValue;

    return PredictionGraphValue(
      predictionGraphLineType: predictionGraphLineType,
      fromDate: fromDate,
      toDate: toDate,
      today: today,
      expensePoints: predictionResult.expensePoints,
      predictionPoints: predictionResult.predictionPoints,
      income: income,
      budget: budget,
      maxValue: maxValue,
      displayMaxValue: displayMaxValue,
      latestPrice: predictionResult.lastPrice,
      predictionPrice: predictionResult.predictionPrice,
      xAxisLabels: xAxisLabels,
      incomeLabelPosition: incomeLabelPosition,
      budgetLabelPosition: budgetLabelPosition,
      predictionLabel: predictionResult.predictionLabel,
      shouldShowPredictionLine: predictionResult.shouldShowPredictionLine,
      shouldShowBudgetLine: shouldShowBudgetLine,
      shouldShowIncomeLine: shouldShowIncomeLine,
      shouldShowExpenseLabel: shouldShowExpenseLabel,
      expenseLabelPosition: expenseLabelPosition,
      dailyBarDataList: dailyBarDataList,
      barMaxValue: barMaxValue,
      totalFixedCostExpense: fixedCostExpenseTotal,
    );
  }
}
