/// Package imports
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_expense_list_area/bonus_expense_history_tile.dart';

/// Local imports
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_expense_history_value_provider.dart';

import 'package:kakeibo/view_model/state/update_DB_count.dart';

class BonusExpenseListArea extends ConsumerStatefulWidget {
  const BonusExpenseListArea({this.scrollController, super.key});

  final ScrollController? scrollController;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BonusExpenseListArea();
}

class _BonusExpenseListArea extends ConsumerState<BonusExpenseListArea> {
  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return ref.watch(resolvedBonusExpenseHistoryValueProvider).when(
          data: (valueList) {
            if (valueList.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.only(top: 16.0),
                controller: widget.scrollController,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(), // デフォルトで「必要なときだけスクロール」
                itemCount: valueList.length,
                itemBuilder: (context, index) {
                  return BonusExpenseHistoryTile(value: valueList[index]);
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
