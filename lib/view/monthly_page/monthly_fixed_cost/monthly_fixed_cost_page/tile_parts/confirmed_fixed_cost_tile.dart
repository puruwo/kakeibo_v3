import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_record/fixed_cost_record_usecase.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_list_card.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/tile_parts/fixed_cost_tile_subtitle.dart';
import 'package:kakeibo/view/register_page/expense_tab/open_fixed_cost_record_edit_sheet.dart';

class ConfirmedFixedCostTile extends ConsumerWidget {
  const ConfirmedFixedCostTile({
    super.key,
    required this.value,
  });

  final MonthlyConfirmedFixedCostTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 支払い日のフォーマット
    final paymentDateLabel =
        '${value.date.year}/${value.date.month}/${value.date.day}';

    // 値段ラベル
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return AppListCard(
      primaryTitle: value.name,
      // 2行目は「小カテゴリー › 日付」（案A。仕様 §8.5）
      subtitleLeadingWidget: FixedCostTileSubtitle(
        smallCategoryName: value.smallCategoryName,
        dateLabel: paymentDateLabel,
      ),
      priceLabel: priceLabel,
      isIncome: false,
      customUnderPriceLabel: value.frequencyLabel,
      onTap: () async {
        // 固定費の実績行の編集シートを開く（編集できるのは金額・拠出元・メモのみ。仕様 §6.6）
        await openFixedCostRecordEditSheet(context, ref, expenseId: value.id);
      },
      onLongPress: () async {
        return await showMenuDialog(context, items: [
          MenuDialogItem(
              label: '削除',
              icon: Icons.delete_outline,
              isDestructive: true,
              onPressed: () async {
                showDeleteConfirmationDialog(
                  context,
                  onConfirm: () {
                    ref
                        .read(fixedCostRecordUsecaseProvider)
                        .delete(id: value.id);
                  },
                );
              }),
        ]);
      },
    );
  }
}
