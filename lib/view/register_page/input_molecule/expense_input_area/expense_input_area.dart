import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/register_page/input_molecule/expense_input_area/expense_input_field.dart';
import 'package:kakeibo/view/register_page/input_molecule/expense_input_area/income_source_input_field.dart';
class ExpenseInputArea extends ConsumerStatefulWidget {
  const ExpenseInputArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpenseInputArea();
}

class _ExpenseInputArea extends ConsumerState<ExpenseInputArea> {

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondarySystemfill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 購入金額入力
            ExpenseInputField(),

            SizedBox(
              height: 14,
            ),

            // 区切り線
            Divider(
              // ウィジェット自体の高さ
              height: 0,
              // 線の太さ
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: MyColors.separater,
            ),

            SizedBox(
              height: 2,
            ),

            // 拠出元選択
            IncomeSourceInputField(),
          ],
        ),
      ),
    );
  }
}
