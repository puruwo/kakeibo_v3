import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_list_card.dart';
import 'package:kakeibo/view/component/unconfirmed_fixed_cost_chip_label.dart';
import 'package:kakeibo/view/fixed_cost_setting_page/fixed_cost_setting_page.dart';

class FixedCostItemTile extends ConsumerWidget {
  const FixedCostItemTile({
    super.key,
    required this.item,
  });
  final FixedCostEntity item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 表示価格を決定（変動ありの場合はestimatedPrice、変動なしの場合はprice）
    final displayPrice = item.variable == 1 ? item.estimatedPrice : item.price;
    final isVariable = item.variable == 1;

    // 支払い頻度のラベルを取得
    final PaymentFrequencyValue frequencyValue = PaymentFrequencyValue.fromDB(
      intervalNumber: item.intervalNumber,
      intervalUnitNumber: item.intervalUnit,
    );

    // 次回支払日のフォーマット
    String formattedNextPaymentDate = '';
    if (item.nextPaymentDate != null && item.nextPaymentDate!.isNotEmpty) {
      final dateStr = item.nextPaymentDate!;
      if (dateStr.length == 8) {
        formattedNextPaymentDate =
            '${dateStr.substring(0, 4)}/${dateStr.substring(4, 6)}/${dateStr.substring(6, 8)}';
      }
    }

    // 金額ラベル
    final priceLabel =
        displayPrice == 0 ? '---' : yenmarkFormattedPriceGetter(displayPrice);

    return AppListCard(
      primaryTitle: item.name,
      subtitleLeading: formattedNextPaymentDate.isNotEmpty
          ? '次回：$formattedNextPaymentDate'
          : null,
      priceSubtitle: isVariable ? '平均' : null,
      priceLabel: priceLabel,
      isIncome: false,
      customWidget: isVariable ? const UnconfirmedFixedCostChipLabel() : null,
      customUnderPriceLabel: frequencyValue.dateLabel,
      // タイルタップで固定費の設定画面へ（仕様 §6.7）
      onTap: () => _openSettingPage(context),
      onLongPress: () async {
        return await showMenuDialog(context, items: [
          MenuDialogItem(
              label: '編集',
              icon: Icons.edit_outlined,
              onPressed: () => _openSettingPage(context)),
          MenuDialogItem(
              label: '削除',
              icon: Icons.delete_outline,
              isDestructive: true,
              onPressed: () async {
                showFixedCostDeleteConfirmationDialog(
                  context,
                  onConfirm: () {
                    ref.read(fixedCostUsecaseProvider).delete(id: item.id!);
                  },
                );
              }),
        ]);
      },
    );
  }

  /// 固定費の設定画面（マスタ編集）へ遷移する
  void _openSettingPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FixedCostSettingPage(fixedCostEntity: item),
      ),
    );
  }
}
