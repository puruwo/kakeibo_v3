import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/yearly_income_list/yearly_income_list_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/yearly_income_list_value/yearly_income_list_entity.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 年度は2025/4/25〜2026/4/24
  final yearPeriod = PeriodValue(
    startDatetime: DateTime(2025, 4, 25),
    endDatetime: DateTime(2026, 4, 24),
  );

  // 収入小カテゴリー（1:給与→大1 / 2:賞与→大2 / 3:副業→大1）
  const incomeSmallCategories = [
    IncomeSmallCategoryEntity(
      id: 1,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '給与',
      defaultDisplayed: 1,
    ),
    IncomeSmallCategoryEntity(
      id: 2,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '賞与',
      defaultDisplayed: 1,
    ),
    IncomeSmallCategoryEntity(
      id: 3,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '副業',
      defaultDisplayed: 1,
    ),
  ];

  // 収入大カテゴリー（1:給与 / 2:ボーナス）
  const incomeBigCategories = [
    IncomeBigCategoryEntity(
      id: 1,
      name: '給与',
      colorCode: '0000FF',
      iconPath: 'assets/images/icon_salary.svg',
    ),
    IncomeBigCategoryEntity(
      id: 2,
      name: 'ボーナス',
      colorCode: 'FF00FF',
      iconPath: 'assets/images/icon_bonus.svg',
    ),
  ];

  // 2025年6月〜2026年1月にまたがる収入
  const incomes = [
    IncomeEntity(id: 1, categoryId: 1, date: '20250625', price: 300000),
    IncomeEntity(id: 2, categoryId: 1, date: '20250725', price: 310000),
    IncomeEntity(id: 3, categoryId: 2, date: '20251215', price: 500000),
    IncomeEntity(id: 4, categoryId: 1, date: '20260125', price: 320000),
    IncomeEntity(id: 5, categoryId: 3, date: '20250610', price: 50000),
  ];

  Future<YearlyIncomeListValue> fetchIncomeList({
    List<IncomeEntity> records = incomes,
  }) {
    final container = createContainer(
      overrides: [
        incomeRepositoryProvider.overrideWithValue(
          FakeIncomeRepository(initialRecords: records),
        ),
        incomeSmallCategoryRepositoryProvider.overrideWithValue(
          FakeIncomeSmallCategoryRepository(
            initialRecords: incomeSmallCategories,
          ),
        ),
        incomeBigCategoryRepositoryProvider.overrideWithValue(
          FakeIncomeBigCategoryRepository(initialRecords: incomeBigCategories),
        ),
      ],
    );
    return container.read(yearlyIncomeListNotifierProvider(yearPeriod).future);
  }

  group('YearlyIncomeListUsecaseNotifier の月グループ', () {
    test('月ごとにまとめられる（期間開始年は「M月」・年跨ぎは「yyyy年M月」）', () async {
      final result = await fetchIncomeList();

      expect(result.monthlyGroups.map((g) => g.monthLabel), [
        '2026年1月',
        '12月',
        '7月',
        '6月',
      ]);
      // 6月は2件（給与と副業）
      expect(result.monthlyGroups.last.incomes, hasLength(2));
    });

    test('月グループは新しい順に並ぶ（年跨ぎ）', () async {
      final result = await fetchIncomeList();

      // 2026年1月が2025年12月より前に来る
      final labels = result.monthlyGroups.map((g) => g.monthLabel).toList();
      expect(labels.indexOf('2026年1月'), lessThan(labels.indexOf('12月')));
    });

    test('月グループ内は日付の新しい順に並ぶ', () async {
      final result = await fetchIncomeList();

      final june = result.monthlyGroups.firstWhere(
        (g) => g.monthLabel == '6月',
      );
      expect(june.incomes.map((e) => e.date), [
        DateTime(2025, 6, 25),
        DateTime(2025, 6, 10),
      ]);
      // 大カテゴリーの色とアイコンが引き継がれる
      expect(june.incomes.first.smallCategoryName, '給与');
      expect(june.incomes.first.bigCategoryName, '給与');
      expect(june.incomes.first.colorCode, '0000FF');
      expect(june.incomes.first.iconPath, 'assets/images/icon_salary.svg');
    });

    test('totalIncomeは全収入の合計になる', () async {
      final result = await fetchIncomeList();

      expect(result.totalIncome, 1480000);
    });
  });

  group('YearlyIncomeListUsecaseNotifier のカテゴリー別サマリー', () {
    test('同じ小カテゴリーの金額は合算される', () async {
      final result = await fetchIncomeList();

      final salary = result.categorySummaries.firstWhere(
        (s) => s.categoryName == '給与',
      );
      // 6月30万 + 7月31万 + 翌年1月32万
      expect(salary.totalAmount, 930000);
      expect(result.categorySummaries.map((s) => s.categoryName), [
        '給与',
        '賞与',
        '副業',
      ]);
    });

    test('percentageは合計に対する比率で、金額の多い順に並ぶ', () async {
      final result = await fetchIncomeList();

      expect(result.categorySummaries.map((s) => s.totalAmount), [
        930000,
        500000,
        50000,
      ]);
      expect(result.categorySummaries[0].percentage, closeTo(62.8378, 1e-4));
      expect(result.categorySummaries[1].percentage, closeTo(33.7838, 1e-4));
      expect(result.categorySummaries[2].percentage, closeTo(3.3784, 1e-4));
    });

    test('収入が1件も無ければ空のグループ・合計0・空のサマリーになる', () async {
      final result = await fetchIncomeList(records: const []);

      expect(result.monthlyGroups, isEmpty);
      expect(result.totalIncome, 0);
      expect(result.categorySummaries, isEmpty);
    });
  });
}
