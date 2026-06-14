import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/tiles/expense_item_tile.dart';
import 'package:kakeibo/view/register_page/common_input_field/transaction_type_pill.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

import 'golden_helper.dart';

void main() {
  testWidgets('TransactionTypePill 支出/収入/固定費', timeout: const Timeout(Duration(seconds: 60)), (tester) async {
    await loadAppFonts();
    await tester.pumpWidget(
      wrapDark(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TransactionTypePill(
              mode: RegisterScreenMode.add,
              currentMode: TransactionMode.expense,
              onModeChanged: (_) {},
            ),
            const SizedBox(height: 12),
            TransactionTypePill(
              mode: RegisterScreenMode.add,
              currentMode: TransactionMode.income,
              onModeChanged: (_) {},
            ),
            const SizedBox(height: 12),
            TransactionTypePill(
              mode: RegisterScreenMode.add,
              currentMode: TransactionMode.fixedCost,
              onModeChanged: (_) {},
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/transaction_type_pill.png'),
    );
  });

  testWidgets('ExpenseItemTile 支出フラット行', timeout: const Timeout(Duration(seconds: 60)), (tester) async {
    await loadAppFonts();
    await tester.pumpWidget(
      wrapDark(
        padding: EdgeInsets.zero,
        SizedBox(
          width: 375,
          child: ExpenseItemTile(
            value: ExpenseHistoryTileValue(
              id: 1,
              date: DateTime(2026, 8, 10),
              price: 1634,
              paymentCategoryId: 1,
              memo: 'ランチ',
              smallCategoryName: '外食',
              bigCategoryName: '食費',
              colorCode: 'FF7171',
              iconPath: 'assets/images/icon_meal.svg',
              incomeSourceBigCategory: 0,
            ),
            leftsidePadding: 16,
            listSmallcategoryMemoOffset: 0,
            screenHorizontalMagnification: 1.0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ExpenseItemTile),
      matchesGoldenFile('goldens/expense_item_tile.png'),
    );
  });
}
