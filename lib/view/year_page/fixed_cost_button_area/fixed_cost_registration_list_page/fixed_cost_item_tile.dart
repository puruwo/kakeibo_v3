import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/unconfirmed_fixed_cost_chip_label.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

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

    return AppInkWell(
      onLongPress: () async {
        return await showMenuDialog(context, items: [
          MenuDialogItem(
              label: '編集',
              icon: Icons.edit_outlined,
              onPressed: () async {
                showModalBottomSheet(
                  //sccafoldの上に出すか
                  useRootNavigator: true,
                  isScrollControlled: true,
                  useSafeArea: true,
                  constraints: const BoxConstraints(
                    maxWidth: 2000,
                  ),
                  context: context,
                  // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
                  builder: (context) {
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      theme: ThemeData.dark(),
                      themeMode: ThemeMode.dark,
                      darkTheme: ThemeData.dark(),
                      home: MediaQuery.withClampedTextScaling(
                        // テキストサイズの制御
                        minScaleFactor: 0.7,
                        maxScaleFactor: 0.95,
                        child: RegisaterPageBase.editFixedCost(
                            fixedCostEntity: item),
                      ),
                    );
                  },
                );
              }),
          MenuDialogItem(
              label: '削除',
              icon: Icons.delete_outline,
              onPressed: () async {
                showDeleteConfirmationDialog(
                  context,
                  onConfirm: () {
                    ref.read(fixedCostUsecaseProvider).delete(id: item.id!);
                  },
                );
              }),
        ]);
      },
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: MyColors.quarternarySystemfill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左側: 名前
                Text(
                  item.name,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: MyColors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // 金額
                Row(
                  children: [
                    RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        children: [
                          if (isVariable)
                            TextSpan(
                              text: '平均　',
                              style: MyFonts.cardSecondaryTitle,
                            ),
                          TextSpan(
                            text: yenmarkFormattedPriceGetter(displayPrice),
                            style: MyFonts.cardPriceLabel,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 次回支払日と頻度
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '次回：$formattedNextPaymentDate',
                  style: MyFonts.cardSecondaryTitle,
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    // 変動ありの場合は「変動あり」ラベルを表示
                    if (isVariable) const UnconfirmedFixedCostChipLabel(),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      frequencyValue.dateLabel,
                      style: MyFonts.cardSecondaryTitle,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
