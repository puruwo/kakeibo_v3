import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:collection/collection.dart';
import 'package:kakeibo/application/expense_history/bonus_expense_history_digest_usecase.dart';
import 'package:kakeibo/application/expense_history/expense_history_service.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_usecase.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_unconfirmed_fixed_cost_usecase.dart';
import 'package:kakeibo/application/income_history/income_history_usecase.dart';
import 'package:kakeibo/application/income_history/request_income_history_usecase.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_group_value.dart';
import 'package:kakeibo/domain/ui_value/historical_all_transactions_value/historical_all_transactions_value.dart';
import 'dart:collection';

import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 履歴ページ用の全トランザクションデータを取得するプロバイダ
// 支出（ボーナス除く）、ボーナス支出、収入（月次）、ボーナス収入、固定費（確定/未確定）を取得

final historicalTransactionNotifierProvider = AsyncNotifierProvider.family<
    HistoricalTransactionUsecaseNotifier,
    HistoricalAllTransactionsValue,
    PeriodValue>(
  HistoricalTransactionUsecaseNotifier.new,
);

class HistoricalTransactionUsecaseNotifier
    extends FamilyAsyncNotifier<HistoricalAllTransactionsValue, PeriodValue> {
  @override
  Future<HistoricalAllTransactionsValue> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    // 各データを取得
    final expenses = await _fetchExpenses(selectedMonthPeriod);
    final bonusExpenses = await ref.watch(
        bonusExpenseHistoryDigestNotifierProvider(selectedMonthPeriod).future);

    // 月次収入取得用のリクエスト（bigId=0）
    final incomeRequest = RequestIncomeHistoryUsecase(
        bigId: 0, selectedMonthPeriod: selectedMonthPeriod);
    final incomes =
        await ref.watch(incomeHistoryNotifierProvider(incomeRequest).future);

    // ボーナス収入取得用のリクエスト（bigId=1）
    final bonusIncomeRequest = RequestIncomeHistoryUsecase(
        bigId: 1, selectedMonthPeriod: selectedMonthPeriod);
    final bonusIncomes = await ref
        .watch(incomeHistoryNotifierProvider(bonusIncomeRequest).future);

    final confirmedFixedCosts = await ref
        .watch(monthlyFixedCostNotifierProvider(selectedMonthPeriod).future);
    final unconfirmedFixedCosts = await ref.watch(
        monthlyUnconfirmedFixedCostNotifierProvider(selectedMonthPeriod)
            .future);

    return HistoricalAllTransactionsValue(
      expenses: expenses,
      bonusExpenses: bonusExpenses,
      incomes: incomes,
      bonusIncomes: bonusIncomes,
      confirmedFixedCosts: confirmedFixedCosts,
      unconfirmedFixedCosts: unconfirmedFixedCosts,
    );
  }

  // 通常支出（ボーナス除く）を取得して日付でグループ分け
  Future<List<ExpenseHistoryTileGroupValue>> _fetchExpenses(
      PeriodValue selectedMonthPeriod) async {
    final service = ExpenseHistoryService(
      expenseRepo: ref.read(expenseRepositoryProvider),
      smallCategoryRepo: ref.read(expenseSmallCategoryRepositoryProvider),
      bigCategoryRepo: ref.read(expensebigCategoryRepositoryProvider),
    );

    // incomeSourceBigIdは0を指定して、月次支出のみを取得する
    final entities = await service.fetchTileList(0, selectedMonthPeriod);

    // 取得したタイルデータをDateTimeでグループ分けする
    final grouped = entities.groupListsBy<DateTime>((e) => e.date);

    // DateTimeで分けられたグループを、上から降順に並び替える
    SplayTreeMap<DateTime, List<ExpenseHistoryTileValue>> sortedGroup =
        SplayTreeMap.from(
            grouped, (DateTime key1, DateTime key2) => key2.compareTo(key1));

    final List<ExpenseHistoryTileGroupValue> result = [];

    // グループ分けされたExpenseHistoryTileValueを、さらに各グループ内でidによって降順で並び替える
    for (var aGroup in sortedGroup.entries) {
      // idによる降順で並び替え
      aGroup.value.sort(((a, b) => b.id.compareTo(a.id)));

      // グループ分けされ並べ替えたMapをExpenseHistoryTileGroupValueに変換する
      final buffGroup = ExpenseHistoryTileGroupValue(
        date: aGroup.key,
        expenseHistoryTileValueList: aGroup.value,
      );

      result.add(buffGroup);
    }

    return result;
  }
}
