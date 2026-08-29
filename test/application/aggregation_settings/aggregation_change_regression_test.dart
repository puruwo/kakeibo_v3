// 集計期間の設定変更が既存レコードの所属期間へ与える影響の回帰テスト
// （KP-005 テストケース D-1・D-2）
//
// 既存テストは「保存済み設定を固定した状態」だけを検証している。
// ここでは同じレコード群に対して開始日・開始月を変えたコンテナを順に当て、
// 期間の境界レコードが正しく所属を変えること・レコード自体は消えも増えもしないことを固定する。
//
// Fake の合計額系（fetchTotalExpenseByPeriod 等）はスタブ値方式のため使わず、
// records を期間で絞る取得系（支出: fetchWithSourceCategory / 収入: calcurateSumWithPeriod）
// を経由して集計する。期間は本物の MonthPeriodService / YearPeriodService で求める。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/annual_balance_chart_usecase/annual_balance_chart_usecase.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/core/year_value/year_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';
import 'package:kakeibo/domain_service/month_period_service/period_status_service.dart';
import 'package:kakeibo/domain_service/year_period_service/month_period_service.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

/// 今日（システム日時）。旧設定（25日始まり）では今月 = 8/25〜9/24
final _today = DateTime(2026, 8, 29);

/// 支出フィクスチャ。旧期間（25日始まり）の境界に4件、年度境界（4月始まり）に2件
const _expenses = [
  // e1: 旧期間の前月末
  ExpenseEntity(id: 1, date: '20260724', price: 1000, paymentCategoryId: 11),
  // e2: 旧期間の初日
  ExpenseEntity(id: 2, date: '20260725', price: 2000, paymentCategoryId: 11),
  // e3: 旧期間の末日
  ExpenseEntity(id: 3, date: '20260824', price: 4000, paymentCategoryId: 11),
  // e4: 旧期間の翌期初日
  ExpenseEntity(id: 4, date: '20260825', price: 8000, paymentCategoryId: 11),
  // e5: 年度境界（4/25始まり）の前
  ExpenseEntity(id: 5, date: '20260331', price: 100, paymentCategoryId: 11),
  // e6: 年度境界の初日
  ExpenseEntity(id: 6, date: '20260425', price: 200, paymentCategoryId: 11),
];

/// 収入フィクスチャ。支出と同じ4日付（金額は 10,000×n で区別）
const _incomes = [
  IncomeEntity(id: 1, date: '20260724', price: 10000),
  IncomeEntity(id: 2, date: '20260725', price: 20000),
  IncomeEntity(id: 3, date: '20260824', price: 30000),
  IncomeEntity(id: 4, date: '20260825', price: 40000),
];

void main() {
  late FakeExpenseRepository fakeExpenseRepository;
  late FakeIncomeRepository fakeIncomeRepository;

  setUp(() {
    // 設定変更の前後でレコードを共有するため、Fake はテストごとに1つ作って使い回す
    fakeExpenseRepository = FakeExpenseRepository(initialRecords: _expenses);
    // 収入の会計種別解決用に、小カテゴリー「給与」→ 大カテゴリー1（生活収支）を与える
    fakeIncomeRepository = FakeIncomeRepository(
      initialRecords: _incomes,
      smallCategoryToBigCategory: {IncomeSmallCategoryConstants.salary: 1},
    );
  });

  /// 「設定を変更した状態」を、開始日・開始月を変えた別コンテナで表現する
  ProviderContainer createSettingsContainer({
    int startDay = 25,
    int startMonth = 4,
  }) {
    return createContainer(
      overrides: [
        ...aggregationSettingOverrides(
          startDay: startDay,
          startMonth: startMonth,
          systemDate: _today,
        ),
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
        incomeRepositoryProvider.overrideWithValue(fakeIncomeRepository),
      ],
    );
  }

  /// 今日を含む月の集計期間（設定に従う）
  Future<PeriodValue> monthPeriodOf(ProviderContainer c, [DateTime? date]) =>
      c.read(monthPeriodServiceProvider).fetchMonthPeriod(date ?? _today);

  /// 今日を含む年度の集計期間（設定に従う）
  Future<PeriodValue> yearPeriodOf(ProviderContainer c, [DateTime? date]) =>
      c.read(yearPeriodServiceProvider).fetchYearPeriod(date ?? _today);

  /// 期間内の支出合計（生活収支拠出）
  Future<int> expenseSumIn(PeriodValue period) async {
    final rows = await fakeExpenseRepository.fetchWithSourceCategory(
      incomeSourceBigId: AccountTypeConstants.living,
      period: period,
    );
    return rows.fold<int>(0, (sum, e) => sum + e.effectivePrice);
  }

  /// 期間内の収入合計
  Future<int> incomeSumIn(PeriodValue period) =>
      fakeIncomeRepository.calcurateSumWithPeriod(period: period);

  group('月次集計: 開始日の変更で境界レコードの所属月が移る（D-1）', () {
    test('変更前（開始日25）: 今月 8/25〜9/24 は e4 のみ・収入も i4 のみ', () async {
      final period = await monthPeriodOf(createSettingsContainer());

      expect(period.startDatetime, DateTime(2026, 8, 25));
      expect(period.endDatetime, DateTime(2026, 9, 24));
      expect(await expenseSumIn(period), 8000);
      expect(await incomeSumIn(period), 40000);
    });

    test('開始日を20に変更: 今月 8/20〜9/19 に e3 が移り合計 12,000', () async {
      final period = await monthPeriodOf(createSettingsContainer(startDay: 20));

      expect(period.startDatetime, DateTime(2026, 8, 20));
      expect(period.endDatetime, DateTime(2026, 9, 19));
      expect(await expenseSumIn(period), 4000 + 8000);
      expect(await incomeSumIn(period), 30000 + 40000);
    });

    test('開始日を1に変更: 今月 8/1〜8/31 は e3+e4、前月 7/1〜7/31 は e1+e2', () async {
      final container = createSettingsContainer(startDay: 1);
      final thisMonth = await monthPeriodOf(container);
      final lastMonth = await monthPeriodOf(container, DateTime(2026, 7, 15));

      expect(thisMonth.startDatetime, DateTime(2026, 8, 1));
      expect(thisMonth.endDatetime, DateTime(2026, 8, 31));
      expect(await expenseSumIn(thisMonth), 4000 + 8000);
      expect(lastMonth.startDatetime, DateTime(2026, 7, 1));
      expect(lastMonth.endDatetime, DateTime(2026, 7, 31));
      expect(await expenseSumIn(lastMonth), 1000 + 2000);
      expect(await incomeSumIn(lastMonth), 10000 + 20000);
    });

    test('開始日を28に変更: 今月 8/28〜9/27 は 0 で e4 は前月 7/28〜8/27 へ移る', () async {
      final container = createSettingsContainer(startDay: 28);
      final thisMonth = await monthPeriodOf(container);
      final lastMonth = await monthPeriodOf(container, DateTime(2026, 8, 10));

      expect(thisMonth.startDatetime, DateTime(2026, 8, 28));
      expect(thisMonth.endDatetime, DateTime(2026, 9, 27));
      expect(await expenseSumIn(thisMonth), 0);
      expect(await incomeSumIn(thisMonth), 0);
      expect(lastMonth.startDatetime, DateTime(2026, 7, 28));
      expect(lastMonth.endDatetime, DateTime(2026, 8, 27));
      // e3(8/24)・e4(8/25) が前月に入る
      expect(await expenseSumIn(lastMonth), 4000 + 8000);
    });

    test('開始日を 25→20→25 と戻すと変更前と同じ結果に戻る（設定変更は非破壊）', () async {
      final before = await expenseSumIn(
        await monthPeriodOf(createSettingsContainer(startDay: 25)),
      );
      final changed = await expenseSumIn(
        await monthPeriodOf(createSettingsContainer(startDay: 20)),
      );
      final restored = await expenseSumIn(
        await monthPeriodOf(createSettingsContainer(startDay: 25)),
      );

      expect(before, 8000);
      expect(changed, 12000);
      expect(restored, before);
    });

    test('どの開始日でも 7/24〜8/25 の4件は消えず増えない（総数不変）', () async {
      for (final startDay in [25, 20, 1, 28]) {
        final container = createSettingsContainer(startDay: startDay);
        // 7月度・8月度・9月度の3期間を合わせれば境界4件をすべて覆う
        final periods = [
          await monthPeriodOf(container, DateTime(2026, 7, 15)),
          await monthPeriodOf(container, DateTime(2026, 8, 15)),
          await monthPeriodOf(container, DateTime(2026, 9, 15)),
        ];
        // 隣り合う期間は重ならず隙間もない
        expect(
          periods[1].startDatetime,
          periods[0].endDatetime.add(const Duration(days: 1)),
          reason: '開始日$startDay: 7月度と8月度が連続していない',
        );
        expect(
          periods[2].startDatetime,
          periods[1].endDatetime.add(const Duration(days: 1)),
          reason: '開始日$startDay: 8月度と9月度が連続していない',
        );

        var count = 0;
        var sum = 0;
        for (final p in periods) {
          final rows = await fakeExpenseRepository.fetchWithSourceCategory(
            incomeSourceBigId: AccountTypeConstants.living,
            period: p,
          );
          count += rows.length;
          sum += rows.fold<int>(0, (s, e) => s + e.effectivePrice);
        }
        expect(count, 4, reason: '開始日$startDay: 境界4件の総数が変わった');
        expect(sum, 1000 + 2000 + 4000 + 8000, reason: '開始日$startDay');
        expect(fakeExpenseRepository.records, hasLength(6));
      }
    });
  });

  group('年度集計: 開始月の変更で年度の所属が移る（D-2）', () {
    test('変更前（4月25日始まり）: 今年度 2026/4/25〜2027/4/24 は e5 を含まない', () async {
      final period = await yearPeriodOf(createSettingsContainer());

      expect(period.startDatetime, DateTime(2026, 4, 25));
      expect(period.endDatetime, DateTime(2027, 4, 24));
      // e6 + e1〜e4
      expect(await expenseSumIn(period), 200 + 1000 + 2000 + 4000 + 8000);
    });

    test('開始月1・開始日1に変更: 今年度 2026/1/1〜12/31 に e5 が加わる', () async {
      final period = await yearPeriodOf(
        createSettingsContainer(startDay: 1, startMonth: 1),
      );

      expect(period.startDatetime, DateTime(2026, 1, 1));
      expect(period.endDatetime, DateTime(2026, 12, 31));
      expect(await expenseSumIn(period), 100 + 200 + 1000 + 2000 + 4000 + 8000);
    });

    test('開始月9に変更: 今年度 2025/9/25〜2026/9/24 は全件・翌年度は 0', () async {
      final container = createSettingsContainer(startMonth: 9);
      final thisYear = await yearPeriodOf(container);
      // 翌年度（2026/9/25〜2027/9/24）は 10/1 を含む年度として求める
      final nextYear = await yearPeriodOf(container, DateTime(2026, 10, 1));

      expect(thisYear.startDatetime, DateTime(2025, 9, 25));
      expect(thisYear.endDatetime, DateTime(2026, 9, 24));
      expect(await expenseSumIn(thisYear), 15300);
      expect(nextYear.startDatetime, DateTime(2026, 9, 25));
      expect(await expenseSumIn(nextYear), 0);
    });

    test('年間収支グラフ: 開始月1・開始日1 なら 1月始まりの12ヶ月が暦月で並ぶ', () async {
      // 合計額系はスタブ値方式なので、期間開始日のキーで「暦月の区切りで問い合わせたか」を検証する
      fakeExpenseRepository
          .totalExpenseByPeriodWithBigCategoryResultByPeriodStart
          .addAll({
            '20260701': 3000, // 7/1〜7/31 = e1+e2 と同じ区切り
            '20260801': 12000, // 8/1〜8/31 = e3+e4 と同じ区切り
          });
      final container = createSettingsContainer(startDay: 1, startMonth: 1);
      final yearPeriod = await yearPeriodOf(container);
      final dateScope = DateScopeEntity(
        selectedDate: _today,
        aggregationMonthPeriod: await monthPeriodOf(container),
        displayMonthPeriod: await monthPeriodOf(container),
        monthIndex: 7,
        representativeMonth: const MonthValue(month: '202608'),
        yearPeriod: yearPeriod,
        representativeYear: const YearValue(year: '2026'),
        periodStatus: PeriodStatus.current,
      );

      final chart = await container.read(
        annualBalanceChartNotifierProvider(dateScope).future,
      );

      expect(chart.monthlyBalanceValues, hasLength(12));
      expect(chart.monthlyBalanceValues.map((v) => v.month), [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
      ]);
      expect(chart.monthlyBalanceValues[6].monthlyExpense, 3000);
      expect(chart.monthlyBalanceValues[7].monthlyExpense, 12000);
      // 収入は records から集計される（暦月 8/1〜8/31 に i3+i4）
      expect(chart.monthlyBalanceValues[7].monthlyIncome, 30000 + 40000);
      expect(chart.monthlyBalanceValues[6].monthlyIncome, 10000 + 20000);
    });
  });
}
