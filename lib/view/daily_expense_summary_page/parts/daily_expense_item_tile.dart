import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/styles/history_list_styles.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/util/util.dart';

/// 日別支出サマリーページ用の支出タイル（表示のみ）
class DailyExpenseItemTile extends StatelessWidget {
  const DailyExpenseItemTile({
    super.key,
    required this.value,
    required this.leftsidePadding,
    required this.listSmallcategoryMemoOffset,
    required this.screenHorizontalMagnification,
  });

  final ExpenseHistoryTileValue value;
  final double leftsidePadding;
  final double listSmallcategoryMemoOffset;
  final double screenHorizontalMagnification;

  @override
  Widget build(BuildContext context) {
    final color = MyColors().getColorFromHex(value.colorCode);

    // アイコン
    final icon = FittedBox(
      fit: BoxFit.scaleDown,
      child: SvgPicture.asset(
        value.iconPath,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        semanticsLabel: 'categoryIcon',
        width: 25,
        height: 25,
      ),
    );

    // 値段ラベル
    final priceLabel =
        value.price == 0 ? '未確定' : yenmarkFormattedPriceGetter(value.price);

    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: leftsidePadding, right: leftsidePadding),
          child: SizedBox(
            height: 49,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // アイコン
                SizedBox(height: 49, width: 49, child: icon),

                // 大カテゴリー、小カテゴリーのColumn
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 大カテゴリー
                      SizedBox(
                        width: 153 * screenHorizontalMagnification,
                        child: Text(
                          value.bigCategoryName,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: HistoryListStyles.historyTileBigCategoryLabel,
                        ),
                      ),

                      // 小カテゴリーとメモ
                      Row(
                        children: [
                          // 小カテゴリー
                          SizedBox(
                            width: 56,
                            child: Text(
                              ' ${value.smallCategoryName}',
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: HistoryListStyles.historyTileSubLabel,
                            ),
                          ),
                          // メモ
                          SizedBox(
                            width: 90 + listSmallcategoryMemoOffset,
                            child: Text(
                              ' ${value.memo}',
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: HistoryListStyles.historyTileSubLabel,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // 値段
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: SizedBox(
                    width: 100,
                    child: Text(
                      priceLabel,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: HistoryListStyles.historyTilePriceLabel,
                    ),
                  ),
                ),

                // マイナスアイコン（支出を示す）
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    size: 18,
                    Icons.remove,
                    color: MyColors.pink,
                  ),
                )
              ],
            ),
          ),
        ),
        Divider(
          thickness: 0.25,
          height: 0.25,
          indent: 50 + leftsidePadding,
          endIndent: leftsidePadding,
          color: MyColors.separater,
        )
      ],
    );
  }
}
