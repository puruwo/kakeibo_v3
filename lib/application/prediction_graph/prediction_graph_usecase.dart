import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:kakeibo/application/fixed_cost/fixed_cost_service.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/daily_bar_data.dart';
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
  late final ExpenseSmallCategoryRepository _smallCategoryRepo =
      ref.read(expenseSmallCategoryRepositoryProvider);
  late final ExpenseBigCategoryRepository _bigCategoryRepo =
      ref.read(expensebigCategoryRepositoryProvider);
  late final FixedCostCategoryRepository _fixedCostCategoryRepo =
      ref.read(fixedCostCategoryRepositoryProvider);

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
        displayMaxValue: 100.0, // デフォルト値
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
    final displayMaxValue = maxValue * 1.2;

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

    // 棒グラフデータを取得
    final dailyBarResult = await _getDailyBarData(fromDate, toDate, today);
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
      predictionLabel: predictionLabel,
      shouldShowPredictionLine: shouldShowPredictionLine,
      shouldShowBudgetLine: shouldShowBudgetLine,
      shouldShowIncomeLine: shouldShowIncomeLine,
      dailyBarDataList: dailyBarDataList,
      barMaxValue: barMaxValue,
      totalFixedCostExpense: fixedCostExpenseTotal,
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

  /// 予想支出ラベルを生成
  String _generatePredictionLabel(int predictionPrice) {
    final priceLabel = yenFormattedPriceGetter(predictionPrice);
    return priceLabel;
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
  /// 固定費は日付に関係なく初日にまとめて含める
  Future<List<Map<String, dynamic>>> getDailyDataList(
      PredictionGraphLineType predictionGraphLineType,
      DateTime fromDate,
      DateTime toDate) async {
    // 日付をキーとしたマップに変換してマージ
    final Map<DateTime, int> dailyExpenseSumMap = {};

    // 月全体の固定費合計を取得（初日に一括で加算するため）
    final period = PeriodValue(startDatetime: fromDate, endDatetime: toDate);
    final fixedCostExpenses =
        await _fixedCostExpenseRepo.fetchByPeriod(period: period);
    int totalFixedCost = 0;
    for (final expense in fixedCostExpenses) {
      totalFixedCost += expense.price;
    }

    // 開始日を初期値として追加（固定費を含む）
    dailyExpenseSumMap.addAll({fromDate: totalFixedCost});

    // 一般支出のみ日毎に取得してマップに追加（固定費は初日に含めたので除外）
    var loopSelectedDate = fromDate;
    while (loopSelectedDate.isBefore(toDate) ||
        loopSelectedDate.isSameDate(toDate)) {
      final dailyExpense = await _expenseRepo.fetchDailyExpenseByPeriod(
        date: loopSelectedDate,
      );

      if (dailyExpense > 0) {
        dailyExpenseSumMap[loopSelectedDate] =
            (dailyExpenseSumMap[loopSelectedDate] ?? 0) + dailyExpense;
      } else if (loopSelectedDate.isSameDate(toDate) &&
          !dailyExpenseSumMap.containsKey(loopSelectedDate)) {
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

  /// 日別カテゴリー別支出データを取得
  Future<_DailyBarResult> _getDailyBarData(
      DateTime fromDate, DateTime toDate, DateTime today) async {
    // 棒グラフのスケール閾値（2万円）
    const int barThreshold = 20000;

    // 大カテゴリー情報を取得してキャッシュ（colorCode, iconPath, name）
    final bigCategories = await _bigCategoryRepo.fetchAll();
    final bigCategoryMap = <int, _BigCategoryInfo>{};
    for (final cat in bigCategories) {
      bigCategoryMap[cat.id] = _BigCategoryInfo(
        colorCode: cat.colorCode,
        iconPath: cat.resourcePath,
        name: cat.bigCategoryName,
      );
    }

    // 小カテゴリー情報を取得してキャッシュ（小ID -> 大ID）
    final smallCategories = await _smallCategoryRepo.fetchAll();
    final smallToBigMap = <int, int>{};
    for (final cat in smallCategories) {
      smallToBigMap[cat.id] = cat.bigCategoryKey;
    }

    // 固定費カテゴリー情報を取得してキャッシュ
    final fixedCostCategories = await _fixedCostCategoryRepo.fetchAll();
    final fixedCostCategoryMap = <int, _BigCategoryInfo>{};
    for (final cat in fixedCostCategories) {
      fixedCostCategoryMap[cat.id] = _BigCategoryInfo(
        colorCode: cat.colorCode,
        iconPath: cat.resourcePath,
        name: cat.categoryName,
      );
    }

    // 期間内の固定費支出を取得
    final period = PeriodValue(startDatetime: fromDate, endDatetime: toDate);
    final fixedCostExpenses =
        await _fixedCostExpenseRepo.fetchByPeriod(period: period);

    // 固定費支出を日付別にグループ化
    final fixedCostByDate = <String, List<FixedCostExpenseEntity>>{};
    for (final expense in fixedCostExpenses) {
      final dateKey = expense.date;
      fixedCostByDate.putIfAbsent(dateKey, () => []);
      fixedCostByDate[dateKey]!.add(expense);
    }

    final dailyBarDataList = <DailyBarData>[];
    int maxDailyTotal = 0;

    // 期間内の各日のデータを取得
    var currentDate = fromDate;
    while (!currentDate.isAfter(toDate)) {
      // その日の一般支出リストを取得
      final expenses = await _expenseRepo.fetchDailyExpenseListByDate(
        date: currentDate,
      );

      // 大カテゴリー別に集計（一般支出のみ、固定費は含めない）
      final categoryTotals = <int, int>{};

      // 一般支出を集計
      for (final expense in expenses) {
        final smallCategoryId = expense.paymentCategoryId;
        final bigCategoryId = smallToBigMap[smallCategoryId] ?? 0;
        categoryTotals[bigCategoryId] =
            (categoryTotals[bigCategoryId] ?? 0) + expense.price;
      }

      // 支出がない日はスキップ
      if (categoryTotals.isEmpty) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }

      // カテゴリー別支出リストを作成（一般支出のみ）
      final categoryExpenses = <CategoryExpense>[];
      int dailyTotal = 0;

      for (final entry in categoryTotals.entries) {
        final catInfo = bigCategoryMap[entry.key];
        categoryExpenses.add(CategoryExpense(
          bigCategoryId: entry.key,
          price: entry.value,
          colorCode: catInfo?.colorCode ?? 'FF888888',
          iconPath: catInfo?.iconPath ?? '',
          categoryName: catInfo?.name ?? '',
          normalizedHeight: 0, // 後で設定
        ));
        dailyTotal += entry.value;
      }

      // 日別最大値を更新
      if (dailyTotal > maxDailyTotal) {
        maxDailyTotal = dailyTotal;
      }

      // 未来日付かどうか判定
      final isFutureDate = currentDate.isAfter(today);

      // 一時的なデータとして保持（後で正規化する）
      dailyBarDataList.add(DailyBarData(
        date: currentDate,
        isFutureDate: isFutureDate,
        categoryExpenses: categoryExpenses,
        normalizedTotalHeight: dailyTotal.toDouble(), // 一時的に合計値を入れる
      ));

      currentDate = currentDate.add(const Duration(days: 1));
    }

    // 棒グラフの最大値を計算（閾値を超えたらその最大値、それ以外は閾値）
    final barMaxValue =
        maxDailyTotal > barThreshold ? maxDailyTotal : barThreshold;

    // 正規化とデータ再構築
    final sqrtMaxValue = math.sqrt(barMaxValue);
    final normalizedList = <DailyBarData>[];

    for (final data in dailyBarDataList) {
      final dailyTotal = data.normalizedTotalHeight; // 一時的に入れた合計値
      final sqrtDaily = math.sqrt(dailyTotal);
      final normalizedTotalHeight = sqrtDaily / sqrtMaxValue;

      final normalizedExpenses = <CategoryExpense>[];
      for (final expense in data.categoryExpenses) {
        // 高さ比率 (合計に対する比率)
        final heightRatio = dailyTotal > 0 ? expense.price / dailyTotal : 0.0;

        normalizedExpenses.add(expense.copyWith(
          normalizedHeight: heightRatio,
        ));
      }

      normalizedList.add(data.copyWith(
        categoryExpenses: normalizedExpenses,
        normalizedTotalHeight: normalizedTotalHeight,
      ));
    }

    return _DailyBarResult(
      dailyBarDataList: normalizedList,
      barMaxValue: barMaxValue,
    );
  }
}

/// 棒グラフデータ取得結果
class _DailyBarResult {
  final List<DailyBarData> dailyBarDataList;
  final int barMaxValue;

  _DailyBarResult({
    required this.dailyBarDataList,
    required this.barMaxValue,
  });
}

/// 大カテゴリー情報キャッシュ用クラス
class _BigCategoryInfo {
  final String colorCode;
  final String iconPath;
  final String name;

  _BigCategoryInfo({
    required this.colorCode,
    required this.iconPath,
    required this.name,
  });
}
