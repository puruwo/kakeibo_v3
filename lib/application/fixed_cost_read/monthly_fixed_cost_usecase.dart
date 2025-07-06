import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_service.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';

import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 月の確定分固定費を取得するユースケース

final monthlyFixedCostNotifierProvider = AsyncNotifierProvider.family<
    MonthlyFixedCostUsecaseNotifier,
    List<MonthlyConfirmedFixedCostTileValue>,
    PeriodValue>(
  MonthlyFixedCostUsecaseNotifier.new,
);

class MonthlyFixedCostUsecaseNotifier extends FamilyAsyncNotifier<
    List<MonthlyConfirmedFixedCostTileValue>, PeriodValue> {
  late ExpenseRepository _expenseRepo;
  late ExpenseSmallCategoryRepository _smallCategoryRepo;
  late ExpenseBigCategoryRepository _bigCategoryRepo;
  late FixedCostRepository _fixedCostRepo;

  @override
  Future<List<MonthlyConfirmedFixedCostTileValue>> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _expenseRepo = ref.read(expenseRepositoryProvider);
    _smallCategoryRepo = ref.read(expenseSmallCategoryRepositoryProvider);
    _bigCategoryRepo = ref.read(expensebigCategoryRepositoryProvider);
    _fixedCostRepo = ref.read(fixedCostRepositoryProvider);

    // expenseから固定費の支出を取得する
    final expenseList = await _expenseRepo.fetchFixedCostByPeriod(
      period: selectedMonthPeriod,
    );

    // 返却する結果のリスト
    final values = <MonthlyConfirmedFixedCostTileValue>[];

    for (var expense in expenseList) {
      final small = await _smallCategoryRepo.fetchBySmallCategory(
          smallCategoryId: expense.paymentCategoryId);
      final big = await _bigCategoryRepo.fetchByBigCategory(
          bigCategoryId: small.bigCategoryKey);
      final fixedCostEntity =
          await _fixedCostRepo.fetch(fixedCostId: expense.fixedCostId!);

      final frequencyLabel =
          MonthlyFixedCostService().frequencyLabelGetter(fixedCostEntity);

      values.add(
        MonthlyConfirmedFixedCostTileValue(
            id: expense.id,
            date: DateTime.parse(
                '${expense.date.substring(0, 4)}-${expense.date.substring(4, 6)}-${expense.date.substring(6, 8)}'),
            price: expense.price,
            name: expense.memo,
            variable: fixedCostEntity.variable,
            intervalNumber: fixedCostEntity.intervalNumber,
            intervalUnit: fixedCostEntity.intervalUnit,
            nextPaymentDate: fixedCostEntity.nextPaymentDate,
            smallCategoryName: small.smallCategoryName,
            bigCategoryName: big.bigCategoryName,
            colorCode: big.colorCode,
            resourcePath: big.resourcePath,
            frequencyLabel: frequencyLabel),
      );
    }

    return values;
  }
}
