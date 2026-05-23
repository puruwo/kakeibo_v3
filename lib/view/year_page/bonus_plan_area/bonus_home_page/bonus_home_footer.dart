import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
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
      child: MainButton(
        buttonType: ButtonColorType.main,
        buttonText: '新しい支出を追加',
        onPressed: () {
          final today = ref.read(systemDatetimeNotifierProvider);
          final newExpense = ExpenseEntity(
            date: DateFormat('yyyyMMdd').format(today),
            incomeSourceBigCategory:
                IncomeBigCategoryConstants.incomeSourceIdBonus,
            memo: '',
          );
          showAppModalBottomSheet(
            context,
            child: RegisaterPageBase.addExpense(expenseEntity: newExpense),
          );
        },
      ),
    );
  }

  Widget _newIncomeButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: MainButton(
        buttonType: ButtonColorType.main,
        buttonText: '新しい収入を追加',
        onPressed: () {
          final today = ref.read(systemDatetimeNotifierProvider);
          final newIncome = IncomeEntity(
            date: DateFormat('yyyyMMdd').format(today),
            categoryId: IncomeBigCategoryConstants.incomeSourceIdBonus,
          );
          showAppModalBottomSheet(
            context,
            child: RegisaterPageBase.addIncome(incomeEntity: newIncome),
          );
        },
      ),
    );
  }
}
