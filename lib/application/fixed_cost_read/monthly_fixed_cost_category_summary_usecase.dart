import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_tile_service.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_sammary_value/monthly_fixed_cost_category_summary_value/monthly_fixed_cost_category_summary_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// カテゴリー別の固定費サマリー情報を取得するユースケース
// グルーピングの単位は支出大カテゴリー（v10で固定費カテゴリーから変更。仕様 §8.3）

final monthlyFixedCostCategorySummaryNotifierProvider = AsyncNotifierProvider
    .family<MonthlyFixedCostCategorySummaryNotifier,
        List<MonthlyFixedCostCategorySummaryValue>, PeriodValue>(
  MonthlyFixedCostCategorySummaryNotifier.new,
);

class MonthlyFixedCostCategorySummaryNotifier extends FamilyAsyncNotifier<
    List<MonthlyFixedCostCategorySummaryValue>, PeriodValue> {
  @override
  Future<List<MonthlyFixedCostCategorySummaryValue>> build(
      PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    final entries = await ref
        .read(monthlyFixedCostTileServiceProvider)
        .fetchEntries(period: selectedMonthPeriod);

    // 支出大カテゴリーidごとにグループ化（出現順を保つ）
    final Map<int, List<MonthlyFixedCostTileEntry>> categoryMap = {};
    for (var entry in entries) {
      categoryMap.putIfAbsent(entry.expenseBigCategoryId, () => []).add(entry);
    }

    // カテゴリーごとにサマリーを作成
    final List<MonthlyFixedCostCategorySummaryValue> result = [];

    for (var mapEntry in categoryMap.entries) {
      final items = mapEntry.value;

      // 確定済みかどうかと合計金額を計算
      bool isAllConfirmed = true;
      int totalAmount = 0;

      for (var item in items) {
        if (!item.isConfirmed) {
          isAllConfirmed = false;
        }
        // 未確定分は予想額で合算する（実効金額。仕様 §7.1）
        totalAmount += item.amount;
      }

      result.add(
        MonthlyFixedCostCategorySummaryValue(
          // 支出大カテゴリーid（フィールド名の変更はT5）
          fixedCostCategoryId: mapEntry.key,
          categoryName: items.first.bigCategoryName,
          colorCode: items.first.colorCode,
          resourcePath: items.first.resourcePath,
          isAllConfirmed: isAllConfirmed,
          totalAmount: totalAmount,
        ),
      );
    }

    return result;
  }
}
