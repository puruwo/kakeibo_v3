import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/ui_value/daily_transaction_group/daily_transaction_group.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/tiles/confirmed_fixed_cost_item_tile.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/tiles/expense_item_tile.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/tiles/income_item_tile.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/tiles/unconfirmed_fixed_cost_item_tile.dart';

class TransactionHistoryGroupTile extends ConsumerWidget {
  const TransactionHistoryGroupTile({
    super.key,
    required this.group,
    required this.leftsidePadding,
    required this.listSmallcategoryMemoOffset,
    required this.screenHorizontalMagnification,
  });

  final DailyTransactionGroup group;
  final double leftsidePadding;
  final double listSmallcategoryMemoOffset;
  final double screenHorizontalMagnification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // すべてのリストを結合してWidgetのリストを作成する
    final List<Widget> tileWidgets = [];

    // 固定費(確定)
    for (var item in group.confirmedFixedCosts) {
      tileWidgets.add(ConfirmedFixedCostItemTile(
        value: item,
        leftsidePadding: leftsidePadding,
        screenHorizontalMagnification: screenHorizontalMagnification,
      ));
    }

    // 固定費(未確定)
    for (var item in group.unconfirmedFixedCosts) {
      tileWidgets.add(UnconfirmedFixedCostItemTile(
        value: item,
        leftsidePadding: leftsidePadding,
        screenHorizontalMagnification: screenHorizontalMagnification,
      ));
    }

    // 支出
    for (var item in group.expenses) {
      tileWidgets.add(ExpenseItemTile(
        value: item,
        leftsidePadding: leftsidePadding,
        listSmallcategoryMemoOffset: listSmallcategoryMemoOffset,
        screenHorizontalMagnification: screenHorizontalMagnification,
      ));
    }

    // ボーナス支出
    for (var item in group.bonusExpenses) {
      // ボーナス支出もExpenseItemTileで表示（UIが同じなら）
      // 必要に応じてBonusExpenseItemTileを作っても良いが、今回はExpenseItemTileを流用
      tileWidgets.add(ExpenseItemTile(
        value: item,
        leftsidePadding: leftsidePadding,
        listSmallcategoryMemoOffset: listSmallcategoryMemoOffset,
        screenHorizontalMagnification: screenHorizontalMagnification,
      ));
    }

    // 収入
    for (var item in group.incomes) {
      tileWidgets.add(IncomeItemTile(
        value: item,
        leftsidePadding: leftsidePadding,
        screenHorizontalMagnification: screenHorizontalMagnification,
      ));
    }

    // ボーナス収入
    for (var item in group.bonusIncomes) {
      tileWidgets.add(IncomeItemTile(
        value: item,
        leftsidePadding: leftsidePadding,
        screenHorizontalMagnification: screenHorizontalMagnification,
      ));
    }

    if (tileWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: tileWidgets,
    );
  }
}
