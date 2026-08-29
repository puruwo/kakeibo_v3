import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
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

class YearlyIncomeCard extends ConsumerWidget {
  const YearlyIncomeCard({
    super.key,
    required this.value,
  });

  final IncomeHistoryTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ColorCode.toColor(value.colorCode);
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return AppListCard(
      onTap: () => _showModalBottomSheet(context),
      onLongPress: () => _showMenuDialog(context, ref),
      iconPath: value.iconPath,
      iconColor: color,
      // 一覧のカテゴリー集計が大カテゴリー単位のため、明細も大・小を併記する
      // （支出履歴タイルと同じ語彙。ユーザー指定 2026-08-29）
      primaryTitle: value.bigCategoryName,
      secondaryTitle: value.smallCategoryName,
      subtitleLeading: '${value.date.month}月${value.date.day}日',
      subtitleTrailing: value.memo,
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
        isDestructive: true,
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
