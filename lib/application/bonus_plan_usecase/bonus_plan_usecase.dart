import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/bonus_plan_value/bonus_plan_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final bonusPlanNotifierProvider = AsyncNotifierProvider.family<
    BonusPlanUsecaseNotifier, BonusPlanValue, PeriodValue>(
  BonusPlanUsecaseNotifier.new,
);

// yearlyPageのボーナスタイルのデータを取得するユースケース
class BonusPlanUsecaseNotifier
    extends FamilyAsyncNotifier<BonusPlanValue, PeriodValue> {
  late IncomeRepository _incomeRepository;
  late ExpenseRepository _expenseRepository;

  @override
  Future<BonusPlanValue> build(PeriodValue selectedYearPeriod) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _incomeRepository = ref.read(incomeRepositoryProvider);

    _expenseRepository = ref.read(expenseRepositoryProvider);

    return fetch(selectedYearPeriod: selectedYearPeriod);
  }

  Future<BonusPlanValue> fetch(
      {required PeriodValue selectedYearPeriod}) async {

    // カテゴリーIDを1で指定することで、ボーナス収入の合計を取得する
    final yearlyBonusIncome =
        await _incomeRepository.calcurateSumWithBigCategoryAndPeriod(
            period: selectedYearPeriod, bigCategoryId: 1);

    // カテゴリーIDを1で指定することで、ボーナス分の支出の合計を取得する
    final yearlyBonusExpense =
        await _expenseRepository.fetchTotalExpenseByPeriodWithBigCategory(
            incomeSourceBigCategory: IncomeBigCategoryConstants.incomeSourceIdBonus,
            fromDate: selectedYearPeriod.startDatetime,
            toDate: selectedYearPeriod.endDatetime);

    // 予定貯金を計算
    final lastBonusPrice = yearlyBonusIncome - yearlyBonusExpense;

    return BonusPlanValue(
      yearlyBonusExpense: yearlyBonusExpense,
      yearlyBonusIncome: yearlyBonusIncome,
      lastBonusPrice: lastBonusPrice,
    );
  }
}
