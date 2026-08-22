import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:kakeibo/application/fixed_cost/fixed_cost_occurrence_service.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_constants.dart';
import 'package:kakeibo/theme/category_palette.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/daily_bar_data.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';

/// 棒グラフデータの取得結果
/// `dailyBarDataList` は正規化済み（normalizedTotalHeight が 0〜1 の比率）
class DailyBarResult {
  final List<DailyBarData> dailyBarDataList;
  final int barMaxValue;

  DailyBarResult({
    required this.dailyBarDataList,
    required this.barMaxValue,
  });
}

/// 大カテゴリー情報キャッシュ用
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

final predictionGraphDataSourceProvider = Provider<PredictionGraphDataSource>(
  PredictionGraphDataSource.new,
);

/// 予測グラフ用のデータソース
///
/// 折れ線（日付ごとの累積支出）と棒グラフ（日別カテゴリー集計）の
/// データ取得・集計を担う。usecase からはここを介してDBアクセスを行う。
class PredictionGraphDataSource {
  PredictionGraphDataSource(this._ref);

  final Ref _ref;

  late final ExpenseRepository _expenseRepo =
      _ref.read(expenseRepositoryProvider);
  late final ExpenseSmallCategoryRepository _smallCategoryRepo =
      _ref.read(expenseSmallCategoryRepositoryProvider);
  late final ExpenseBigCategoryRepository _bigCategoryRepo =
      _ref.read(expensebigCategoryRepositoryProvider);
  late final FixedCostOccurrenceService _fixedCostOccurrenceService =
      _ref.read(fixedCostOccurrenceServiceProvider);

  /// 折れ線用：日付ごとの累積支出データを取得する
  ///
  /// 一般支出と固定費（確定→price / 未確定→fixed_cost.estimated_price）を
  /// 日付通りに合算したうえで累積化したリストを返す。
  Future<List<Map<String, dynamic>>> fetchCumulativeByDate({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final mergedDataList = await _fetchDailyDataList(fromDate, toDate);

    // 累積値に変換
    int cumulativeSum = 0;
    for (int i = 0; i < mergedDataList.length; i++) {
      final int sumPriceDaily = mergedDataList[i]['sum_price_daily'] as int;
      cumulativeSum += sumPriceDaily;
      mergedDataList[i]['sum_price_daily'] = cumulativeSum;
    }
    return mergedDataList;
  }

  /// 日毎の支出データリストを取得
  ///
  /// 固定費実績もexpenseに入るため、日次集計（実効金額の共通式）が
  /// そのまま固定費を含む。加えて、期間内にまだ実績行が生成されていない
  /// 支払日ぶんを周期展開して積む（仕様 §7.4）。
  Future<List<Map<String, dynamic>>> _fetchDailyDataList(
      DateTime fromDate, DateTime toDate) async {
    // 日付をキーとしたマップに変換してマージ
    final Map<DateTime, int> dailyExpenseSumMap = {};

    // 実績行が未生成の固定費（未来の支払日など）を日付ごとに積む
    final occurrences = await _fixedCostOccurrenceService.fetchOccurrences(
      period: PeriodValue(startDatetime: fromDate, endDatetime: toDate),
    );
    for (final occurrence in occurrences) {
      if (occurrence.isGenerated) continue;
      dailyExpenseSumMap[occurrence.date] =
          (dailyExpenseSumMap[occurrence.date] ?? 0) + occurrence.amount;
    }

    // 支出を日毎に取得してマップに追加（生成済みの固定費行はここに含まれる）
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

  /// 棒グラフ用：日別カテゴリー別支出データを取得する
  ///
  /// 一般支出を大カテゴリー別に集計し、固定費はその日に登録があれば
  /// 1本のグレー棒として先頭に積む（同日複数レコードあれば1本に統合）。
  /// 各日の値は `barMaxValue` を基準に正規化された値で返す。
  Future<DailyBarResult> fetchDailyBarData({
    required DateTime fromDate,
    required DateTime toDate,
    required DateTime today,
  }) async {
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

    // 期間内に発生する固定費を「日付別の合計」に集計する
    // 生成済みの実績行は日次リストからも取れるが、未生成の支払日ぶん（仕様 §7.4）を
    // 同じ経路で扱うためここでまとめて日付別に集計する
    final period = PeriodValue(startDatetime: fromDate, endDatetime: toDate);
    final occurrences = await _fixedCostOccurrenceService.fetchOccurrences(
      period: period,
    );
    final fixedCostTotalByDate = <String, int>{};
    for (final occurrence in occurrences) {
      final dateKey = DateFormat('yyyyMMdd').format(occurrence.date);
      fixedCostTotalByDate[dateKey] =
          (fixedCostTotalByDate[dateKey] ?? 0) + occurrence.amount;
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

      // 大カテゴリー別に集計（一般支出）
      final categoryTotals = <int, int>{};

      // 一般支出を集計（固定費行は下でまとめて1本の棒にするため除外する）
      for (final expense in expenses) {
        if (expense.fixedCostId != null) continue;
        final smallCategoryId = expense.paymentCategoryId;
        final bigCategoryId = smallToBigMap[smallCategoryId] ?? 0;
        categoryTotals[bigCategoryId] =
            (categoryTotals[bigCategoryId] ?? 0) + expense.effectivePrice;
      }

      // その日の固定費合計（実績行＋未生成の支払日ぶん）
      final dateKey = DateFormat('yyyyMMdd').format(currentDate);
      final fixedCostForDay = fixedCostTotalByDate[dateKey] ?? 0;

      // 一般支出も固定費もない日はスキップ
      if (categoryTotals.isEmpty && fixedCostForDay == 0) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }

      // カテゴリー別支出リストを作成
      final categoryExpenses = <CategoryExpense>[];
      int dailyTotal = 0;

      // その日に固定費があれば、先頭にまとめて1本の棒として積む
      // （同じ日に複数レコードあっても1本に統合する）
      if (fixedCostForDay > 0) {
        categoryExpenses.add(CategoryExpense(
          bigCategoryId: PredictionGraphConstants.fixedCostBarCategoryId,
          price: fixedCostForDay,
          colorCode: CategoryPalette.fixedCostHex,
          iconPath: '',
          categoryName: '固定費',
          normalizedHeight: 0, // 後で設定
        ));
        dailyTotal += fixedCostForDay;
      }

      for (final entry in categoryTotals.entries) {
        final catInfo = bigCategoryMap[entry.key];
        categoryExpenses.add(CategoryExpense(
          bigCategoryId: entry.key,
          price: entry.value,
          colorCode: catInfo?.colorCode ?? CategoryPalette.fixedCostHex,
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
        maxDailyTotal > PredictionGraphConstants.barChartScaleThreshold
            ? maxDailyTotal
            : PredictionGraphConstants.barChartScaleThreshold;

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

    return DailyBarResult(
      dailyBarDataList: normalizedList,
      barMaxValue: barMaxValue,
    );
  }
}
