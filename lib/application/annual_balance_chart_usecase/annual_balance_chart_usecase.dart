import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/annual_balance_chart_value.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/monthly_balance_value/monthly_balance_value.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_representative_month_service.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final annualBalanceChartNotifierProvider = AsyncNotifierProvider.family<
    AnnualBalanceChartUsecaseNotifier,
    AnnualBalanceChartValue,
    DateScopeEntity>(
  AnnualBalanceChartUsecaseNotifier.new,
);

class AnnualBalanceChartUsecaseNotifier
    extends FamilyAsyncNotifier<AnnualBalanceChartValue, DateScopeEntity> {
  late IncomeRepository _incomeRepository;
  late ExpenseRepository _expenseRepository;
  late MonthPeriodService _monthPeriodService;
  late AggregationRepresentativeMonthService _aRMService;

  @override
  Future<AnnualBalanceChartValue> build(DateScopeEntity dateScope) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _incomeRepository = ref.read(incomeRepositoryProvider);

    _expenseRepository = ref.read(expenseRepositoryProvider);

    _monthPeriodService = ref.read(monthPeriodServiceProvider);

    _aRMService = ref.read(aggregationRepresentativeMonthServiceProvider);

    return fetch(dateScope: dateScope);
  }

  // その年の月ごとの収支を取得する
  Future<AnnualBalanceChartValue> fetch(
      {required DateScopeEntity dateScope}) async {
    final monthBalanceValues = <MonthlyBalanceValue>[];

    // 現在の月の期間を取得
    final currentMonthPeriod = dateScope.monthPeriod;

    // 一番最初の月の期間を取得
    final firstMonthPeriod = await _monthPeriodService
        .fetchMonthPeriod(dateScope.yearPeriod.startDatetime);

    // 未来
    bool hasNoRecord = true;
    for (int i = 0; i < 12; i++) {
      final pueryPeriod =
          _monthPeriodService.fetchShiftedMonthPeriod(firstMonthPeriod, i);

      // ボーナス以外の収入を取得
      final income =
          await _incomeRepository.calcurateSumWithBigCategoryAndPeriod(
              period: pueryPeriod, bigCategoryId: 0);

      // ボーナス支出以外の支出を取得
      final expense =
          await _expenseRepository.fetchTotalExpenseByPeriodWithBigCategory(
              incomeSourceBigCategory: 0,
              fromDate: pueryPeriod.startDatetime,
              toDate: pueryPeriod.endDatetime);

      // ステータスを確認
      MonthlyBalanceType monthlyBalanceType;
      if (pueryPeriod.startDatetime.isAfter(currentMonthPeriod.endDatetime)) {
        monthlyBalanceType = MonthlyBalanceType.future;
      } else if (income == 0 && expense == 0) {
        monthlyBalanceType = MonthlyBalanceType.noRecorod;
      } else if (income == 0) {
        monthlyBalanceType = MonthlyBalanceType.noIncome;
        hasNoRecord = false;
      } else if (income == 0) {
        monthlyBalanceType = MonthlyBalanceType.noExpense;
        hasNoRecord = false;
      } else if (income - expense > 0) {
        monthlyBalanceType = MonthlyBalanceType.surplus;
        hasNoRecord = false;
      } else {
        monthlyBalanceType = MonthlyBalanceType.deficit;
        hasNoRecord = false;
      }

      final monthNumber =
          await _aRMService.fetchMonth(pueryPeriod.startDatetime);

      monthBalanceValues.add(
        MonthlyBalanceValue(
          month: monthNumber.monthNumber,
          monthlyIncome: income,
          monthlyExpense: expense,
          savings: income - expense,
          monthlyBalanceType: monthlyBalanceType,
        ),
      );
    }

    AnnualBalanceChartValue result = AnnualBalanceChartValue(
      monthIndex: dateScope.monthIndex,
      currentMonth: dateScope.representativeMonth.monthNumber,
      monthlyBalanceValues: monthBalanceValues,
      hasNoRecord:hasNoRecord,
    );

    return result;
  }
}
