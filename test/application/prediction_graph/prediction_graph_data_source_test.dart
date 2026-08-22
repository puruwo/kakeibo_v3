import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_constants.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_data_source.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/theme/category_palette.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 支出大カテゴリーマスタ（1:食費 / 2:日用品）
  const bigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FF0000',
      bigCategoryName: '食費',
      resourcePath: 'assets/images/icon_food.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: '00FF00',
      bigCategoryName: '日用品',
      resourcePath: 'assets/images/icon_daily.svg',
      displayOrder: 2,
      isDisplayed: 1,
    ),
  ];

  // 支出小カテゴリーマスタ（11・12→大カテゴリー1 / 21→大カテゴリー2）
  const smallCategories = [
    ExpenseSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '食料品',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 12,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '外食',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 21,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '消耗品',
      defaultDisplayed: 1,
    ),
  ];

  // 固定費マスタ
  // 10: 金額確定型（80,000円）。実績生成済みの回を表すのに使う
  // 30: 変動型（予想額6,000円）。実績生成済みの回を表すのに使う
  // 50: 変動型（予想額9,000円）。next_payment_date=7/4 で未生成の回を表す
  const fixedCosts = [
    FixedCostEntity(
      id: 10,
      name: '家賃',
      variable: 0,
      price: 80000,
      fixedCostCategoryId: 1,
      expenseSmallCategoryId: 11,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      // 期間（7/1〜7/5）より後に設定し、未生成分として展開されないようにする
      nextPaymentDate: '20250802',
    ),
    FixedCostEntity(
      id: 30,
      name: '電気代',
      variable: 1,
      estimatedPrice: 6000,
      fixedCostCategoryId: 1,
      expenseSmallCategoryId: 11,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
      nextPaymentDate: '20250804',
    ),
  ];

  /// 実績未生成の固定費マスタ（次回支払日7/4・予想額9,000円）
  const ungeneratedGas = FixedCostEntity(
    id: 50,
    name: 'ガス代',
    variable: 1,
    estimatedPrice: 9000,
    fixedCostCategoryId: 1,
    expenseSmallCategoryId: 11,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250104',
    nextPaymentDate: '20250704',
  );

  // 7/2に支払われる確定済みの固定費行（80,000円）
  const confirmedRent = ExpenseEntity(
    id: 100,
    date: '20250702',
    price: 80000,
    paymentCategoryId: 11,
    memo: '家賃',
    fixedCostId: 10,
    isConfirmed: 1,
  );

  // 7/4に支払われる未確定の固定費行（予想額6,000円）
  const unconfirmedElectricity = ExpenseEntity(
    id: 200,
    date: '20250704',
    price: null,
    paymentCategoryId: 11,
    memo: '電気代',
    fixedCostId: 30,
    isConfirmed: 0,
    estimatedPrice: 6000,
  );

  /// 予測グラフのデータソースを組み立てる
  ///
  /// [dailyExpenseTotals] / [dailyExpenseLists] は expense の日次集計・日次リスト。
  /// v10では固定費行もexpenseに入るため、生成済みの固定費はこの2つに含まれる。
  /// [expenses] には固定費行そのものを渡す（未生成分の判定に使う）。
  PredictionGraphDataSource buildDataSource({
    Map<DateTime, int> dailyExpenseTotals = const {},
    Map<DateTime, List<ExpenseEntity>> dailyExpenseLists = const {},
    List<ExpenseEntity> expenses = const [],
    List<FixedCostEntity> masters = fixedCosts,
  }) {
    final container = createContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(
          FakeExpenseRepository(
            initialRecords: expenses,
            dailyExpenseTotalByDate: dailyExpenseTotals,
            dailyExpenseListByDate: dailyExpenseLists,
          ),
        ),
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(initialRecords: masters),
        ),
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseSmallCategoryRepository(initialRecords: smallCategories),
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseBigCategoryRepository(initialRecords: bigCategories),
        ),
      ],
    );
    return container.read(predictionGraphDataSourceProvider);
  }

  /// 累積データから日付だけを取り出す
  List<DateTime> datesOf(List<Map<String, dynamic>> rows) =>
      rows.map((e) => e['date'] as DateTime).toList();

  /// 累積データから金額だけを取り出す
  List<int> sumsOf(List<Map<String, dynamic>> rows) =>
      rows.map((e) => e['sum_price_daily'] as int).toList();

  group('PredictionGraphDataSource.fetchCumulativeByDate', () {
    final fromDate = DateTime(2025, 7, 1);
    final toDate = DateTime(2025, 7, 5);

    test('日別の支出合計が累積値に変換される', () async {
      final dataSource = buildDataSource(
        dailyExpenseTotals: {
          DateTime(2025, 7, 1): 1000,
          DateTime(2025, 7, 3): 2000,
          DateTime(2025, 7, 5): 500,
        },
      );

      final result = await dataSource.fetchCumulativeByDate(
        fromDate: fromDate,
        toDate: toDate,
      );

      expect(datesOf(result), [
        DateTime(2025, 7, 1),
        DateTime(2025, 7, 3),
        DateTime(2025, 7, 5),
      ]);
      expect(sumsOf(result), [1000, 3000, 3500]);
    });

    test('生成済みの固定費行は日次集計に含まれる（後付けの加算はしない）', () async {
      // 7/2の確定80,000円・7/4の未確定6,000円は expense の日次集計に入っている
      final dataSource = buildDataSource(
        dailyExpenseTotals: {
          DateTime(2025, 7, 2): 80000,
          DateTime(2025, 7, 4): 6000,
        },
        expenses: const [confirmedRent, unconfirmedElectricity],
      );

      final result = await dataSource.fetchCumulativeByDate(
        fromDate: fromDate,
        toDate: toDate,
      );

      expect(datesOf(result), [
        DateTime(2025, 7, 2),
        DateTime(2025, 7, 4),
        DateTime(2025, 7, 5),
      ]);
      // 二重計上されず 80000 → 86000 で累積する
      expect(sumsOf(result), [80000, 86000, 86000]);
    });

    test('実績未生成の固定費は次回支払日から周期展開してスパイクになる', () async {
      // ガス代（次回支払日7/4・予想額9,000円）はまだ実績行が無い
      final dataSource = buildDataSource(
        dailyExpenseTotals: {DateTime(2025, 7, 2): 1000},
        masters: const [...fixedCosts, ungeneratedGas],
      );

      final result = await dataSource.fetchCumulativeByDate(
        fromDate: fromDate,
        toDate: toDate,
      );

      expect(datesOf(result), [
        DateTime(2025, 7, 2),
        DateTime(2025, 7, 4),
        DateTime(2025, 7, 5),
      ]);
      expect(sumsOf(result), [1000, 10000, 10000]);
    });

    test('同じ支払日に実績行があれば周期展開ぶんは二重に積まれない', () async {
      // 7/4のガス代は既に実績生成済み（予想額9,000円が日次集計に入っている）
      final dataSource = buildDataSource(
        dailyExpenseTotals: {DateTime(2025, 7, 4): 9000},
        expenses: const [
          ExpenseEntity(
            id: 300,
            date: '20250704',
            price: null,
            paymentCategoryId: 11,
            memo: 'ガス代',
            fixedCostId: 50,
            isConfirmed: 0,
            estimatedPrice: 9000,
          ),
        ],
        masters: const [...fixedCosts, ungeneratedGas],
      );

      final result = await dataSource.fetchCumulativeByDate(
        fromDate: fromDate,
        toDate: toDate,
      );

      expect(sumsOf(result), [9000, 9000]);
    });

    test('一般支出と固定費が同じ日にあれば合算される', () async {
      final dataSource = buildDataSource(
        dailyExpenseTotals: {DateTime(2025, 7, 2): 81500},
        expenses: const [confirmedRent],
      );

      final result = await dataSource.fetchCumulativeByDate(
        fromDate: fromDate,
        toDate: toDate,
      );

      expect(datesOf(result), [DateTime(2025, 7, 2), DateTime(2025, 7, 5)]);
      expect(sumsOf(result), [81500, 81500]);
    });

    test('支出0の日はエントリーを作らないが、最終日だけは0でもエントリーが追加される', () async {
      final dataSource = buildDataSource(
        dailyExpenseTotals: {DateTime(2025, 7, 2): 1000},
      );

      final result = await dataSource.fetchCumulativeByDate(
        fromDate: fromDate,
        toDate: toDate,
      );

      // 支出のある7/2と、支出が無くても追加される最終日7/5の2件だけ
      expect(datesOf(result), [DateTime(2025, 7, 2), DateTime(2025, 7, 5)]);
      expect(sumsOf(result), [1000, 1000]);

      // 最終日に支出がある場合は0エントリーの追加は起きない
      final withLastDayExpense = await buildDataSource(
        dailyExpenseTotals: {
          DateTime(2025, 7, 2): 1000,
          DateTime(2025, 7, 5): 500,
        },
      ).fetchCumulativeByDate(fromDate: fromDate, toDate: toDate);

      expect(datesOf(withLastDayExpense), [
        DateTime(2025, 7, 2),
        DateTime(2025, 7, 5),
      ]);
      expect(sumsOf(withLastDayExpense), [1000, 1500]);
    });

    test('未生成分を先に取り込んでも結果は日付昇順になる', () async {
      // 周期展開ぶん（7/4）を先にマップへ入れてから日次ループで7/1・7/3を足す
      final dataSource = buildDataSource(
        dailyExpenseTotals: {
          DateTime(2025, 7, 1): 100,
          DateTime(2025, 7, 3): 200,
        },
        masters: const [...fixedCosts, ungeneratedGas],
      );

      final result = await dataSource.fetchCumulativeByDate(
        fromDate: fromDate,
        toDate: toDate,
      );

      final dates = datesOf(result);
      expect(dates, [
        DateTime(2025, 7, 1),
        DateTime(2025, 7, 3),
        DateTime(2025, 7, 4),
        DateTime(2025, 7, 5),
      ]);
      // 累積値なので単調増加になる
      expect(sumsOf(result), [100, 300, 9300, 9300]);
    });
  });

  group('PredictionGraphDataSource.fetchDailyBarData', () {
    test('一般支出が大カテゴリー別に集計される', () async {
      final dataSource = buildDataSource(
        dailyExpenseLists: {
          DateTime(2025, 7, 1): const [
            ExpenseEntity(
              id: 1,
              date: '20250701',
              price: 1000,
              paymentCategoryId: 11,
            ),
            ExpenseEntity(
              id: 2,
              date: '20250701',
              price: 500,
              paymentCategoryId: 12,
            ),
            ExpenseEntity(
              id: 3,
              date: '20250701',
              price: 300,
              paymentCategoryId: 21,
            ),
          ],
        },
      );

      final result = await dataSource.fetchDailyBarData(
        fromDate: DateTime(2025, 7, 1),
        toDate: DateTime(2025, 7, 1),
        today: DateTime(2025, 7, 1),
      );

      expect(result.dailyBarDataList, hasLength(1));
      final categoryExpenses = result.dailyBarDataList.first.categoryExpenses;
      expect(categoryExpenses, hasLength(2));
      // 小カテゴリー11・12は同じ大カテゴリー1にまとまる
      expect(categoryExpenses[0].bigCategoryId, 1);
      expect(categoryExpenses[0].price, 1500);
      expect(categoryExpenses[0].colorCode, 'FF0000');
      expect(categoryExpenses[0].categoryName, '食費');
      expect(categoryExpenses[0].iconPath, 'assets/images/icon_food.svg');
      expect(categoryExpenses[1].bigCategoryId, 2);
      expect(categoryExpenses[1].price, 300);
      expect(categoryExpenses[1].categoryName, '日用品');
    });

    test('固定費は同じ日に複数あっても先頭の1本にまとまる', () async {
      const rentOnJul2 = ExpenseEntity(
        id: 100,
        date: '20250702',
        price: 80000,
        paymentCategoryId: 11,
        memo: '家賃',
        fixedCostId: 10,
        isConfirmed: 1,
      );
      // 7/2に未確定の固定費（予想額6,000円）も支払いがある状態にする
      const electricityOnJul2 = ExpenseEntity(
        id: 201,
        date: '20250702',
        price: null,
        paymentCategoryId: 11,
        memo: '電気代',
        fixedCostId: 30,
        isConfirmed: 0,
        estimatedPrice: 6000,
      );
      final dataSource = buildDataSource(
        dailyExpenseLists: {
          DateTime(2025, 7, 2): const [
            ExpenseEntity(
              id: 1,
              date: '20250702',
              price: 1000,
              paymentCategoryId: 11,
            ),
            // 固定費行も日次リストに含まれる（v10）。カテゴリー棒には積まれない
            rentOnJul2,
            electricityOnJul2,
          ],
        },
        expenses: const [rentOnJul2, electricityOnJul2],
      );

      final result = await dataSource.fetchDailyBarData(
        fromDate: DateTime(2025, 7, 2),
        toDate: DateTime(2025, 7, 2),
        today: DateTime(2025, 7, 2),
      );

      final categoryExpenses = result.dailyBarDataList.first.categoryExpenses;
      // 固定費2件が1本に統合され、先頭に積まれる
      expect(categoryExpenses, hasLength(2));
      expect(
        categoryExpenses.first.bigCategoryId,
        PredictionGraphConstants.fixedCostBarCategoryId,
      );
      expect(categoryExpenses.first.price, 86000);
      expect(categoryExpenses.first.categoryName, '固定費');
      expect(categoryExpenses.first.colorCode, CategoryPalette.fixedCostHex);
      expect(categoryExpenses.first.iconPath, '');
      // 固定費行はカテゴリー別の棒には二重計上されない
      expect(categoryExpenses[1].bigCategoryId, 1);
      expect(categoryExpenses[1].price, 1000);
    });

    test('実績未生成の固定費も未来のスパイクとして棒に積まれる', () async {
      final dataSource = buildDataSource(
        masters: const [...fixedCosts, ungeneratedGas],
      );

      final result = await dataSource.fetchDailyBarData(
        fromDate: DateTime(2025, 7, 1),
        toDate: DateTime(2025, 7, 5),
        today: DateTime(2025, 7, 2),
      );

      // 7/4だけが棒として現れる（未来日）
      expect(result.dailyBarDataList.map((e) => e.date), [DateTime(2025, 7, 4)]);
      expect(result.dailyBarDataList.single.isFutureDate, isTrue);
      expect(result.dailyBarDataList.single.categoryExpenses.single.price, 9000);
    });

    test('barMaxValueは日別最大合計としきい値20,000円の大きい方になる', () async {
      // 日別最大がしきい値以下の場合はしきい値が採用される
      final belowThreshold =
          await buildDataSource(
            dailyExpenseLists: {
              DateTime(2025, 7, 1): const [
                ExpenseEntity(
                  id: 1,
                  date: '20250701',
                  price: 5000,
                  paymentCategoryId: 11,
                ),
              ],
            },
          ).fetchDailyBarData(
            fromDate: DateTime(2025, 7, 1),
            toDate: DateTime(2025, 7, 1),
            today: DateTime(2025, 7, 1),
          );
      expect(
        belowThreshold.barMaxValue,
        PredictionGraphConstants.barChartScaleThreshold,
      );

      // 日別最大がしきい値を超えたら実際の最大値が採用される
      final aboveThreshold =
          await buildDataSource(
            dailyExpenseLists: {
              DateTime(2025, 7, 1): const [
                ExpenseEntity(
                  id: 1,
                  date: '20250701',
                  price: 5000,
                  paymentCategoryId: 11,
                ),
              ],
              DateTime(2025, 7, 2): const [
                ExpenseEntity(
                  id: 2,
                  date: '20250702',
                  price: 30000,
                  paymentCategoryId: 11,
                ),
              ],
            },
          ).fetchDailyBarData(
            fromDate: DateTime(2025, 7, 1),
            toDate: DateTime(2025, 7, 2),
            today: DateTime(2025, 7, 2),
          );
      expect(aboveThreshold.barMaxValue, 30000);
    });

    test('棒の高さは平方根スケールで正規化され、バー内はカテゴリー金額比になる', () async {
      final dataSource = buildDataSource(
        dailyExpenseLists: {
          DateTime(2025, 7, 1): const [
            ExpenseEntity(
              id: 1,
              date: '20250701',
              price: 3000,
              paymentCategoryId: 11,
            ),
            ExpenseEntity(
              id: 2,
              date: '20250701',
              price: 2000,
              paymentCategoryId: 21,
            ),
          ],
        },
      );

      final result = await dataSource.fetchDailyBarData(
        fromDate: DateTime(2025, 7, 1),
        toDate: DateTime(2025, 7, 1),
        today: DateTime(2025, 7, 1),
      );

      final barData = result.dailyBarDataList.first;
      // √5,000 / √20,000 = 0.5
      expect(
        barData.normalizedTotalHeight,
        closeTo(math.sqrt(5000) / math.sqrt(20000), 1e-9),
      );
      expect(barData.normalizedTotalHeight, closeTo(0.5, 1e-9));
      // バー内の比率は日合計に対するカテゴリー金額の比
      expect(barData.categoryExpenses[0].normalizedHeight, closeTo(0.6, 1e-9));
      expect(barData.categoryExpenses[1].normalizedHeight, closeTo(0.4, 1e-9));
    });

    test('未来日はisFutureDate=trueになり、支出のない日はリストに含まれない', () async {
      final dataSource = buildDataSource(
        dailyExpenseLists: {
          DateTime(2025, 7, 2): const [
            ExpenseEntity(
              id: 1,
              date: '20250702',
              price: 1000,
              paymentCategoryId: 11,
            ),
          ],
          DateTime(2025, 7, 4): const [
            ExpenseEntity(
              id: 2,
              date: '20250704',
              price: 2000,
              paymentCategoryId: 11,
            ),
          ],
        },
      );

      final result = await dataSource.fetchDailyBarData(
        fromDate: DateTime(2025, 7, 1),
        toDate: DateTime(2025, 7, 5),
        today: DateTime(2025, 7, 3),
      );

      // 支出のある7/2・7/4だけが残る
      expect(result.dailyBarDataList.map((e) => e.date), [
        DateTime(2025, 7, 2),
        DateTime(2025, 7, 4),
      ]);
      expect(result.dailyBarDataList[0].isFutureDate, isFalse);
      expect(result.dailyBarDataList[1].isFutureDate, isTrue);
    });
  });
}
