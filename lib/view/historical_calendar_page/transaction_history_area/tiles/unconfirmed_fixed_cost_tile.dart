import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_expense/fixed_cost_expense_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/tile_parts/price_input_dialog.dart';

class UnconfirmedFixedCostTile extends ConsumerWidget {
  const UnconfirmedFixedCostTile({
    super.key,
    required this.value,
    required this.leftsidePadding,
    required this.screenHorizontalMagnification,
  });

  final MonthlyUnconfirmedFixedCostTileValue value;
  final double leftsidePadding;
  final double screenHorizontalMagnification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 平均金額と頻度の表示
    final frequencyWithAverage = value.variable == 1 && value.estimatedPrice > 0
        ? '平均 ${yenmarkFormattedPriceGetter(value.estimatedPrice)} / ${value.frequencyLabel}'
        : value.frequencyLabel;

    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      color: MyColors.transparent,
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
      onTap: () async {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return PriceInputDialog(value: value);
            });
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: leftsidePadding,
            ),
            child: SizedBox(
              height: 49,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 名前
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value.name,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: MyColors.label,
                          ),
                        ),
                        Text(
                          frequencyWithAverage,
                          style: const TextStyle(
                            fontSize: 12,
                            color: MyColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 未入力
                  const Padding(
                    padding: EdgeInsets.only(right: 22.0),
                    child: Text(
                      '未入力',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 15,
                        color: MyColors.red, // 目立たせる
                      ),
                    ),
                  ),
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
