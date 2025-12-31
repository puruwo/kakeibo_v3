import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/application/fixed_cost_expense/fixed_cost_expense_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';

class ConfirmedFixedCostItemTile extends ConsumerWidget {
  const ConfirmedFixedCostItemTile({
    super.key,
    required this.value,
    required this.leftsidePadding,
    required this.screenHorizontalMagnification,
  });

  final MonthlyConfirmedFixedCostTileValue value;
  final double leftsidePadding;
  final double screenHorizontalMagnification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = MyColors().getColorFromHex(value.colorCode);

    // アイコン
    final icon = FittedBox(
      fit: BoxFit.scaleDown,
      child: SvgPicture.asset(
        value.resourcePath,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        semanticsLabel: 'categoryIcon',
        width: 25,
        height: 25,
      ),
    );
    // 値段ラベル
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      onLongPress: () async {
        return await showMenuDialog(context, items: [
          MenuDialogItem(
              label: '削除',
              icon: Icons.delete_outline,
              onPressed: () async {
                showDeleteConfirmationDialog(
                  context,
                  onConfirm: () {
                    ref
                        .read(fixedCostExpenseUsecaseProvider)
                        .delete(id: value.id);
                  },
                );
              }),
        ]);
      },
      child: Column(
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
                        // 固定費名（小カテゴリー的に表示）
                        SizedBox(
                          width: 153 * screenHorizontalMagnification,
                          child: Text(
                            value.name,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: MyFonts.historyTileBigCategoryLabel,
                          ),
                        ),
                        // 固定費（確定済み）ラベル
                        SizedBox(
                          width: 153 * screenHorizontalMagnification,
                          child: const Text(
                            '固定費',
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: MyFonts.historyTileSubLabel,
                          ),
                        ),
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
                        style: MyFonts.historyTilePriceLabel,
                      ),
                    ),
                  ),

                  // nextArrowアイコン
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
      ),
    );
  }
}
