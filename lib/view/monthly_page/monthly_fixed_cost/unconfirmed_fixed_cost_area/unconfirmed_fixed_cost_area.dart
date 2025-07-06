/// Package imports
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/unconfirmed_fixed_cost_area/unconfirmed_fixed_cost_tile.dart';

/// Local imports
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class UnconfirmedFixedCostListArea extends ConsumerStatefulWidget {
  const UnconfirmedFixedCostListArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConfirmedFixedCostListAreaState();
}

class _ConfirmedFixedCostListAreaState extends ConsumerState<UnconfirmedFixedCostListArea> {
  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return ref.watch(resolvedUnconfirmedFixedCostValueValueProvider).when(
          data: (valueList) {
            if (valueList.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8.0, 16.0, 0),
                shrinkWrap: true,
                itemCount: valueList.length,
                itemBuilder: (context, index) {
                  return UnconfirmedFixedCostTile(value: valueList[index]);
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
