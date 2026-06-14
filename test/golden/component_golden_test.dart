import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/view/component/app_list_card.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/tiles/confirmed_fixed_cost_item_tile.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/tiles/expense_item_tile.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/tiles/income_item_tile.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_area/tiles/unconfirmed_fixed_cost_item_tile.dart';
import 'package:kakeibo/view/register_page/common_input_field/transaction_type_pill.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

import 'golden_helper.dart';

const _timeout = Timeout(Duration(seconds: 60));

/// RepaintBoundary でコンポーネントを切り出して golden 化する。
Future<void> _capture(
  WidgetTester tester,
  Widget child,
  String name, {
  double width = 375,
}) async {
  await loadAppFonts();
  final key = GlobalKey();
  await tester.pumpWidget(
    wrapDark(
      RepaintBoundary(
        key: key,
        // 切り出し範囲に黒背景を入れる。これが無いと透明背景になり
        // ダークテーマの白文字(タイトル/価格)が消えてしまう。
        child: ColoredBox(
          color: const Color(0xFF000000),
          child: SizedBox(width: width, child: child),
        ),
      ),
      padding: EdgeInsets.zero,
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(find.byKey(key), matchesGoldenFile('goldens/$name.png'));
}

void main() {
  testWidgets('TransactionTypePill 支出/収入/固定費', timeout: _timeout, (tester) async {
    await _capture(
      tester,
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
      'transaction_type_pill',
      width: 140,
    );
  });

  testWidgets('履歴フラット行 4種', timeout: _timeout, (tester) async {
    await _capture(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExpenseItemTile(
            value: const _Expense().value,
            leftsidePadding: 16,
            listSmallcategoryMemoOffset: 0,
            screenHorizontalMagnification: 1.0,
          ),
          IncomeItemTile(
            value: const _Income().value,
            leftsidePadding: 16,
            screenHorizontalMagnification: 1.0,
          ),
          ConfirmedFixedCostItemTile(
            value: const _ConfirmedFixed().value,
            leftsidePadding: 16,
            screenHorizontalMagnification: 1.0,
          ),
          UnconfirmedFixedCostItemTile(
            value: const _UnconfirmedFixed().value,
            leftsidePadding: 16,
            screenHorizontalMagnification: 1.0,
          ),
        ],
      ),
      'history_rows',
    );
  });

  testWidgets('AppListCard 収入/支出', timeout: _timeout, (tester) async {
    await _capture(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          AppListCard(
            iconPath: 'assets/images/icon_school.svg',
            iconColor: Color(0xFF21D19F),
            primaryTitle: '夏ボーナス',
            subtitleLeading: '2月10日',
            subtitleTrailing: '2年目ボーナス',
            priceLabel: '654,700円',
            isIncome: true,
          ),
          SizedBox(height: 8),
          AppListCard(
            iconPath: 'assets/images/icon_domain.svg',
            iconColor: Color(0xFF8E8E93),
            primaryTitle: '家賃',
            subtitleLeading: '住居費',
            priceLabel: '85,000円',
            isIncome: false,
          ),
        ],
      ),
      'app_list_card',
    );
  });
}

// --- サンプル値 ---
class _Expense {
  const _Expense();
  ExpenseHistoryTileValue get value => ExpenseHistoryTileValue(
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
      );
}

class _Income {
  const _Income();
  IncomeHistoryTileValue get value => IncomeHistoryTileValue(
        id: 2,
        date: DateTime(2026, 8, 10),
        price: 30000,
        paymentCategoryId: 1,
        memo: '',
        smallCategoryName: '月収',
        bigCategoryName: 'アルバイト',
        colorCode: '21D19F',
        iconPath: 'assets/images/icon_school.svg',
      );
}

class _ConfirmedFixed {
  const _ConfirmedFixed();
  MonthlyConfirmedFixedCostTileValue get value =>
      MonthlyConfirmedFixedCostTileValue(
        id: 3,
        date: DateTime(2026, 8, 10),
        price: 85000,
        name: '家賃',
        variable: 0,
        intervalNumber: 1,
        intervalUnit: 1,
        categoryName: '住居費',
        colorCode: '8E8E93',
        resourcePath: 'assets/images/icon_domain.svg',
        frequencyLabel: '毎月',
      );
}

class _UnconfirmedFixed {
  const _UnconfirmedFixed();
  MonthlyUnconfirmedFixedCostTileValue get value =>
      MonthlyUnconfirmedFixedCostTileValue(
        id: 4,
        date: DateTime(2026, 8, 10),
        fixedCostId: 1,
        name: '電気代',
        variable: 1,
        intervalNumber: 1,
        intervalUnit: 1,
        estimatedPrice: 8000,
        categoryName: '光熱費',
        colorCode: '8E8E93',
        resourcePath: 'assets/images/icon_energy_savings_leaf.svg',
        frequencyLabel: '毎月',
      );
}
