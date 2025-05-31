import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
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
  late IncomeRepository _incomeRepository;
  late AggregationRepresentativeMonthService
      _aggregationRepresentativeMonthService;
  late BudgetRepository _budgetRepository;

  @override
  Future<MonthlyPlanValue> build(DateScopeEntity dateScope) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _incomeRepository = ref.read(incomeRepositoryProvider);

    _aggregationRepresentativeMonthService =
        ref.read(aggregationRepresentativeMonthServiceProvider);

    _budgetRepository = ref.read(budgetRepositoryProvider);

    return fetch(dateScope: dateScope);
  }

  // 前カテゴリー合計のタイルデータを取得する
  Future<MonthlyPlanValue> fetch(
      {required DateScopeEntity dateScope}) async {
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

    // 予定貯金を計算
    final expectedSavings = monthlyIncome - totalPrice;

    return MonthlyPlanValue(
      monthlyIncome: monthlyIncome,
      monthlyBudget: totalPrice,
      expectedSavings: expectedSavings,
    );
  }
}
