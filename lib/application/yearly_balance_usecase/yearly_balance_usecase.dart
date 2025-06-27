import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/yearly_balance_value/yearly_balance_value.dart';
import 'package:kakeibo/view_model/state/date_scope/entity/date_scope_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final yearlyBalanceNotifierProvider = AsyncNotifierProvider.family<
    YearlyBalanceUsecaseNotifier, YearlyBalanceValue, DateScopeEntity>(
  YearlyBalanceUsecaseNotifier.new,
);

class YearlyBalanceUsecaseNotifier
    extends FamilyAsyncNotifier<YearlyBalanceValue, DateScopeEntity> {
  late IncomeRepository _incomeRepository;
  late ExpenseRepository _expenseRepository;

  @override
  Future<YearlyBalanceValue> build(DateScopeEntity dateScope) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _incomeRepository = ref.read(incomeRepositoryProvider);

    _expenseRepository = ref.read(expenseRepositoryProvider);

    return fetch(dateScope: dateScope);
  }

  // 前カテゴリー合計のタイルデータを取得する
  Future<YearlyBalanceValue> fetch({required DateScopeEntity dateScope}) async {
    // 年間収入を取得
    final yearlyIncome = await _incomeRepository.calcurateSumWithPeriod(
        period: dateScope.yearPeriod);

    // 年間支出を取得
    final yearlyExpense = await _expenseRepository.fetchTotalExpenseByPeriod(
        fromDate: dateScope.yearPeriod.startDatetime,
        toDate: dateScope.yearPeriod.endDatetime);

    // 残金を計算
    final savings = yearlyIncome - yearlyExpense;

    YearlyBalanceType yearlyBalanceType;
    if (yearlyIncome == 0 && yearlyExpense == 0) {
      yearlyBalanceType = YearlyBalanceType.noRecorod;
    } else if (yearlyIncome == 0) {
      yearlyBalanceType = YearlyBalanceType.noIncome;
    } else if (yearlyExpense == 0) {
      yearlyBalanceType = YearlyBalanceType.noExpense;
    } else if (savings > 0) {
      yearlyBalanceType = YearlyBalanceType.surplus;
    } else {
      yearlyBalanceType = YearlyBalanceType.deficit;
    }

    return YearlyBalanceValue(
      yearlyIncome: yearlyIncome,
      yearlyExpense: yearlyExpense,
      savings: savings,
      yearlyBalanceType: yearlyBalanceType,
    );
  }
}
