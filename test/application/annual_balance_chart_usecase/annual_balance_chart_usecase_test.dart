import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/annual_balance_chart_usecase/annual_balance_chart_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/annual_balance_chart_value.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/monthly_balance_value/monthly_balance_value.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 年度は2025/4/25〜2026/4/24、代表月は202506（buildDateScopeの既定値）
  final dateScope = buildDateScope();

  // 年度内の各月度の開始日（＝Fakeの期間別返却値のキー）
  const aprilKey = '20250425';
  const mayKey = '20250525';
  const juneKey = '20250625';
  // 2025/7/6を基準にすると7月度以降は未来になる
  const julyKey = '20250725';
  const augustKey = '20250825';

  /// 年間収支グラフのProviderをテストするコンテナを組み立てる
  ///
  /// 金額はいずれも「月度の開始日(yyyyMMdd) → 金額」のMapで指定する。
  /// 指定しなかった月度は0になる。
  /// [expense] は固定費行を含む支出合計（v10でexpenseの単一集計になった。仕様 §7.1）。
  ProviderContainer createChartContainer({
    DateTime? systemDate,
    Map<String, int> income = const {},
    Map<String, int> expense = const {},
  }) {
    final incomeRepository = FakeIncomeRepository()
      ..sumWithAccountTypeAndPeriodResultByPeriodStart.addAll(income);
    final expenseRepository = FakeExpenseRepository()
      ..totalExpenseByPeriodWithBigCategoryResultByPeriodStart.addAll(expense);

    return createContainer(
      overrides: [
        // システム日時は2025/7/6（現在月度は2025/6/25〜2025/7/24）
        ...aggregationSettingOverrides(
          systemDate: systemDate ?? DateTime(2025, 7, 6),
        ),
        incomeRepositoryProvider.overrideWithValue(incomeRepository),
        expenseRepositoryProvider.overrideWithValue(expenseRepository),
      ],
    );
  }

  Future<AnnualBalanceChartValue> fetchChart(ProviderContainer container) =>
      container.read(annualBalanceChartNotifierProvider(dateScope).future);

  /// 年度の先頭（4月度）の結果を取り出す
  MonthlyBalanceValue firstMonthOf(AnnualBalanceChartValue value) =>
      value.monthlyBalanceValues.first;

  group('AnnualBalanceChartUsecaseNotifier の月次データ', () {
    test('年度開始月から12ヶ月分が順に生成される', () async {
      final container = createChartContainer();

      final result = await fetchChart(container);

      expect(result.monthlyBalanceValues, hasLength(12));
      expect(result.monthlyBalanceValues.map((v) => v.month), [
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        1,
        2,
        3,
      ]);
      // 代表日は各月度の開始日
      expect(
        result.monthlyBalanceValues.first.representativeDate,
        DateTime(2025, 4, 25),
      );
      expect(
        result.monthlyBalanceValues.last.representativeDate,
        DateTime(2026, 3, 25),
      );
      // 選択中の月度の情報はdateScopeから引き継ぐ
      expect(result.currentMonth, 6);
      expect(result.monthIndex, dateScope.monthIndex);
    });

    test('支出はexpenseの単一テーブル集計をそのまま使う（後付け合算なし）', () async {
      // 100000（通常）+ 80000（確定固定費）+ 6000（未確定固定費の予想額）が
      // すでにSQL側で合算された値として返る
      final container = createChartContainer(
        income: const {aprilKey: 300000},
        expense: const {aprilKey: 186000},
      );

      final result = await fetchChart(container);

      final april = firstMonthOf(result);
      expect(april.monthlyIncome, 300000);
      expect(april.monthlyExpense, 186000);
      expect(april.savings, 114000);
    });
  });

  group('AnnualBalanceChartUsecaseNotifier のステータス判定', () {
    test('現在月度より後の月度はfuture', () async {
      // 金額が入っていても未来ならfutureが優先される
      final container = createChartContainer(
        income: const {julyKey: 300000, augustKey: 300000},
      );

      final result = await fetchChart(container);

      final types = result.monthlyBalanceValues
          .map((v) => v.monthlyBalanceType)
          .toList();
      // 4月度〜6月度は未来ではない
      expect(
        types.sublist(0, 3),
        everyElement(isNot(MonthlyBalanceType.future)),
      );
      // 7月度以降は未来
      expect(types.sublist(3), everyElement(MonthlyBalanceType.future));
    });

    test('収入も支出も0ならnoRecorod', () async {
      final container = createChartContainer();

      final result = await fetchChart(container);

      expect(
        firstMonthOf(result).monthlyBalanceType,
        MonthlyBalanceType.noRecorod,
      );
    });

    test('収入だけ0ならnoIncome', () async {
      final container = createChartContainer(
        expense: const {aprilKey: 100000},
      );

      final result = await fetchChart(container);

      expect(
        firstMonthOf(result).monthlyBalanceType,
        MonthlyBalanceType.noIncome,
      );
    });

    test('支出だけ0ならnoExpense', () async {
      final container = createChartContainer(income: const {aprilKey: 300000});

      final result = await fetchChart(container);

      expect(
        firstMonthOf(result).monthlyBalanceType,
        MonthlyBalanceType.noExpense,
      );
    });

    test('収入が支出を上回ればsurplus', () async {
      final container = createChartContainer(
        income: const {aprilKey: 300000},
        expense: const {aprilKey: 100000},
      );

      final result = await fetchChart(container);

      expect(
        firstMonthOf(result).monthlyBalanceType,
        MonthlyBalanceType.surplus,
      );
      expect(firstMonthOf(result).savings, 200000);
    });

    test('収入が支出以下ならdeficit（収支差0もdeficit）', () async {
      final sameContainer = createChartContainer(
        income: const {aprilKey: 100000},
        expense: const {aprilKey: 100000},
      );
      final overContainer = createChartContainer(
        income: const {aprilKey: 100000},
        expense: const {aprilKey: 150000},
      );

      final same = await fetchChart(sameContainer);
      final over = await fetchChart(overContainer);

      expect(firstMonthOf(same).monthlyBalanceType, MonthlyBalanceType.deficit);
      expect(firstMonthOf(same).savings, 0);
      expect(firstMonthOf(over).monthlyBalanceType, MonthlyBalanceType.deficit);
      expect(firstMonthOf(over).savings, -50000);
    });

    test('全月がfuture/noRecorodならhasNoRecordがtrue・1月でも記録があればfalse', () async {
      final emptyContainer = createChartContainer();
      final recordedContainer = createChartContainer(
        income: const {mayKey: 300000},
      );

      final empty = await fetchChart(emptyContainer);
      final recorded = await fetchChart(recordedContainer);

      expect(empty.hasNoRecord, isTrue);
      expect(recorded.hasNoRecord, isFalse);
    });
  });

  group('AnnualBalanceChartUsecaseNotifier のY軸スケール', () {
    test('未来月の金額はスケール計算から除外される', () async {
      final container = createChartContainer(
        // 過去月は10万、未来月は100万
        income: const {aprilKey: 100000, augustKey: 1000000},
      );

      final result = await fetchChart(container);

      // 未来の100万を拾っていたらmaxValueは100万規模になる
      expect(result.yAxisScale.maxValue, 100000);
      expect(result.yAxisScale.interval, 20000);
    });

    test('全月が未来で記録が無ければダミースケールになる', () async {
      // システム日時を年度開始より前にすると12ヶ月すべて未来になる
      final container = createChartContainer(systemDate: DateTime(2025, 3, 1));

      final result = await fetchChart(container);

      expect(
        result.monthlyBalanceValues.map((v) => v.monthlyBalanceType),
        everyElement(MonthlyBalanceType.future),
      );
      expect(result.hasNoRecord, isTrue);
      expect(result.yAxisScale.minValue, 0);
      expect(result.yAxisScale.maxValue, 100000);
      expect(result.yAxisScale.interval, 10000);
      expect(result.yAxisScale.gridValues, isEmpty);
    });

    test('maxValueはintervalの倍数に切り上げられ、gridValuesは0からinterval刻みになる', () async {
      final container = createChartContainer(income: const {aprilKey: 105000});

      final result = await fetchChart(container);

      // 105000 → interval 20000 → 6目盛りぶんの120000へ切り上げ
      expect(result.yAxisScale.interval, 20000);
      expect(result.yAxisScale.maxValue, 120000);
      expect(result.yAxisScale.gridValues, [
        0,
        20000,
        40000,
        60000,
        80000,
        100000,
        120000,
      ]);
    });

    test('グリッド間隔は1/2/5系列から選ばれる', () async {
      // 目標グリッド本数は5本。最大値を5で割った値に近い1/2/5系列を選ぶ
      final largeContainer = createChartContainer(
        income: const {aprilKey: 480000},
      );
      final middleContainer = createChartContainer(
        income: const {aprilKey: 230000},
      );
      final smallContainer = createChartContainer(
        income: const {aprilKey: 90000},
      );

      final large = await fetchChart(largeContainer);
      final middle = await fetchChart(middleContainer);
      final small = await fetchChart(smallContainer);

      expect(large.yAxisScale.interval, 100000);
      expect(middle.yAxisScale.interval, 50000);
      expect(small.yAxisScale.interval, 20000);
    });

    test('グリッド間隔の下限は1万（少額でも1万を下回らない）', () async {
      final container = createChartContainer(
        income: const {aprilKey: 30000},
        expense: const {juneKey: 8000},
      );

      final result = await fetchChart(container);

      // 30000/5=6000 は1万未満のため下限の1万に丸められる
      expect(result.yAxisScale.interval, 10000);
      expect(result.yAxisScale.maxValue, 30000);
    });
  });
}
