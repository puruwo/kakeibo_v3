import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/application/fixed_cost_record/fixed_cost_record_usecase.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_list_card.dart';
import 'package:kakeibo/view/component/fixed_cost_chip_label.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/expense_tab/open_fixed_cost_record_edit_sheet.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

/// 支出履歴の共通タイル（案件 UIデザイン改修 §6）
///
/// 特別枠支出リスト・支出一覧のカテゴリー明細/月別で共用する。
/// タップで編集シート、長押しで編集/削除メニューを開く。
/// 固定費由来の行（fixedCostId 非NULL）は日次サマリーのタイルと同じ扱い:
/// 専用編集シート・専用削除ユースケース・未確定は「未入力」表示＋チップ（仕様 §6.5・§6.6）。
class ExpenseHistoryListTile extends ConsumerWidget {
  const ExpenseHistoryListTile({
    super.key,
    required this.value,
  });

  final ExpenseHistoryTileValue value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ColorCode.toColor(value.colorCode);

    // 固定費由来の行かどうか（仕様 §8.4）
    final isFixedCost = value.fixedCostId != null;
    // 未確定の固定費行は金額が未入力
    final isUnconfirmed = isFixedCost && value.isConfirmed == 0;

    final priceLabel =
        isUnconfirmed ? '未入力' : yenmarkFormattedPriceGetter(value.price);

    return AppListCard(
      onTap: () async => await _openEditSheet(context, ref),
      onLongPress: () => _showMenuDialog(context, ref),
      iconPath: value.iconPath,
      iconColor: color,
      primaryTitle: value.bigCategoryName,
      secondaryTitle: value.smallCategoryName,
      subtitleLeading: '${value.date.month}月${value.date.day}日',
      subtitleTrailing: value.memo,
      priceLabel: priceLabel,
      priceLabelStyle:
          isUnconfirmed ? AppTextStyles.listCardUnconfirmedPriceLabel : null,
      // 固定費行の識別チップ
      customWidget: isFixedCost ? const FixedCostChipLabel() : null,
      isIncome: false,
      priceWidth: 100,
    );
  }

  /// 編集シートを開く（固定費行は編集範囲が違う専用シート。仕様 §6.6）
  Future<void> _openEditSheet(BuildContext context, WidgetRef ref) async {
    if (value.fixedCostId != null) {
      await openFixedCostRecordEditSheet(context, ref, expenseId: value.id);
      return;
    }
    _showEditSheet(context);
  }

  Future<void> _showMenuDialog(BuildContext context, WidgetRef ref) async {
    await showMenuDialog(context, items: [
      MenuDialogItem(
        label: '編集',
        icon: Icons.edit_outlined,
        onPressed: () async {
          await _openEditSheet(context, ref);
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
              // 固定費行の削除は推定額の再計算を伴うため専用ユースケースを使う（仕様 §6.5）
              if (value.fixedCostId != null) {
                ref.read(fixedCostRecordUsecaseProvider).delete(id: value.id);
              } else {
                ref.read(expenseUsecaseProvider).delete(id: value.id);
              }
            },
          );
        },
      ),
    ]);
  }

  void _showEditSheet(BuildContext context) {
    final expenseEntity = ExpenseEntity(
      id: value.id,
      date: DateFormat('yyyyMMdd').format(value.date),
      price: value.price,
      paymentCategoryId: value.paymentCategoryId,
      memo: value.memo,
      incomeSourceBigCategory: value.incomeSourceBigCategory,
    );
    showAppModalBottomSheet(
      context,
      child: RegisaterPageBase.editExpense(expenseEntity: expenseEntity),
    );
  }
}
