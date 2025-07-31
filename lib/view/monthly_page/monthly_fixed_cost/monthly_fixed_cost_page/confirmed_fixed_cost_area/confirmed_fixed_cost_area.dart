/// Package imports
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/confirmed_fixed_cost_area/confirmed_fixed_cost_tile.dart';

/// Local imports
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class ConfirmedFixedCostListArea extends ConsumerStatefulWidget {
  const ConfirmedFixedCostListArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConfirmedFixedCostListAreaState();
}

class _ConfirmedFixedCostListAreaState extends ConsumerState<ConfirmedFixedCostListArea> {
  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return ref.watch(resolvedConfirmedFixedCostValueValueProvider).when(
          data: (valueList) {
            if (valueList.isNotEmpty) {
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: valueList.length,
                itemBuilder: (context, index) {
                  return ConfirmedFixedCostTile(value: valueList[index]);
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
