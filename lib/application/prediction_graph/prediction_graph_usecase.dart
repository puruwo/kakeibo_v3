import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:kakeibo/application/fixed_cost/fixed_cost_service.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';
import 'package:kakeibo/util/util.dart';

final predictionGraphUsecaseProvider = Provider<PredictionGraphUsecase>(
  PredictionGraphUsecase.new,
);

/// ラベル表示判定結果
class _LabelDisplayDecision {
  final bool shouldShowIncomeLine;
  final bool shouldShowBudgetLine;

  _LabelDisplayDecision({
    required this.shouldShowIncomeLine,
    required this.shouldShowBudgetLine,
  });
}

class PredictionGraphUsecase {
  PredictionGraphUsecase(this.ref);

  final Ref ref;

  late final IncomeRepository _incomeRepo = ref.read(incomeRepositoryProvider);
  late final ExpenseRepository _expenseRepo =
      ref.read(expenseRepositoryProvider);
  late final FixedCostExpenseRepository _fixedCostExpenseRepo =
      ref.read(fixedCostExpenseRepositoryProvider);
  late final BudgetRepository _budgetRepo = ref.read(budgetRepositoryProvider);

  /// 横軸ラベルの間隔（日数）
  static const int _xAxisLabelInterval = 7;

  /// 予測グラフのデータを取得
  Future<PredictionGraphValue> fetchPredictionGraphData(
      DateScopeEntity dateScope) async {
    // 期間を取得
    final fromDate = dateScope.monthPeriod.startDatetime;
    final toDate = dateScope.monthPeriod.endDatetime;
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
      );
    } else {
      predictionGraphLineType = PredictionGraphLineType.thisMonth;
    }

    // 累積支出データを取得
    final cumulativePriceData =
        predictionGraphLineType == PredictionGraphLineType.lastMonth
            ? await _getCumulativePriceByDate(
                predictionGraphLineType, fromDate, toDate)
            : predictionGraphLineType == PredictionGraphLineType.thisMonth
                ? await _getCumulativePriceByDate(
                    predictionGraphLineType, fromDate, today)
                : [];

    // 収入を取得
    final income = await _incomeRepo.calcurateSumWithBigCategoryAndPeriod(
        period: dateScope.monthPeriod,
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

    // 累積支出データをチャート用に変換
    final expensePoints = <PredictionGraphPoint>[];
    int lastPrice = 0;
    DateTime lastDate = fromDate;
    if (cumulativePriceData.isNotEmpty) {
      for (final data in cumulativePriceData) {
        final dateTime = data['date'] as DateTime;
        final price = data['sum_price_daily'] as int;
        expensePoints.add(PredictionGraphPoint(date: dateTime, price: price));
      }
    }

    // 経過日数と総日数を計算するために最後のデータを取得
    final lastData = cumulativePriceData.last;
    lastDate = lastData['date'] as DateTime;
    lastPrice = lastData['sum_price_daily'] as int;

    // 経過日数と総日数を計算
    final elapsedDays = lastDate.difference(fromDate).inDays + 1;
    final totalDays = toDate.difference(fromDate).inDays + 1;

    ///予想支出額を計算するロジック
    int? predictionPrice;
    bool shouldShowPredictionLine;
    List<PredictionGraphPoint>? predictionPoints;
    String? predictionLabel;
    // 予測支出額を表示しない条件（過去月、未来月、経過日数5日以下、データなし）
    if (elapsedDays <= 5 ||
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
      predictionLabel = _generatePredictionLabel(predictionPrice);
    }

    // グラフの最大値を計算
    final maxValue = _calculateMaxValue(
      lastPrice,
      predictionPrice,
      income,
      budgetIncludeFixedCost,
    );

    // 横軸ラベルを生成
    final xAxisLabels = _generateXAxisLabels(fromDate, toDate);

    // ラベル表示ロジック（重なりを考慮）
    final labelDisplayDecision =
        _decideLabelDisplay(income, budgetIncludeFixedCost, maxValue);
    final shouldShowIncomeLine = labelDisplayDecision.shouldShowIncomeLine;
    final shouldShowBudgetLine = labelDisplayDecision.shouldShowBudgetLine;

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
      latestPrice: lastPrice,
      predictionPrice: predictionPrice,
      xAxisLabels: xAxisLabels,
      incomeLabelPosition: incomeLabelPosition,
      budgetLabelPosition: budgetLabelPosition,
      predictionLabel: predictionLabel,
      shouldShowPredictionLine: shouldShowPredictionLine,
      shouldShowBudgetLine: shouldShowBudgetLine,
      shouldShowIncomeLine: shouldShowIncomeLine,
    );
  }

  /// 日毎の累積支出データを取得
  Future<List<Map<String, dynamic>>> _getCumulativePriceByDate(
      PredictionGraphLineType predictionGraphLineType,
      DateTime fromDate,
      DateTime toDate) async {
    // 日毎のmapを取得
    final List<Map<String, dynamic>> mergedDataList =
        await getDailyDataList(predictionGraphLineType, fromDate, toDate);

    // 累積値に変換
    int cumulativeSum = 0;
    for (int i = 0; i < mergedDataList.length; i++) {
      final int sumPriceDaily = mergedDataList[i]['sum_price_daily'] as int;
      cumulativeSum += sumPriceDaily;
      mergedDataList[i]['sum_price_daily'] = cumulativeSum;
    }
    return mergedDataList;
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

    for (int i = 0; i < totalDays; i += _xAxisLabelInterval) {
      final date = fromDate.add(Duration(days: i));
      final label = DateFormat.Md().format(date);
      labels.add(XAxisLabel(date: date, label: label));
    }

    return labels;
  }

  /// 収入ラベルの表示位置を計算
  /// 予算との位置関係でラベル位置を調整
  LabelPosition _calculateIncomeLabelPosition(
      int income, int budget, bool shouldShowBudgetLine) {
    final priceLabel = yenFormattedPriceGetter(income);
    final label = '給与 $priceLabel';

    // 予算が表示されない場合は上に表示
    if (!shouldShowBudgetLine) {
      return LabelPosition(label: label, yOffset: -7.0);
    }

    // 収入が予算以下の場合は上に、予算より大きい場合はさらに上に表示
    final yOffset = income <= budget ? -7.0 : -25.0;

    return LabelPosition(label: label, yOffset: yOffset);
  }

  /// 予算ラベルの表示位置を計算
  /// 収入との位置関係でラベル位置を調整
  LabelPosition _calculateBudgetLabelPosition(
      int income, int budget, bool shouldShowIncomeLine) {
    final priceLabel = yenFormattedPriceGetter(budget);
    final label = '予算 $priceLabel';

    // 収入が表示されない場合は上に表示
    if (!shouldShowIncomeLine) {
      return LabelPosition(label: label, yOffset: -7.0);
    }

    // 収入が予算以下の場合は上に、収入が予算より大きい場合は下に表示
    final yOffset = income <= budget ? -23.0 : 0.0;

    return LabelPosition(label: label, yOffset: yOffset);
  }

  /// 予想支出ラベルを生成
  String _generatePredictionLabel(int predictionPrice) {
    final priceLabel = yenFormattedPriceGetter(predictionPrice);
    return '予想支出 $priceLabel';
  }

  /// ラベル表示判定（重なりを考慮）
  /// グラフの最大値に対する収入と予算の位置関係から、ラベルが重なるかを判定
  _LabelDisplayDecision _decideLabelDisplay(
      int income, int budget, double maxValue) {
    // どちらかが0の場合は、値がある方のみ表示
    if (income == 0 && budget == 0) {
      return _LabelDisplayDecision(
        shouldShowIncomeLine: false,
        shouldShowBudgetLine: false,
      );
    }
    if (income == 0) {
      return _LabelDisplayDecision(
        shouldShowIncomeLine: false,
        shouldShowBudgetLine: true,
      );
    }
    if (budget == 0) {
      return _LabelDisplayDecision(
        shouldShowIncomeLine: true,
        shouldShowBudgetLine: false,
      );
    }

    // 両方とも値がある場合、グラフ上の位置の差を計算
    // グラフの高さを100%として、収入と予算の位置を計算
    final incomePosition = income / maxValue; // 0.0 ~ 1.0
    final budgetPosition = budget / maxValue; // 0.0 ~ 1.0

    // 位置の差の絶対値を計算（グラフ上の距離）
    final positionDiff = (incomePosition - budgetPosition).abs();

    // 位置の差が10%未満の場合、ラベルが重なると判定
    // この場合、大きい方の値を優先して表示
    if (positionDiff < 0.1) {
      if (income >= budget) {
        return _LabelDisplayDecision(
          shouldShowIncomeLine: true,
          shouldShowBudgetLine: false,
        );
      } else {
        return _LabelDisplayDecision(
          shouldShowIncomeLine: false,
          shouldShowBudgetLine: true,
        );
      }
    }

    // 位置の差が十分ある場合は両方表示
    return _LabelDisplayDecision(
      shouldShowIncomeLine: true,
      shouldShowBudgetLine: true,
    );
  }

  /// 日毎の支出データリストを取得
  Future<List<Map<String, dynamic>>> getDailyDataList(
      PredictionGraphLineType predictionGraphLineType,
      DateTime fromDate,
      DateTime toDate) async {
    // 日付をキーとしたマップに変換してマージ
    final Map<DateTime, int> dailyExpenseSumMap = {};
    dailyExpenseSumMap.addAll({fromDate: 0}); // 開始日を初期値として追加

    // 一般支出と固定費を日毎に取得してマップに追加
    var loopSelectedDate = fromDate;
    while (loopSelectedDate.isBefore(toDate) ||
        loopSelectedDate.isSameDate(toDate)) {
      final dailyExpense = await _expenseRepo.fetchDailyExpenseByPeriod(
        date: loopSelectedDate,
      );
      final dailyFixedCost =
          await _fixedCostExpenseRepo.fetchDailyFixedCostExpenseByPeriod(
        date: loopSelectedDate,
      );

      final totalExpense = dailyExpense + dailyFixedCost;
      if (totalExpense > 0) {
        dailyExpenseSumMap[loopSelectedDate] = totalExpense;
      } else if (loopSelectedDate.isSameDate(toDate)) {
        // 最終日で支出が0の場合も追加
        dailyExpenseSumMap[loopSelectedDate] = 0;
      }
      loopSelectedDate = loopSelectedDate.add(const Duration(days: 1));
    }

    // マップをリストに変換してソート
    final mergedDataList = dailyExpenseSumMap.entries
        .map((entry) => {'date': entry.key, 'sum_price_daily': entry.value})
        .toList()
      ..sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return mergedDataList;
  }
}
