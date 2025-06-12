import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/view/register_page/expense_tab/register_expense_page.dart';
import 'package:kakeibo/view/register_page/income_tab/register_income_page.dart';
import 'package:kakeibo/view_model/state/bonus_home_page/selected_tab_controller/selected_tab_controller.dart';

class BonusHomeFooter extends ConsumerWidget {
  const BonusHomeFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (ref.watch(selectedTabControllerNotifierProvider)) {
      case SelectedTab.bonusExpense:
        return _newExpenseButton(context, ref);
      case SelectedTab.bonusIncome:
        return _newIncomeButton(context, ref);
      default:
        return const SizedBox.shrink(); // 他のタブでは何も表示しない
    }
  }

  Widget _newExpenseButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final today = DateTime.now();
          ExpenseEntity newExpense = ExpenseEntity(
            date: DateFormat('yyyyMMdd').format(today),
            incomeSourceBigCategory: 1, //　1を指定することで、収入の大カテゴリーでボーナスを選択する
            memo: '',
          );

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
                  child: RegisterExpensePage(
                    expenseEntity: newExpense,
                    isTabVisible: true, // タブを非表示にする
                  ),
                ),
              );
            },
          );
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

  Widget _newIncomeButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
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
              final today = DateTime.now();
              IncomeEntity newIncome = IncomeEntity(
                date: DateFormat('yyyyMMdd').format(today),
                categoryId: 1, //　1を指定することで、でボーナスを選択する
                memo: 'oeiaoi',
              );
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData.dark(),
                themeMode: ThemeMode.dark,
                darkTheme: ThemeData.dark(),
                home: MediaQuery.withClampedTextScaling(
                  child: RegisterIncomePage(
                    incomeEntity: newIncome,
                    isTabVisible: true, // タブを非表示にする
                  ),
                ),
              );
            },
          );
        },
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
