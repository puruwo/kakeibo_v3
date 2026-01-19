import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_list_card.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

class BonusExpenseHistoryTile extends ConsumerWidget {
  const BonusExpenseHistoryTile({
    super.key,
    required this.value,
  });

  final ExpenseHistoryTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = MyColors().getColorFromHex(value.colorCode);
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return AppListCard(
      onTap: () => _showModalBottomSheet(context),
      onLongPress: () => _showMenuDialog(context, ref),
      iconPath: value.iconPath,
      iconColor: color,
      primaryTitle: value.bigCategoryName,
      secondaryTitle: value.smallCategoryName,
      subtitleLeading: '${value.date.month}月${value.date.day}日',
      subtitleTrailing: value.memo,
      priceLabel: priceLabel,
      isIncome: false,
      priceWidth: 100,
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
              ref.read(expenseUsecaseProvider).delete(id: value.id);
            },
          );
        },
      ),
    ]);
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(
        maxWidth: 2000,
      ),
      context: context,
      builder: (context) {
        ExpenseEntity expenseEntity = ExpenseEntity(
          id: value.id,
          date: DateFormat('yyyyMMdd').format(value.date),
          price: value.price,
          paymentCategoryId: value.paymentCategoryId,
          memo: value.memo,
          incomeSourceBigCategory: value.incomeSourceBigCategory,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(),
          home: MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.7,
            maxScaleFactor: 0.95,
            child: RegisaterPageBase.editExpense(
              expenseEntity: expenseEntity,
            ),
          ),
        );
      },
    );
  }
}
