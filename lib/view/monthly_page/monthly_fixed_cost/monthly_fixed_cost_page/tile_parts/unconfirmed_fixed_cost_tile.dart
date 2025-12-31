import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_expense/fixed_cost_expense_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/tile_parts/price_input_dialog.dart';

class UnconfirmedFixedCostTile extends ConsumerWidget {
  const UnconfirmedFixedCostTile({
    super.key,
    required this.value,
  });

  final MonthlyUnconfirmedFixedCostTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面の倍率を計算
    final screenHorizontalMagnification = context.screenHorizontalMagnification;

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

    // 支払い日のフォーマット
    final paymentDateLabel =
        '${value.date.year}/${value.date.month}/${value.date.day}';

    // 平均金額と頻度の表示（変動固定費の場合のみ平均を表示）
    final frequencyWithAverage = value.variable == 1 && value.estimatedPrice > 0
        ? '平均 ${yenmarkFormattedPriceGetter(value.estimatedPrice)} / ${value.frequencyLabel}'
        : value.frequencyLabel;

    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: AppInkWell(
          borderRadius: appCardRadius,
          color: MyColors.quarternarySystemfill,
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
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: leftsidePadding,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 上段：名前と「未入力」
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 名前
                    Expanded(
                      child: Text(
                        value.name,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardPrimaryTitle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 未入力
                    Text(
                      '未入力',
                      textAlign: TextAlign.end,
                      style: AppTextStyles.cardPriceLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 下段：日付と頻度（平均金額含む）
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 日付
                    Text(
                      paymentDateLabel,
                      style: AppTextStyles.cardSecondaryTitle,
                    ),
                    // 頻度（変動固定費の場合は平均金額も含む）
                    Text(
                      frequencyWithAverage,
                      style: AppTextStyles.cardSecondaryTitle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PriceInputDialog(value: value);
                });
          },
        ));
  }
}
