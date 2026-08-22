import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_expense/fixed_cost_expense_usecase.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/view/register_page/expense_tab/open_fixed_cost_expense_edit_sheet.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_list_card.dart';

class DailyConfirmedFixedCostItemTile extends ConsumerWidget {
  const DailyConfirmedFixedCostItemTile({
    super.key,
    required this.value,
  });

  final MonthlyConfirmedFixedCostTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ColorCode.toColor(value.colorCode);
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return AppListCard(
      iconPath: value.resourcePath,
      iconColor: color,
      primaryTitle: value.name,
      subtitleLeading: '固定費',
      priceLabel: priceLabel,
      isIncome: false,
      onLongPress: () => _showMenuDialog(context, ref),
    );
  }

  Future<void> _showMenuDialog(BuildContext context, WidgetRef ref) async {
    await showMenuDialog(
      context,
      items: [
        MenuDialogItem(
          label: '削除',
          icon: Icons.delete_outline,
          isDestructive: true,
          onPressed: () {
            showDeleteConfirmationDialog(
              context,
              onConfirm: () {
                ref.read(fixedCostExpenseUsecaseProvider).delete(id: value.id);
              },
            );
          },
        ),
      ],
    );
  }
}

class DailyUnconfirmedFixedCostItemTile extends ConsumerWidget {
  const DailyUnconfirmedFixedCostItemTile({
    super.key,
    required this.value,
  });

  final MonthlyUnconfirmedFixedCostTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ColorCode.toColor(value.colorCode);
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
      onTap: () async {
        await openFixedCostExpenseEditSheet(context, ref, expenseId: value.id);
      },
      onLongPress: () => _showMenuDialog(context, ref),
    );
  }

  Future<void> _showMenuDialog(BuildContext context, WidgetRef ref) async {
    await showMenuDialog(
      context,
      items: [
        MenuDialogItem(
          label: '編集',
          icon: Icons.edit_outlined,
          onPressed: () async {
            await openFixedCostExpenseEditSheet(context, ref,
                expenseId: value.id);
          },
        ),
        MenuDialogItem(
          label: '削除',
          icon: Icons.delete_outline,
          isDestructive: true,
          onPressed: () {
            showDeleteConfirmationDialog(
              context,
              onConfirm: () {
                ref.read(fixedCostExpenseUsecaseProvider).delete(id: value.id);
              },
            );
          },
        ),
      ],
    );
  }
}
