import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/budget_setting_page/budget_category_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_budget_provider.dart';

class BudgetCategoryArea extends ConsumerWidget {
  const BudgetCategoryArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(leftsidePadding, 8, leftsidePadding, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Text(
                  'カテゴリー',
                  style: BudgetSettingsStyles.columnHeaderLabel,
                ),
              ),
              Row(
                children: [
                  Text(
                    '先月の支出',
                    style: BudgetSettingsStyles.columnHeaderLabel,
                  ),
                  SizedBox(
                    width: 123,
                    child: Text(
                      '今月の予算',
                      textAlign: TextAlign.right,
                      style: BudgetSettingsStyles.columnHeaderLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //区切り線
        Divider(
          thickness: 0.25,
          height: 0.25,
          indent: leftsidePadding,
          endIndent: leftsidePadding,
          color: MyColors.separater,
        ),

        // リスト部分
        ref.watch(resolvedBudgetEditValueProvider).when(data: (valueList) {
          return Expanded(
            child: ListView.builder(
              itemCount: valueList.length,
              itemBuilder: (BuildContext context, int i) {
                return BudgetCategoryTile(budgetEditValue: valueList[i]);
              },
            ),
          );
        }, error: (Object error, StackTrace stackTrace) {
          return const Text('エラーが発生しました');
        }, loading: () {
          return const CircularProgressIndicator();
        }),
      ],
    );
  }
}
