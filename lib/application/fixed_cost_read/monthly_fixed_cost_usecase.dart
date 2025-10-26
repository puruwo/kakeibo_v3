import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
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
  late FixedCostExpenseRepository _fixedCostExpenseRepo;
  late FixedCostCategoryRepository _fixedCostCategoryRepo;
  late FixedCostRepository _fixedCostRepo;

  @override
  Future<List<MonthlyConfirmedFixedCostTileValue>> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _fixedCostExpenseRepo = ref.read(fixedCostExpenseRepositoryProvider);
    _fixedCostCategoryRepo = ref.read(fixedCostCategoryRepositoryProvider);
    _fixedCostRepo = ref.read(fixedCostRepositoryProvider);

    // fixed_cost_expenseから確定済み固定費の支出を取得する
    final fixedCostExpenseList = await _fixedCostExpenseRepo.fetchByPeriod(
      period: selectedMonthPeriod,
    );

    // 返却する結果のリスト
    final values = <MonthlyConfirmedFixedCostTileValue>[];

    for (var fixedCostExpense in fixedCostExpenseList) {
      final fixedCostEntity = await _fixedCostRepo.fetch(
          fixedCostId: fixedCostExpense.fixedCostId);
      // 確定済みのもののみ処理
      if (fixedCostExpense.isConfirmed == 1) {
        final category = await _fixedCostCategoryRepo.fetch(
            id: fixedCostExpense.fixedCostCategoryId);

        // 支払い頻度のラベルを取得するために、valueを生成
        final PaymentFrequencyValue frequencyValue =
            PaymentFrequencyValue.fromDB(
                intervalNumber: fixedCostEntity.intervalNumber,
                intervalUnitNumber: fixedCostEntity.intervalUnit);

        // 固定費の詳細情報は現在のアーキテクチャでは取得できないため、
        // 簡略化した情報のみ表示
        values.add(
          MonthlyConfirmedFixedCostTileValue(
              id: fixedCostExpense.id,
              date: DateTime.parse(
                  '${fixedCostExpense.date.substring(0, 4)}-${fixedCostExpense.date.substring(4, 6)}-${fixedCostExpense.date.substring(6, 8)}'),
              price: fixedCostExpense.price,
              name: fixedCostExpense.name,
              variable: fixedCostEntity.variable,
              intervalNumber: fixedCostEntity.intervalNumber,
              intervalUnit: fixedCostEntity.intervalUnit,
              nextPaymentDate: fixedCostEntity.nextPaymentDate,
              categoryName: category.categoryName,
              colorCode: category.colorCode,
              resourcePath: category.resourcePath,
              frequencyLabel: frequencyValue.dateLabel),
        );
      }
    }

    return values;
  }
}
