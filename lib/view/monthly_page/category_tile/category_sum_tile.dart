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
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/category_expense_hisotry_page.dart';
import 'package:kakeibo/view/monthly_page/category_tile/category_sum_graph.dart';
import 'package:kakeibo/view/monthly_page/category_tile/category_sum_text.dart';
import 'package:kakeibo/view/monthly_page/category_tile/price_label.dart';

class CategorySumTile extends HookConsumerWidget {
  const CategorySumTile({required this.categoryTile, super.key});
  final CategoryCardEntity categoryTile;

  int get budget => categoryTile.monthlyBudget;
  CategoryAccountingEntity get monthlyExpenseByCategoryEntity =>
      categoryTile.monthlyExpenseByCategoryEntity;
  List<SmallCategoryTileEntity> get smallCategoryEntity =>
      categoryTile.smallCategoryList;

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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CategorySumText(categoryTile: categoryTile),
                          PriceLabel(categoryTile: categoryTile),
                        ],
                      ),
                      LayoutBuilder(
                          builder: ((context, constraints) => CategorySumGraph(
                              barFrameMaxWidth: constraints.maxWidth,
                              categoryTile: categoryTile))),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                MyIcon.next,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
