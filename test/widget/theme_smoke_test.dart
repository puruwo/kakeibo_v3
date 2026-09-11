// ライト／ダーク両モードで主要画面が例外なく描画できることのスモークテスト（KP-013）
//
// 各画面の表示内容は個別のテストファイルが担保する。ここで見るのは
// 「AppTheme（light / dark）配下で、どの画面も描画・破棄の過程で例外を出さない」こと
// だけ（AppColors 拡張の未登録・入れ子 Theme の再発・明度前提の表現の混入を検知する）。
// 1画面×1モード＝1テストにして、落ちた画面とモードが名前から分かるようにする。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/config/aggregation_setting_page.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/daily_expense_summary_page/daily_expense_summary_page.dart';
import 'package:kakeibo/view/family_page/family_page.dart';
import 'package:kakeibo/view/foundation.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_page.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/monthly_fixed_cost_page.dart';
import 'package:kakeibo/view/monthly_page/monthly_page.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_page.dart';
import 'package:kakeibo/view/register_page/category_area/category_reorder_page.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';
import 'package:kakeibo/view/year_page/year_page.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_expense_list_page.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/fake_repositories.dart';
import '../helper/widget_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // 集計設定・テーマモードは SharedPreferences に保存されるためモックを初期化する
    SharedPreferences.setMockInitialValues({});
  });

  // 記録シート（Foundation が起動時に自動表示する）がカテゴリーを引くため、
  // 支出・収入それぞれ最低1件のカテゴリーマスタを積む
  const expenseSmallCategories = [
    ExpenseSmallCategoryEntity(
      id: 10,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '食費',
      defaultDisplayed: 1,
    ),
  ];
  const expenseBigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '生活費',
      resourcePath: 'assets/images/icon_meal.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
  ];
  const incomeSmallCategories = [
    IncomeSmallCategoryEntity(
      id: 1,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '給与',
      defaultDisplayed: 1,
    ),
  ];
  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '月次収入',
      colorCode: '00AAFF',
      iconPath: 'assets/images/icon_regular_income.svg',
    ),
  ];

  TestFakes buildFakes() => TestFakes(
    expenseSmallCategory: FakeExpenseSmallCategoryRepository(
      initialRecords: expenseSmallCategories,
    ),
    expenseBigCategory: FakeExpenseBigCategoryRepository(
      initialRecords: expenseBigCategories,
    ),
    incomeSmallCategory: FakeIncomeSmallCategoryRepository(
      initialRecords: incomeSmallCategories,
    ),
    incomeBigCategory: FakeIncomeBigCategoryRepository(
      initialRecords: incomeBigCategories,
    ),
  );

  // 年度期間: 2025/4/25〜2026/4/24（システム日時2025/7/6は年度3ヶ月目）
  final yearPeriod = PeriodValue(
    startDatetime: DateTime(2025, 4, 25),
    endDatetime: DateTime(2026, 4, 24),
  );

  // 対象画面。主要タブ・記録シート・設定・主要サブページを網羅する
  // （引数にエンティティを要する編集系ページは個別テストの担当）
  final screens = <({String name, Widget Function() build})>[
    (name: '土台（起動時の記録シート込み）', build: () => const Foundation()),
    (name: '全体タブ', build: () => const YearPage()),
    (name: '月間分析タブ', build: () => const MonthlyPage()),
    (name: '履歴タブ', build: () => const ExpenseHistoryPage()),
    (name: '家族タブ', build: () => const FamilyPage()),
    (name: '設定', build: () => const ConfigTop()),
    (
      name: '集計期間の設定',
      build: () => const AggregationSettingPage(
        originalStartDay: 25,
        originalStartMonth: 4,
      ),
    ),
    (
      name: '記録シート（支出）',
      build: () => const RegisaterPageBase.addExpense(
        transactionMode: TransactionMode.expense,
      ),
    ),
    (name: '記録シート（収入）', build: () => const RegisaterPageBase.addIncome()),
    (name: '記録シート（固定費）', build: () => const RegisaterPageBase.addFixedCost()),
    (
      name: 'カテゴリーの並び替え',
      build: () =>
          const CategoryReorderPage(transactionMode: TransactionMode.expense),
    ),
    (name: 'カテゴリー設定', build: () => const CategorySettingPage()),
    (name: 'ボーナス', build: () => const BonusHomePage()),
    (name: '月間固定費', build: () => const MonthlyFixedCostPage()),
    (name: '月間計画', build: () => const MonthlyPlanHomePage()),
    (name: '固定費の登録一覧', build: () => const FixedCostRegistrationListPage()),
    (name: '年間支出一覧', build: () => YearlyExpenseListPage(period: yearPeriod)),
    (name: '年間収入一覧', build: () => YearlyIncomeListPage(period: yearPeriod)),
    (
      name: '日別支出',
      build: () => DailyExpenseSummaryPage(date: DateTime(2025, 7, 6)),
    ),
  ];

  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    final modeName = themeMode == ThemeMode.dark ? 'ダーク' : 'ライト';
    final expectedColors = themeMode == ThemeMode.dark
        ? AppColors.dark
        : AppColors.light;
    final expectedBrightness = themeMode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light;

    group('$modeName モード', () {
      for (final screen in screens) {
        testWidgets('${screen.name} が例外なく描画・破棄できる', (tester) async {
          await pumpApp(
            tester,
            home: screen.build(),
            fakes: buildFakes(),
            themeMode: themeMode,
          );
          // 非同期 Provider の解決とアニメーションを進めつつ、1フレームごとに例外を回収する
          final renderErrors = await pumpAndCollectExceptions(tester);
          expect(
            renderErrors,
            isEmpty,
            reason: '${screen.name}（$modeName）の描画で例外',
          );

          // 画面がそのモードの AppTheme 配下にある（AppColors 拡張が引ける）こと
          final context = tester.element(
            find.byType(Scaffold, skipOffstage: false).first,
          );
          expect(Theme.of(context).brightness, expectedBrightness);
          expect(context.colors, same(expectedColors));

          // 破棄（記録シートの dispose 等）でも例外を出さない
          await tester.pumpWidget(const SizedBox.shrink());
          final disposeErrors = await pumpAndCollectExceptions(
            tester,
            times: 3,
          );
          expect(
            disposeErrors,
            isEmpty,
            reason: '${screen.name}（$modeName）の破棄で例外',
          );
        });
      }
    });
  }
}
