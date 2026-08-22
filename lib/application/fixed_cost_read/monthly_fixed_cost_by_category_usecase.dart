import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_tile_service.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/i_monthly_fixed_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_fixed_cost_by_category_group/monthly_fixed_cost_by_category_group.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// カテゴリー別にグルーピングされた固定費を取得するユースケース
// グルーピングの単位は支出大カテゴリー（v10で固定費カテゴリーから変更。仕様 §8.3）

final monthlyFixedCostByCategoryNotifierProvider = AsyncNotifierProvider.family<
    MonthlyFixedCostByCategoryUsecaseNotifier,
    List<MonthlyFixedCostByCategoryGroup>,
    PeriodValue>(
  MonthlyFixedCostByCategoryUsecaseNotifier.new,
);

class MonthlyFixedCostByCategoryUsecaseNotifier extends FamilyAsyncNotifier<
    List<MonthlyFixedCostByCategoryGroup>, PeriodValue> {
  @override
  Future<List<MonthlyFixedCostByCategoryGroup>> build(
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

    // カテゴリーごとにグループ化したリストを作成
    final List<MonthlyFixedCostByCategoryGroup> result = [];

    for (var mapEntry in categoryMap.entries) {
      final items = mapEntry.value;
      final List<IMonthlyFixedTileValue> tiles =
          items.map((e) => e.tile).toList();

      result.add(
        MonthlyFixedCostByCategoryGroup(
          expenseBigCategoryId: mapEntry.key,
          categoryName: items.first.bigCategoryName,
          colorCode: items.first.colorCode,
          resourcePath: items.first.resourcePath,
          items: tiles,
        ),
      );
    }

    return result;
  }
}
