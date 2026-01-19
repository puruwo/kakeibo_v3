import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_list_card.dart';

/// 日別支出サマリーページ用の固定費（確定）タイル（表示のみ）
class DailyConfirmedFixedCostItemTile extends StatelessWidget {
  const DailyConfirmedFixedCostItemTile({
    super.key,
    required this.value,
  });

  final MonthlyConfirmedFixedCostTileValue value;

  @override
  Widget build(BuildContext context) {
    final color = MyColors().getColorFromHex(value.colorCode);
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return AppListCard(
      iconPath: value.resourcePath,
      iconColor: color,
      primaryTitle: value.name,
      subtitleLeading: '固定費',
      priceLabel: priceLabel,
      isIncome: false,
    );
  }
}

/// 日別支出サマリーページ用の固定費（未確定）タイル（表示のみ）
class DailyUnconfirmedFixedCostItemTile extends StatelessWidget {
  const DailyUnconfirmedFixedCostItemTile({
    super.key,
    required this.value,
  });

  final MonthlyUnconfirmedFixedCostTileValue value;

  @override
  Widget build(BuildContext context) {
    final color = MyColors().getColorFromHex(value.colorCode);
    final priceLabel = value.estimatedPrice == 0
        ? '未確定'
        : yenmarkFormattedPriceGetter(value.estimatedPrice);

    return AppListCard(
      iconPath: value.resourcePath,
      iconColor: color,
      primaryTitle: value.name,
      subtitleLeading: '固定費(未確定)',
      priceLabel: priceLabel,
      isIncome: false,
    );
  }
}
