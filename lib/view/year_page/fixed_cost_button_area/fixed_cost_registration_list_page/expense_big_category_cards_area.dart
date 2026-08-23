import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/ui_value/fixed_cost_registration_list_value/fixed_cost_registration_list_entity.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/tile_parts/expense_big_category_header.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_item_tile.dart';

class ExpenseBigCategoryCardsArea extends StatelessWidget {
  const ExpenseBigCategoryCardsArea({super.key, required this.group});

  final ExpenseBigCategoryGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カテゴリーヘッダー（アイコン + 名前）
          ExpenseBigCategoryHeader(
            categoryName: group.categoryName,
            colorCode: group.categoryColorCode,
            resourcePath: group.categoryIconPath,
          ),
          // 固定費アイテムのリスト
          Column(
            children: [
              for (int i = 0; i < group.items.length; i++)
                FixedCostItemTile(item: group.items[i]),
            ],
          ),
        ],
      ),
    );
  }
}
