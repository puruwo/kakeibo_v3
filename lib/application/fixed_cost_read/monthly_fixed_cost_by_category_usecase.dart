import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/i_monthly_fixed_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_fixed_cost_by_category_group/monthly_fixed_cost_by_category_group.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// カテゴリー別にグルーピングされた固定費を取得するユースケース

final monthlyFixedCostByCategoryNotifierProvider = AsyncNotifierProvider.family<
    MonthlyFixedCostByCategoryUsecaseNotifier,
    List<MonthlyFixedCostByCategoryGroup>,
    PeriodValue>(
  MonthlyFixedCostByCategoryUsecaseNotifier.new,
);

class MonthlyFixedCostByCategoryUsecaseNotifier extends FamilyAsyncNotifier<
    List<MonthlyFixedCostByCategoryGroup>, PeriodValue> {
  late FixedCostExpenseRepository _fixedCostExpenseRepo;
  late FixedCostCategoryRepository _fixedCostCategoryRepo;
  late FixedCostRepository _fixedCostRepo;

  @override
  Future<List<MonthlyFixedCostByCategoryGroup>> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _fixedCostExpenseRepo = ref.read(fixedCostExpenseRepositoryProvider);
    _fixedCostCategoryRepo = ref.read(fixedCostCategoryRepositoryProvider);
    _fixedCostRepo = ref.read(fixedCostRepositoryProvider);

    // fixed_cost_expenseから全ての固定費の支出を取得する
    final fixedCostExpenseList = await _fixedCostExpenseRepo.fetchByPeriod(
      period: selectedMonthPeriod,
    );

    // カテゴリーIDごとにグループ化するためのマップ
    final Map<int, List<IMonthlyFixedTileValue>> categoryMap = {};

    for (var fixedCostExpense in fixedCostExpenseList) {
      final fixedCostEntity = await _fixedCostRepo.fetch(
          fixedCostId: fixedCostExpense.fixedCostId);
      final category = await _fixedCostCategoryRepo.fetch(
          id: fixedCostExpense.fixedCostCategoryId);

      // 支払い頻度のラベルを取得するために、valueを生成
      final PaymentFrequencyValue frequencyValue =
          PaymentFrequencyValue.fromDB(
              intervalNumber: fixedCostEntity.intervalNumber,
              intervalUnitNumber: fixedCostEntity.intervalUnit);

      final categoryId = fixedCostExpense.fixedCostCategoryId;

      // カテゴリーマップに初期化
      if (!categoryMap.containsKey(categoryId)) {
        categoryMap[categoryId] = [];
      }

      // 確定済みの場合
      if (fixedCostExpense.isConfirmed == 1) {
        categoryMap[categoryId]!.add(
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
            frequencyLabel: frequencyValue.dateLabel,
          ),
        );
      } else {
        // 未確定の場合
        categoryMap[categoryId]!.add(
          MonthlyUnconfirmedFixedCostTileValue(
            id: fixedCostExpense.id,
            date: DateTime.parse(
                '${fixedCostExpense.date.substring(0, 4)}-${fixedCostExpense.date.substring(4, 6)}-${fixedCostExpense.date.substring(6, 8)}'),
            fixedCostId: fixedCostExpense.fixedCostId,
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

    // カテゴリーごとにグループ化したリストを作成
    final List<MonthlyFixedCostByCategoryGroup> result = [];

    for (var entry in categoryMap.entries) {
      final categoryId = entry.key;
      final items = entry.value;

      // カテゴリー情報を取得（最初のアイテムから取得可能）
      if (items.isNotEmpty) {
        final firstItem = items.first;
        result.add(
          MonthlyFixedCostByCategoryGroup(
            fixedCostCategoryId: categoryId,
            categoryName: firstItem.categoryName,
            colorCode: firstItem.colorCode,
            resourcePath: firstItem.resourcePath,
            items: items,
          ),
        );
      }
    }

    return result;
  }
}
