import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 月の確定分固定費を取得するユースケース

final monthlyUnconfirmedFixedCostNotifierProvider = AsyncNotifierProvider.family<
    MonthlyUnconfirmedFixedCostUsecaseNotifier, List<MonthlyUnconfirmedFixedCostTileValue>, PeriodValue>(
  MonthlyUnconfirmedFixedCostUsecaseNotifier.new,
);

class MonthlyUnconfirmedFixedCostUsecaseNotifier
    extends FamilyAsyncNotifier<List<MonthlyUnconfirmedFixedCostTileValue>, PeriodValue> {
  late ExpenseRepository _expenseRepo;
  late ExpenseSmallCategoryRepository _smallCategoryRepo;
  late ExpenseBigCategoryRepository _bigCategoryRepo;
  late FixedCostRepository _fixedCostRepo;

  @override
  Future<List<MonthlyUnconfirmedFixedCostTileValue>> build(PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _expenseRepo = ref.read(expenseRepositoryProvider);
    _smallCategoryRepo = ref.read(expenseSmallCategoryRepositoryProvider);
    _bigCategoryRepo = ref.read(expensebigCategoryRepositoryProvider);
    _fixedCostRepo = ref.read(fixedCostRepositoryProvider);

    // expenseから固定費の支出を取得する
    final expenseList = await _expenseRepo.fetchUnconfirmedFixedCostByPeriod(
      period: selectedMonthPeriod,
    );

    // 返却する結果のリスト
    final values = <MonthlyUnconfirmedFixedCostTileValue>[];

    for (var expense in expenseList) {
      final small = await _smallCategoryRepo.fetchBySmallCategory(
          smallCategoryId: expense.paymentCategoryId);
      final big = await _bigCategoryRepo.fetchByBigCategory(
          bigCategoryId: small.bigCategoryKey);
      final fixedCostEntity = await _fixedCostRepo.fetch(
          fixedCostId: expense.fixedCostId!);

      // 支払い頻度のラベルを取得するために、valueを生成
      final PaymentFrequencyValue frequencyValue =
          PaymentFrequencyValue.fromDB(
              intervalNumber: fixedCostEntity.intervalNumber,
              intervalUnitNumber: fixedCostEntity.intervalUnit);

      values.add(
        MonthlyUnconfirmedFixedCostTileValue(
          id: expense.id,
          date: DateTime.parse(
              '${expense.date.substring(0, 4)}-${expense.date.substring(4, 6)}-${expense.date.substring(6, 8)}'),
          name: expense.memo,
          variable: fixedCostEntity.variable,
          intervalNumber: fixedCostEntity.intervalNumber,
          intervalUnit: fixedCostEntity.intervalUnit,
          nextPaymentDate: fixedCostEntity.nextPaymentDate,
          smallCategoryName: small.smallCategoryName,
          bigCategoryName: big.bigCategoryName,
          colorCode: big.colorCode,
          resourcePath: big.resourcePath,
          frequencyLabel: frequencyValue.dateLabel,
        ),
      );
    }

    return values;
  }
}
