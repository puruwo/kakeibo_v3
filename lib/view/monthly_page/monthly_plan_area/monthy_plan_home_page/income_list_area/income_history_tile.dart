import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/income/income_usecase.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_list_card.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

class IncomeHistoryTile extends ConsumerWidget {
  const IncomeHistoryTile({
    super.key,
    required this.value,
  });

  final IncomeHistoryTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return AppListCard(
      onTap: () => _showModalBottomSheet(context),
      onLongPress: () => _showMenuDialog(context, ref),
      iconPath: value.iconPath,
      primaryTitle: value.smallCategoryName,
      subtitleTrailing: value.memo,
      subtitleLeading: '${value.date.month}月${value.date.day}日',
      priceLabel: priceLabel,
      isIncome: true,
    );
  }

  Future<void> _showMenuDialog(BuildContext context, WidgetRef ref) async {
    await showMenuDialog(context, items: [
      MenuDialogItem(
        label: '編集',
        icon: Icons.edit_outlined,
        onPressed: () async {
          _showModalBottomSheet(context);
        },
      ),
      MenuDialogItem(
        label: '削除',
        icon: Icons.delete_outline,
        onPressed: () async {
          showDeleteConfirmationDialog(
            context,
            onConfirm: () {
              ref.read(incomeUsecaseProvider).delete(id: value.id);
            },
          );
        },
      ),
    ]);
  }

  void _showModalBottomSheet(BuildContext context) {
    final incomeEntity = IncomeEntity(
      id: value.id,
      date: DateFormat('yyyyMMdd').format(value.date),
      price: value.price,
      categoryId: value.paymentCategoryId,
      memo: value.memo,
    );
    showAppModalBottomSheet(
      context,
      child: RegisaterPageBase.editIncome(incomeEntity: incomeEntity),
    );
  }
}
