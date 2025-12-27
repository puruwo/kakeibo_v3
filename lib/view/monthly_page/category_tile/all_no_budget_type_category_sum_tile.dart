import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/category_tile/all_no_budget_type_price_label.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/category_expense_hisotry_page.dart';
import 'package:kakeibo/view/monthly_page/category_tile/category_sum_graph.dart';
import 'package:kakeibo/view/monthly_page/category_tile/category_sum_text.dart';

class AllNoBudgetTypeCategorySumTile extends HookConsumerWidget {
  const AllNoBudgetTypeCategorySumTile({required this.categoryTile, super.key});
  final CategoryCardEntity categoryTile;

  int get budget => categoryTile.monthlyBudget;
  CategoryAccountingEntity get monthlyExpenseByCategoryEntity =>
      categoryTile.monthlyExpenseByCategoryEntity;
  List<SmallCategoryTileEntity> get smallCategoryEntity =>
      categoryTile.smallCategoryList;

  static const double priceLabelWidth = 100.0;
  static const double gapBetweenLabelAndIcon = 12.0;
  static const double gapBetweenGraphAndLabel = 12.0;
  // iconWidthはiconのサイズ決定には利用していない
  static const double iconWidth = 15.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppInkWell(
      color: MyColors.quarternarySystemfill,
      borderRadius: appCardRadius,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CategoryExpenseHistoryPage(
              bigId: monthlyExpenseByCategoryEntity.id),
        ));
      },
      child: SizedBox(
        width: 343 * context.screenHorizontalMagnification,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            listTileTheme: ListTileTheme.of(context).copyWith(
              titleAlignment: ListTileTitleAlignment.center,
              horizontalTitleGap: 0,
              minVerticalPadding: 0,
              dense: true,
            ),
          ),
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CategorySumText(categoryTile: categoryTile),
                          CategorySumGraph(
                            barFrameMaxWidth: constraints.maxWidth -
                                priceLabelWidth -
                                gapBetweenLabelAndIcon -
                                gapBetweenGraphAndLabel -
                                iconWidth,
                            categoryTile: categoryTile,
                          ),
                        ],
                      ),
                    ),
                    AllNoBudgetTypePriceLabel(
                      gapBetweenGraphAndLabel: gapBetweenGraphAndLabel,
                      width: priceLabelWidth,
                      categoryTile: categoryTile,
                    ),
                    const SizedBox(
                      width: gapBetweenLabelAndIcon,
                    ),
                    MyIcon.next,
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
