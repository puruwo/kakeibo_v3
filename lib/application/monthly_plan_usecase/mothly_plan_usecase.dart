import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/monthly_plan_value/monthly_plan_value.dart';
import 'package:kakeibo/domain_service/month_period_service/aggregation_representative_month_service.dart';
import 'package:kakeibo/view_model/state/date_scope/entity/date_scope_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final monthlyPlanNotifierProvider = AsyncNotifierProvider.family<
    MonthlyPlanUsecaseNotifier, MonthlyPlanValue, DateScopeEntity>(
  MonthlyPlanUsecaseNotifier.new,
);

class MonthlyPlanUsecaseNotifier
    extends FamilyAsyncNotifier<MonthlyPlanValue, DateScopeEntity> {
  late ExpenseRepository _expenseRepositoryProvider;
  late IncomeRepository _incomeRepository;
  late AggregationRepresentativeMonthService
      _aggregationRepresentativeMonthService;
  late BudgetRepository _budgetRepository;

  @override
  Future<MonthlyPlanValue> build(DateScopeEntity dateScope) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);
    _expenseRepositoryProvider = ref.read(expenseRepositoryProvider);

    _incomeRepository = ref.read(incomeRepositoryProvider);

    _aggregationRepresentativeMonthService =
        ref.read(aggregationRepresentativeMonthServiceProvider);

    _budgetRepository = ref.read(budgetRepositoryProvider);

    return fetch(dateScope: dateScope);
  }

  // 前カテゴリー合計のタイルデータを取得する
  Future<MonthlyPlanValue> fetch({required DateScopeEntity dateScope}) async {

    // 選択した月の集計期間から開始日と終了日を取得する
    DateTime fromDate = dateScope.monthPeriod.startDatetime;
    DateTime toDate = dateScope.monthPeriod.endDatetime;

    // 全カテゴリーの支出を取得
    // 大カテゴリーIDを0にすることで、ボーナスを除くカテゴリーの支出を取得する
    final mothlyExpense = await _expenseRepositoryProvider
        .fetchTotalExpenseByPeriodWithBigCategory(incomeSourceBigCategory: 0, fromDate: fromDate, toDate: toDate);

    // categoryIdは0を指定することで、月次収入の合計を取得する
    final monthlyIncome =
        await _incomeRepository.calcurateSumWithBigCategoryAndPeriod(
            period: dateScope.monthPeriod, bigCategoryId: 0);

    // 集計期間の代表月を取得
    final aggregationRepresentativeMonth =
        await _aggregationRepresentativeMonthService
            .fetchMonth(dateScope.selectedDate);

    // 集計期間代表月の予算を取得
    final totalPrice = await _budgetRepository.fetchMonthlyAll(
        month: aggregationRepresentativeMonth);

    // 今月の残額を計算
    final realSavings = monthlyIncome - mothlyExpense;

    return MonthlyPlanValue(
      monthlyExpense: mothlyExpense,
      monthlyIncome: monthlyIncome,
      monthlyBudget: totalPrice,
      realSavings: realSavings,
    );
  }
}
