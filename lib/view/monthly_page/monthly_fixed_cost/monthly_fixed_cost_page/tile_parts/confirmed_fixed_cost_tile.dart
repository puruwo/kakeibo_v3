import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_expense/fixed_cost_expense_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';

class ConfirmedFixedCostTile extends ConsumerWidget {
  const ConfirmedFixedCostTile({
    super.key,
    required this.value,
  });

  final MonthlyConfirmedFixedCostTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面の倍率を計算
    final screenHorizontalMagnification = context.screenHorizontalMagnification;

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

    // 支払い日のフォーマット
    final paymentDateLabel =
        '${value.date.year}/${value.date.month}/${value.date.day}';

    // 値段ラベル
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppInkWell(
        borderRadius: appCardRadius,
        color: MyColors.quarternarySystemfill,
        onTap: () async {
          // 編集機能は将来実装
        },
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
              // 上段：名前と金額
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
                  // 値段
                  Text(
                    priceLabel,
                    textAlign: TextAlign.end,
                    style: AppTextStyles.cardPriceLabel,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 下段：日付と支払い頻度
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 日付
                  Text(
                    paymentDateLabel,
                    style: AppTextStyles.cardSecondaryTitle,
                  ),
                  // 支払い頻度
                  Text(
                    value.frequencyLabel,
                    style: AppTextStyles.cardSecondaryTitle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
