/// Package imports
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/tile_parts/confirmed_fixed_cost_tile.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/tile_parts/unconfirmed_fixed_cost_tile.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/tile_parts/fixed_cost_category_header.dart';

/// Local imports
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_by_category_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_fixed_cost_by_category_group/monthly_fixed_cost_by_category_group.dart';

// 選択期間を取得し、カテゴリー別固定費のValuesを取得する中間プロバイダ
final resolvedFixedCostByCategoryProvider =
    FutureProvider<List<MonthlyFixedCostByCategoryGroup>>((ref) async {
  // 選択された日付から集計期間を取得する
  final monthPeriod = await ref.watch(analyzePageDateScopeEntityProvider
      .selectAsync((data) => data.monthPeriod));

  // 選択された集計期間を元に、Valuesを取得する
  final values =
      ref.watch(monthlyFixedCostByCategoryNotifierProvider(monthPeriod).future);
  return values;
});

class FixedCostByCategoryListArea extends ConsumerStatefulWidget {
  const FixedCostByCategoryListArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FixedCostByCategoryListAreaState();
}

class _FixedCostByCategoryListAreaState
    extends ConsumerState<FixedCostByCategoryListArea> {
  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return ref.watch(resolvedFixedCostByCategoryProvider).when(
          data: (categoryGroups) {
            if (categoryGroups.isNotEmpty) {
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: categoryGroups.length,
                itemBuilder: (context, groupIndex) {
                  final group = categoryGroups[groupIndex];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // カテゴリーヘッダー
                      FixedCostCategoryHeader(
                        categoryName: group.categoryName,
                        colorCode: group.colorCode,
                        resourcePath: group.resourcePath,
                      ),
                      // カテゴリー内の固定費カード
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: group.items.length,
                        itemBuilder: (context, itemIndex) {
                          final item = group.items[itemIndex];
                          // 確定済みか未確定かで表示するタイルを変える
                          if (item is MonthlyConfirmedFixedCostTileValue) {
                            return ConfirmedFixedCostTile(value: item);
                          } else if (item
                              is MonthlyUnconfirmedFixedCostTileValue) {
                            return UnconfirmedFixedCostTile(value: item);
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              return const Center(
                child: Text(
                  '記録がまだありません',
                  style:
                      TextStyle(color: MyColors.secondaryLabel, fontSize: 16),
                ),
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
        );
  }
}
