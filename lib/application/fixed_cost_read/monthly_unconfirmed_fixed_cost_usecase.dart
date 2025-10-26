import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 月の確定分固定費を取得するユースケース

final monthlyUnconfirmedFixedCostNotifierProvider =
    AsyncNotifierProvider.family<MonthlyUnconfirmedFixedCostUsecaseNotifier,
        List<MonthlyUnconfirmedFixedCostTileValue>, PeriodValue>(
  MonthlyUnconfirmedFixedCostUsecaseNotifier.new,
);

class MonthlyUnconfirmedFixedCostUsecaseNotifier extends FamilyAsyncNotifier<
    List<MonthlyUnconfirmedFixedCostTileValue>, PeriodValue> {
  late FixedCostExpenseRepository _fixedCostExpenseRepo;
  late FixedCostCategoryRepository _fixedCostCategoryRepo;
  late FixedCostRepository _fixedCostRepo;

  @override
  Future<List<MonthlyUnconfirmedFixedCostTileValue>> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _fixedCostExpenseRepo = ref.read(fixedCostExpenseRepositoryProvider);
    _fixedCostCategoryRepo = ref.read(fixedCostCategoryRepositoryProvider);
    _fixedCostRepo = ref.read(fixedCostRepositoryProvider);

    // fixed_cost_expenseから未確定の固定費の支出を取得する
    final fixedCostExpenseList = await _fixedCostExpenseRepo.fetchByPeriod(
      period: selectedMonthPeriod,
    );

    // 返却する結果のリスト
    final values = <MonthlyUnconfirmedFixedCostTileValue>[];

    for (var fixedCostExpense in fixedCostExpenseList) {
      // 未確定のもののみ処理
      if (fixedCostExpense.isConfirmed == 0) {
        final category = await _fixedCostCategoryRepo.fetch(
            id: fixedCostExpense.fixedCostCategoryId);
        final fixedCostEntity = await _fixedCostRepo.fetch(
            fixedCostId: fixedCostExpense.fixedCostId);
        // 支払い頻度のラベルを取得するために、valueを生成
        final PaymentFrequencyValue frequencyValue =
            PaymentFrequencyValue.fromDB(
                intervalNumber: fixedCostEntity.intervalNumber,
                intervalUnitNumber: fixedCostEntity.intervalUnit);
        values.add(
          MonthlyUnconfirmedFixedCostTileValue(
            id: fixedCostExpense.id,
            date: DateTime.parse(
                '${fixedCostExpense.date.substring(0, 4)}-${fixedCostExpense.date.substring(4, 6)}-${fixedCostExpense.date.substring(6, 8)}'),
            fixedCostId: fixedCostExpense.id, // 固定費IDの代わりに固定費支出IDを使用
            name: fixedCostExpense.name,
            variable: fixedCostEntity.variable,
            estimatedPrice: fixedCostEntity.estimatedPrice,
            intervalNumber: fixedCostEntity.intervalNumber,
            intervalUnit: fixedCostEntity.intervalUnit,
            nextPaymentDate: fixedCostEntity.nextPaymentDate,
            categoryName: category.categoryName,
            colorCode: category.colorCode,
            resourcePath: category.resourcePath,
            frequencyLabel: frequencyValue.dateLabel,
          ),
        );
      }
    }

    return values;
  }
}
