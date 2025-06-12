import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/bonus_home_page/selected_tab_controller/selected_tab_controller.dart';

class BonusHomeFooter extends ConsumerWidget {
  const BonusHomeFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (ref.watch(selectedTabControllerNotifierProvider)) {
      case SelectedTab.bonusExpense:
        return _newExpenseButton();
      case SelectedTab.bonusIncome:
        return _newIncomeButton();
      default:
        return const SizedBox.shrink(); // 他のタブでは何も表示しない
    }
  }

  Widget _newExpenseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.buttonPrimary,
        ),
        child: Text(
          '新しい支出を追加',
          style: MyFonts.mainButtonText,
        ),
      ),
    );
  }

  Widget _newIncomeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.buttonPrimary,
        ),
        child: Text(
          '新しい収入を追加',
          style: MyFonts.mainButtonText,
        ),
      ),
    );
  }
}
