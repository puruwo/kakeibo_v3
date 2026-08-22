import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 集計期間の開始日（＝Fakeの期間別返却値のキー）
  const currentPeriodKey = '20250625';

  // 固定費マスタ（10:金額確定80,000円）
  const fixedCosts = [
    FixedCostEntity(
      id: 10,
      name: '家賃',
      variable: 0,
      price: 80000,
      fixedCostCategoryId: 1,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    ),
  ];

  // 7/1に支払われる確定済みの固定費（80,000円）
  const confirmedRent = FixedCostExpenseEntity(
    id: 100,
    fixedCostId: 10,
    fixedCostCategoryId: 1,
    date: '20250701',
    price: 80000,
    name: '家賃',
  );

  late FakeExpenseRepository fakeExpenseRepository;

  /// 予測グラフのユースケースをテストするコンテナを組み立てる
  ///
  /// 部品（predictor / layoutCalculator / dataSource）は本物を使い、
  /// その下のリポジトリだけをFakeに差し替えて組成部の振る舞いを見る。
  ProviderContainer createUsecaseContainer({
    required DateTime systemDate,
    Map<String, int> income = const {},
    List<BudgetEntity> budgets = const [],
    Map<DateTime, int> dailyExpenseTotals = const {},
    List<FixedCostExpenseEntity> fixedCostExpenses = const [],
  }) {
    fakeExpenseRepository = FakeExpenseRepository(
      dailyExpenseTotalByDate: dailyExpenseTotals,
    );
    return createContainer(
      overrides: [
        ...aggregationSettingOverrides(systemDate: systemDate),
        incomeRepositoryProvider.overrideWithValue(
          FakeIncomeRepository()
            ..sumWithAccountTypeAndPeriodResultByPeriodStart.addAll(income),
        ),
        budgetRepositoryProvider.overrideWithValue(
          FakeBudgetRepository(initialRecords: budgets),
        ),
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          FakeFixedCostExpenseRepository(initialRecords: fixedCostExpenses),
        ),
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(initialRecords: fixedCosts),
        ),
        // 棒グラフ用のマスタ（このテストではカテゴリー内訳は見ないため空でよい）
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseSmallCategoryRepository(),
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseBigCategoryRepository(),
        ),
        fixedCostCategoryRepositoryProvider.overrideWithValue(
          FakeFixedCostCategoryRepository(),
        ),
      ],
    );
  }

  group('PredictionGraphUsecase.fetchPredictionGraphData のグラフ種別', () {
    test('未来月は計算せずに早期リターンする', () async {
      final container = createUsecaseContainer(
        systemDate: DateTime(2025, 7, 6),
      );
      final usecase = container.read(predictionGraphUsecaseProvider);

      // 8月度（2025/8/25〜2025/9/24）は2025/7/6から見て未来
      final result = await usecase.fetchPredictionGraphData(
        buildDateScope(
          aggregationMonthPeriod: PeriodValue(
            startDatetime: DateTime(2025, 8, 25),
            endDatetime: DateTime(2025, 9, 24),
          ),
          representativeMonth: '202508',
        ),
      );

      expect(
        result.predictionGraphLineType,
        PredictionGraphLineType.futureMonth,
      );
      expect(result.displayMaxValue, 100.0);
      expect(result.income, isNull);
      expect(result.budget, isNull);
      expect(result.maxValue, isNull);
      expect(result.dailyBarDataList, isNull);
      expect(result.shouldShowPredictionLine, isFalse);
      // DBアクセスも発生しない
      expect(fakeExpenseRepository.dailyExpenseTotalDates, isEmpty);
    });

    test('実支出・収入・予算がすべて0ならnoDataになる', () async {
      final container = createUsecaseContainer(
        systemDate: DateTime(2025, 7, 6),
      );
      final usecase = container.read(predictionGraphUsecaseProvider);

      final result = await usecase.fetchPredictionGraphData(buildDateScope());

      // 累積データは最終日の0エントリーだけなので実支出なしと判定される
      expect(result.predictionGraphLineType, PredictionGraphLineType.noData);
      expect(result.displayMaxValue, 100.0);
      expect(result.income, isNull);
      expect(result.budget, isNull);
    });
  });

  group('PredictionGraphUsecase.fetchPredictionGraphData の予算線', () {
    test('予算が0なら固定費を足さず0のままにする', () async {
      final container = createUsecaseContainer(
        systemDate: DateTime(2025, 7, 6),
        // 収入があるためnoDataにはならない
        income: const {currentPeriodKey: 300000},
        fixedCostExpenses: const [confirmedRent],
      );
      final usecase = container.read(predictionGraphUsecaseProvider);

      final result = await usecase.fetchPredictionGraphData(buildDateScope());

      expect(result.budget, 0);
      expect(result.totalFixedCostExpense, 80000);
      expect(result.shouldShowBudgetLine, isFalse);
    });

    test('予算があれば予算＋固定費の合算が予算線の値になる', () async {
      final container = createUsecaseContainer(
        systemDate: DateTime(2025, 7, 6),
        income: const {currentPeriodKey: 300000},
        budgets: const [
          BudgetEntity(
            id: 1,
            expenseBigCategoryId: 1,
            month: '202506',
            price: 50000,
          ),
        ],
        fixedCostExpenses: const [confirmedRent],
      );
      final usecase = container.read(predictionGraphUsecaseProvider);

      final result = await usecase.fetchPredictionGraphData(buildDateScope());

      // 予算50,000円 ＋ 固定費80,000円
      expect(result.budget, 130000);
      expect(result.totalFixedCostExpense, 80000);
      expect(result.shouldShowBudgetLine, isTrue);
    });
  });

  group('PredictionGraphUsecase.fetchPredictionGraphData の集計範囲', () {
    test('当月は表示最大値がグラフ最大値の1.2倍になり、累積は今日まで取得される', () async {
      final container = createUsecaseContainer(
        systemDate: DateTime(2025, 7, 6),
        income: const {currentPeriodKey: 300000},
        dailyExpenseTotals: {DateTime(2025, 7, 1): 1000},
      );
      final usecase = container.read(predictionGraphUsecaseProvider);

      final result = await usecase.fetchPredictionGraphData(buildDateScope());

      expect(result.predictionGraphLineType, PredictionGraphLineType.thisMonth);
      // 収入300,000円が最大値になる
      expect(result.maxValue, 300000.0);
      expect(result.displayMaxValue, 360000.0);
      // 当月の累積データはtoday（7/6）までしか取得しない
      expect(
        fakeExpenseRepository.dailyExpenseTotalDates.last,
        DateTime(2025, 7, 6),
      );
    });

    test('過去月は累積データが期間末まで取得され実績線が組成される', () async {
      final container = createUsecaseContainer(
        // 2025/8/1から見ると6月度（6/25〜7/24）は過去
        systemDate: DateTime(2025, 8, 1),
        income: const {currentPeriodKey: 300000},
        dailyExpenseTotals: {
          DateTime(2025, 7, 1): 1000,
          DateTime(2025, 7, 20): 2000,
        },
      );
      final usecase = container.read(predictionGraphUsecaseProvider);

      final result = await usecase.fetchPredictionGraphData(buildDateScope());

      expect(result.predictionGraphLineType, PredictionGraphLineType.lastMonth);
      // 当月と違い、累積データは期間末（7/24）まで取得される
      expect(
        fakeExpenseRepository.dailyExpenseTotalDates.last,
        DateTime(2025, 7, 24),
      );
      expect(result.expensePoints!.map((e) => e.date), [
        DateTime(2025, 7, 1),
        DateTime(2025, 7, 20),
        DateTime(2025, 7, 24),
      ]);
      expect(result.expensePoints!.map((e) => e.price), [1000, 3000, 3000]);
      expect(result.latestPrice, 3000);
      // 過去月は予測線を出さない
      expect(result.shouldShowPredictionLine, isFalse);
    });
  });
}
