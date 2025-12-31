/// Package imports
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// Local imports
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/income_list_area/income_history_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_income_history_value_provider.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class IncomeListArea extends ConsumerStatefulWidget {
  const IncomeListArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IncomeListAreaState();
}

class _IncomeListAreaState extends ConsumerState<IncomeListArea> {
  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return ref.watch(resolvedIncomeHistoryValueProvider).when(
          data: (valueList) {
            if (valueList.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8.0, 16.0, 0),
                shrinkWrap: true,
                itemCount: valueList.length,
                itemBuilder: (context, index) {
                  return IncomeHistoryTile(value: valueList[index]);
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
