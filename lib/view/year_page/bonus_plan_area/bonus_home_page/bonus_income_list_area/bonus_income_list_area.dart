/// Package imports
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_income_list_area/bonus_income_history_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_income_history_value_provider.dart';

import 'package:kakeibo/view_model/state/update_DB_count.dart';

class BonusIncomeListArea extends ConsumerStatefulWidget {
  const BonusIncomeListArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BonusIncomeListAreaState();
}

class _BonusIncomeListAreaState extends ConsumerState<BonusIncomeListArea> {
  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return ref.watch(resolvedBonusIncomeHistoryValueProvider).when(
          data: (valueList) {
            if (valueList.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8.0, 16.0, 0),
                shrinkWrap: true,
                itemCount: valueList.length,
                itemBuilder: (context, index) {
                  return BonusIncomeHistoryTile(value: valueList[index]);
                },
              );
            } else {
              return Center(
                child: Text(
                  '記録がまだありません',
                  style: AppTextStyles.listEmptyMessage,
                ),
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
        );
  }
}
