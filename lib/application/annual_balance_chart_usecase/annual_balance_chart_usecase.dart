import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/annual_balance_chart_value.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/monthly_balance_value/monthly_balance_value.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/y_axis_scale.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_representative_month_service.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final annualBalanceChartNotifierProvider =
    AsyncNotifierProvider.family<
      AnnualBalanceChartUsecaseNotifier,
      AnnualBalanceChartValue,
      DateScopeEntity
    >(AnnualBalanceChartUsecaseNotifier.new);

class AnnualBalanceChartUsecaseNotifier
    extends FamilyAsyncNotifier<AnnualBalanceChartValue, DateScopeEntity> {
  late IncomeRepository _incomeRepository;
  late ExpenseRepository _expenseRepository;
  late FixedCostExpenseRepository _fixedCostExpenseRepository;
  late MonthPeriodService _monthPeriodService;
  late AggregationRepresentativeMonthService _aRMService;

  @override
  Future<AnnualBalanceChartValue> build(DateScopeEntity dateScope) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _incomeRepository = ref.read(incomeRepositoryProvider);

    _expenseRepository = ref.read(expenseRepositoryProvider);

    _fixedCostExpenseRepository = ref.read(fixedCostExpenseRepositoryProvider);

    _monthPeriodService = ref.read(monthPeriodServiceProvider);

    _aRMService = ref.read(aggregationRepresentativeMonthServiceProvider);

    return fetch(dateScope: dateScope);
  }

  // その年の月ごとの収支を取得する
  Future<AnnualBalanceChartValue> fetch({
    required DateScopeEntity dateScope,
  }) async {
    final monthBalanceValues = <MonthlyBalanceValue>[];

    // 「現在月度」は systemDatetime（運用日時）から導出する
    // selectedDate ベースで計算すると年度切替後に当該年度の開始月以降が
    // すべて未来扱いになるため、実際の今日を基準にする
    final systemDate = ref.read(systemDatetimeNotifierProvider);
    final currentMonthPeriod = await _monthPeriodService.fetchMonthPeriod(
      systemDate,
    );

    // 一番最初の月の期間を取得
    final firstMonthPeriod = await _monthPeriodService.fetchMonthPeriod(
      dateScope.yearPeriod.startDatetime,
    );

    // 未来
    bool hasNoRecord = true;
    for (int i = 0; i < 12; i++) {
      final pueryPeriod = _monthPeriodService.fetchShiftedMonthPeriod(
        firstMonthPeriod,
        i,
      );

      // 会計種別=生活収支の収入を取得（ADR-025: 特別枠系カテゴリーを除く全収入）
      final income = await _incomeRepository
          .calcurateSumWithAccountTypeAndPeriod(
            period: pueryPeriod,
            accountType: AccountTypeConstants.living,
          );

      // 拠出元=生活収支の一般支出を取得（特別枠充当の支出を除く）
      final regularExpense = await _expenseRepository
          .fetchTotalExpenseByPeriodWithBigCategory(
            incomeSourceBigCategory: AccountTypeConstants.living,
            fromDate: pueryPeriod.startDatetime,
            toDate: pueryPeriod.endDatetime,
          );

      // 確定済み固定費支出を取得（生活収支に合算）
      final fixedCostExpense = await _fixedCostExpenseRepository
          .fetchTotalConfirmedFixedCostExpenseWithPeriod(period: pueryPeriod);

      // 未確定固定費の推定額を取得（生活収支に合算）
      final unconfirmedFixedCostExpense = await _fixedCostExpenseRepository
          .fetchTotalUnconfirmedFixedCostEstimatedWithPeriod(
            period: pueryPeriod,
          );

      final expense =
          regularExpense + fixedCostExpense + unconfirmedFixedCostExpense;

      // ステータスを確認
      MonthlyBalanceType monthlyBalanceType;
      if (pueryPeriod.startDatetime.isAfter(currentMonthPeriod.endDatetime)) {
        monthlyBalanceType = MonthlyBalanceType.future;
      } else if (income == 0 && expense == 0) {
        monthlyBalanceType = MonthlyBalanceType.noRecorod;
      } else if (income == 0) {
        monthlyBalanceType = MonthlyBalanceType.noIncome;
        hasNoRecord = false;
      } else if (expense == 0) {
        monthlyBalanceType = MonthlyBalanceType.noExpense;
        hasNoRecord = false;
      } else if (income - expense > 0) {
        monthlyBalanceType = MonthlyBalanceType.surplus;
        hasNoRecord = false;
      } else {
        monthlyBalanceType = MonthlyBalanceType.deficit;
        hasNoRecord = false;
      }

      final monthNumber = await _aRMService.fetchMonth(
        pueryPeriod.startDatetime,
      );

      monthBalanceValues.add(
        MonthlyBalanceValue(
          month: monthNumber.monthNumber,
          monthlyIncome: income,
          monthlyExpense: expense,
          savings: income - expense,
          monthlyBalanceType: monthlyBalanceType,
          representativeDate: pueryPeriod.startDatetime,
        ),
      );
    }

    // Y軸スケールを計算（未来月を除外）
    final yAxisScale = _calculateYAxisScale(monthBalanceValues);

    AnnualBalanceChartValue result = AnnualBalanceChartValue(
      monthIndex: dateScope.monthIndex,
      currentMonth: dateScope.representativeMonth.monthNumber,
      monthlyBalanceValues: monthBalanceValues,
      hasNoRecord: hasNoRecord,
      yAxisScale: yAxisScale,
    );

    return result;
  }

  /// 未来月を除いた収入・支出から、折れ線エリアのY軸スケールを計算する。
  /// グリッド間隔は 1/2/5 系列から選択して目標本数（約5本）に近づける。
  /// 記録ゼロの場合はダミー値を返す（描画側は hasNoRecord で早期リターンする想定）。
  YAxisScale _calculateYAxisScale(List<MonthlyBalanceValue> values) {
    final incomeExpense = <double>[];
    for (final v in values) {
      if (v.monthlyBalanceType == MonthlyBalanceType.future) continue;
      incomeExpense.add(v.monthlyIncome.toDouble());
      incomeExpense.add(v.monthlyExpense.toDouble());
    }

    if (incomeExpense.isEmpty) {
      return const YAxisScale(
        minValue: 0,
        maxValue: 100000,
        interval: 10000,
        gridValues: [],
      );
    }

    final rawMax = incomeExpense.reduce(max);

    // 1/2/5 系列で切りの良い interval を選定（目標グリッド本数=5）
    const targetGridCount = 5;
    final interval = _niceInterval(rawMax, targetGridCount);

    // minValue は 0 固定、maxValue は rawMax を interval 単位で切り上げ
    const minValue = 0.0;
    final maxSteps = max(1, (rawMax / interval).ceil());
    final maxValue = maxSteps * interval;

    // 0 から interval 刻みで maxValue までグリッド値を列挙
    final gridValues = <double>[];
    for (int step = 0; step <= maxSteps; step++) {
      gridValues.add(step * interval);
    }

    return YAxisScale(
      minValue: minValue,
      maxValue: maxValue,
      interval: interval,
      gridValues: gridValues,
    );
  }

  /// (range / targetGridCount) に最も近い 10^n × {1, 2, 5} を返す。
  /// 下限は 10000（1万未満のグリッドは出さない）。
  double _niceInterval(double range, int targetGridCount) {
    if (range <= 0) return 10000.0;
    final rawStep = range / targetGridCount;
    final exp = (log(rawStep) / ln10).floor();
    final pow10 = pow(10, exp).toDouble();
    final base = rawStep / pow10;
    final double niceBase;
    if (base < 1.5) {
      niceBase = 1.0;
    } else if (base < 3.5) {
      niceBase = 2.0;
    } else if (base < 7.5) {
      niceBase = 5.0;
    } else {
      niceBase = 10.0;
    }
    final result = niceBase * pow10;
    return result < 10000.0 ? 10000.0 : result;
  }
}
