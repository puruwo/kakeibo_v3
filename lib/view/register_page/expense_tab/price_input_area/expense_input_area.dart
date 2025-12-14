import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_field.dart';
import 'package:kakeibo/view/register_page/expense_tab/price_input_area/income_source_input_field.dart';

class ExpenseInputArea extends ConsumerStatefulWidget {
  const ExpenseInputArea(
      {super.key,
      required this.originalPrice,
      required this.originalIncomeSourceBigCategory});

  final int originalPrice;
  final int originalIncomeSourceBigCategory;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpenseInputArea();
}

class _ExpenseInputArea extends ConsumerState<ExpenseInputArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondarySystemfill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 購入金額入力
            PriceInputField(
              originalPrice: widget.originalPrice,
              priceInputFieldStatus: PriceInputFieldStatus.normal,
            ),

            const SizedBox(
              height: 8,
            ),

            // 区切り線
            const Divider(
              // ウィジェット自体の高さ
              height: 0,
              // 線の太さ
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: MyColors.separater,
            ),

            const SizedBox(
              height: 2,
            ),

            // 拠出元選択
            IncomeSourceInputField(
                originalIncomeSourceBigCategory:
                    widget.originalIncomeSourceBigCategory),
          ],
        ),
      ),
    );
  }
}
