import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_expense/fixed_cost_expense_usecase.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/history_list_tile.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/tile_parts/price_input_dialog.dart';

class UnconfirmedFixedCostTile extends ConsumerWidget {
  const UnconfirmedFixedCostTile({
    super.key,
    required this.value,
  });

  final MonthlyUnconfirmedFixedCostTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 支払い日のフォーマット
    final paymentDateLabel =
        '${value.date.year}/${value.date.month}/${value.date.day}';

    return HistoryListTile(
      primaryTitle: value.name,
      subtitleLeading: paymentDateLabel,
      priceLabel: '未入力',
      isIncome: false,
      customUnderPriceLabel:
          '平均 ${yenmarkFormattedPriceGetter(value.estimatedPrice)} / ${value.frequencyLabel}',
      onTap: () async {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return PriceInputDialog(value: value);
            });
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
    );
  }
}
