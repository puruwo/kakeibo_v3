import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_list_card.dart';

/// 日別支出サマリーページ用の支出タイル（表示のみ）
class DailyExpenseItemTile extends StatelessWidget {
  const DailyExpenseItemTile({
    super.key,
    required this.value,
  });

  final ExpenseHistoryTileValue value;

  @override
  Widget build(BuildContext context) {
    final color = MyColors().getColorFromHex(value.colorCode);
    final priceLabel =
        value.price == 0 ? '未確定' : yenmarkFormattedPriceGetter(value.price);

    return AppListCard(
      iconPath: value.iconPath,
      iconColor: color,
      primaryTitle: value.bigCategoryName,
      secondaryTitle: value.smallCategoryName,
      subtitleLeading: value.memo,
      priceLabel: priceLabel,
      isIncome: false,
    );
  }
}
