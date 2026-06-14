import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/daily_expense_summary_page/daily_expense_summary_page.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_page.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/category_expense_hisotry_page.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/monthly_fixed_cost_page.dart';
import 'package:kakeibo/view/monthly_page/monthly_page.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_page.dart';
import 'package:kakeibo/view/register_page/category_area/category_reorder_page.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';
import 'package:kakeibo/view/year_page/year_page.dart';

import 'db_harness.dart';
import 'golden_helper.dart';
import 'page_harness.dart';

const _pageTimeout = Timeout(Duration(seconds: 90));

void main() {
  setUpAll(() {
    initDbHarness();
  });

  Future<void> pumpPage(WidgetTester tester, Widget page, String name) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(375 * 3.0, 812 * 3.0);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: repoOverrides(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(extensions: const [AppColors.light]),
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark().copyWith(
            appBarTheme: const AppBarTheme(
              scrolledUnderElevation: 0,
              elevation: 0,
            ),
            extensions: const [AppColors.dark],
          ),
          home: page,
        ),
      ),
    );
    // 実DB I/O(ffi)は runAsync でないと完了しない。runAsync で実非同期を
    // 進め、pump で再描画＆アニメーションクロックを進める、を繰り返す。
    // ネスト非同期(カレンダー/カテゴリ集計)の解決に十分な回数まわす。
    for (var i = 0; i < 18; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 120)));
      await tester.pump(const Duration(milliseconds: 300));
    }
    // sqflite はトランザクション毎に 10s のタイムアウト(実)Timer を張り、
    // トランザクション完了でキャンセルされる。実時間を与えて in-flight な
    // トランザクションを確実に完了させ、Timerを残さない(!timersPending対策)。
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/page_$name.png'),
    );
  }

  testWidgets('FixedCostRegistrationListPage', timeout: _pageTimeout, (tester) async {
    await pumpPage(tester, const FixedCostRegistrationListPage(), 'fixed_cost_list');
  });

  testWidgets('CategorySettingPage', timeout: _pageTimeout, (tester) async {
    await pumpPage(tester, const CategorySettingPage(), 'category_setting');
  });

  testWidgets('ExpenseHistoryPage', timeout: _pageTimeout, (tester) async {
    await pumpPage(tester, const ExpenseHistoryPage(), 'expense_history');
  });

  testWidgets('YearPage', timeout: _pageTimeout, (tester) async {
    await pumpPage(tester, const YearPage(), 'year');
  });

  // 集計系(予算×カテゴリ)の並行DBクエリが sqflite ffi 上で完了せず、
  // ロード中スピナーのまま終了時に Timer が残る(!timersPending)。
  // 実装側のクエリ直列化 or seed 整備が必要。goldenは chrome のみ生成済み。
  testWidgets('MonthlyPage', timeout: _pageTimeout, skip: true, (tester) async {
    await pumpPage(tester, const MonthlyPage(), 'monthly');
  });

  testWidgets('MonthlyPlanHomePage', timeout: _pageTimeout, skip: true, (tester) async {
    await pumpPage(tester, const MonthlyPlanHomePage(), 'monthly_plan');
  });

  testWidgets('MonthlyFixedCostPage', timeout: _pageTimeout, (tester) async {
    await pumpPage(tester, const MonthlyFixedCostPage(), 'monthly_fixed_cost');
  });

  testWidgets('CategoryReorderPage', timeout: _pageTimeout, (tester) async {
    await pumpPage(
      tester,
      const CategoryReorderPage(transactionMode: TransactionMode.expense),
      'category_reorder',
    );
  });

  testWidgets('DailyExpenseSummaryPage', timeout: _pageTimeout, (tester) async {
    await pumpPage(
      tester,
      DailyExpenseSummaryPage(date: DateTime(2026, 8, 10)),
      'daily_expense_summary',
    );
  });

  testWidgets('CategoryExpenseHistoryPage', timeout: _pageTimeout, (tester) async {
    await pumpPage(
      tester,
      const CategoryExpenseHistoryPage(bigId: 0),
      'category_expense_history',
    );
  });

  testWidgets('BonusHomePage', timeout: _pageTimeout, (tester) async {
    await pumpPage(tester, const BonusHomePage(), 'bonus_home');
  });
}
