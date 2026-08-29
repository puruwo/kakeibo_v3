// 固定費見込み算出ユースケースのロジックUT
//
// 見込みは2段構え（仕様 §7.3）:
//   ① 対象月に実績行がある固定費 → expenseの固定費行の実効金額
//   ② 未生成ぶん → fixed_cost.next_payment_date から周期展開
// 「next_payment_date が対象月内か」の単純判定は使わない。バッチは実績生成後に
// next_payment_date を次周期へ前進させるため、その判定だと当月分が常に0になる。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_forecast_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  // 支出大カテゴリー（1:住居 / 2:光熱費。表示順は 1 → 2）
  const bigCategories = [
    ExpenseBigCategoryEntity(
      id: 1,
      colorCode: 'FFAA00',
      bigCategoryName: '住居',
      resourcePath: 'assets/images/icon_home.svg',
      displayOrder: 1,
      isDisplayed: 1,
    ),
    ExpenseBigCategoryEntity(
      id: 2,
      colorCode: '00AAFF',
      bigCategoryName: '光熱費',
      resourcePath: 'assets/images/icon_bolt.svg',
      displayOrder: 2,
      isDisplayed: 1,
    ),
  ];

  // 支出小カテゴリー（11=家賃・12=保険 → 大1 / 21=電気 → 大2）
  const smallCategories = [
    ExpenseSmallCategoryEntity(
      id: 11,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '家賃',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 12,
      smallCategoryOrderKey: 2,
      bigCategoryKey: 1,
      displayedOrderInBig: 2,
      smallCategoryName: '保険',
      defaultDisplayed: 1,
    ),
    ExpenseSmallCategoryEntity(
      id: 21,
      smallCategoryOrderKey: 3,
      bigCategoryKey: 2,
      displayedOrderInBig: 1,
      smallCategoryName: '電気',
      defaultDisplayed: 1,
    ),
  ];

  /// 毎月の家賃80,000円（確定型・小カテゴリー11→大1）
  ///
  /// [nextPaymentDate] で「バッチ実行済み（8/1へ前進済み）」と
  /// 「未実行（7/1のまま）」を切り替える。
  FixedCostEntity rent({required String nextPaymentDate}) => FixedCostEntity(
    id: 10,
    name: '家賃',
    variable: 0,
    price: 80000,
    expenseSmallCategoryId: 11,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
    nextPaymentDate: nextPaymentDate,
  );

  /// 7/1に生成済みの家賃の実績行（確定済み）
  const generatedRent = ExpenseEntity(
    id: 100,
    date: '20250701',
    price: 80000,
    paymentCategoryId: 11,
    memo: '家賃',
    fixedCostId: 10,
    isConfirmed: 1,
  );

  ProviderContainer createForecastContainer({
    List<ExpenseEntity> expenses = const [],
    List<FixedCostEntity> fixedCosts = const [],
  }) {
    return createContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(
          FakeExpenseRepository(initialRecords: expenses),
        ),
        fixedCostRepositoryProvider.overrideWithValue(
          FakeFixedCostRepository(initialRecords: fixedCosts),
        ),
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseSmallCategoryRepository(initialRecords: smallCategories),
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          FakeExpenseBigCategoryRepository(initialRecords: bigCategories),
        ),
      ],
    );
  }

  group('FixedCostForecastUsecaseNotifier', () {
    test('当月バッチ実行済みなら実績行の実効金額が見込みになる', () async {
      // バッチが7/1の実績を生成し、next_payment_dateは8/1へ前進済み。
      // 「next_payment_dateが対象月内か」で判定すると0円になってしまうケース
      final container = createForecastContainer(
        expenses: const [generatedRent],
        fixedCosts: [rent(nextPaymentDate: '20250801')],
      );

      final result = await container.read(
        fixedCostForecastNotifierProvider(period).future,
      );

      expect(result.total, 80000);
      expect(result.byBigCategory, hasLength(1));
      expect(result.byBigCategory.single.expenseBigCategoryId, 1);
      expect(result.byBigCategory.single.bigCategoryName, '住居');
      expect(result.byBigCategory.single.amount, 80000);
    });

    test('当月バッチ未実行なら次回支払日から周期展開して見込みになる', () async {
      // 実績行はまだ無く、next_payment_dateが7/1のまま
      final container = createForecastContainer(
        fixedCosts: [rent(nextPaymentDate: '20250701')],
      );

      final result = await container.read(
        fixedCostForecastNotifierProvider(period).future,
      );

      expect(result.total, 80000);
      expect(result.amountOf(1), 80000);
    });

    test('実績行がある回は周期展開ぶんと二重計上されない', () async {
      // 7/1の実績があり、next_payment_dateも7/1のまま（バッチ途中の状態）
      final container = createForecastContainer(
        expenses: const [generatedRent],
        fixedCosts: [rent(nextPaymentDate: '20250701')],
      );

      final result = await container.read(
        fixedCostForecastNotifierProvider(period).future,
      );

      expect(result.total, 80000);
    });

    test('未確定の実績行は予想額で見込みに入る', () async {
      final container = createForecastContainer(
        expenses: const [
          ExpenseEntity(
            id: 101,
            date: '20250705',
            price: null,
            paymentCategoryId: 21,
            memo: '電気代',
            fixedCostId: 30,
            isConfirmed: 0,
            estimatedPrice: 6000,
          ),
        ],
        fixedCosts: const [
          FixedCostEntity(
            id: 30,
            name: '電気代',
            variable: 1,
            estimatedPrice: 6000,
            expenseSmallCategoryId: 21,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250105',
            nextPaymentDate: '20250805',
          ),
        ],
      );

      final result = await container.read(
        fixedCostForecastNotifierProvider(period).future,
      );

      expect(result.total, 6000);
      expect(result.amountOf(2), 6000);
    });

    test('変動型の未生成分はマスタの予想額が使われる', () async {
      // next_payment_dateが7/5で実績未生成。確定型ならprice、変動型ならestimated_price
      final container = createForecastContainer(
        fixedCosts: const [
          FixedCostEntity(
            id: 30,
            name: '電気代',
            variable: 1,
            // 変動型なのでpriceは使われない（使われたら9,999円になる）
            price: 9999,
            estimatedPrice: 6000,
            expenseSmallCategoryId: 21,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250105',
            nextPaymentDate: '20250705',
          ),
        ],
      );

      final result = await container.read(
        fixedCostForecastNotifierProvider(period).future,
      );

      expect(result.total, 6000);
    });

    test('隔月払いは対象月に支払日が来る回だけ計上される', () async {
      // 2ヶ月ごと・次回支払日6/10 → 6/10（期間前）→8/10（期間後）で
      // 6/25〜7/24 には1回も来ない
      const bimonthly = FixedCostEntity(
        id: 40,
        name: '2ヶ月ごとの点検',
        variable: 0,
        price: 5000,
        expenseSmallCategoryId: 12,
        intervalNumber: 2,
        intervalUnit: 1,
        firstPaymentDate: '20250210',
        nextPaymentDate: '20250610',
      );

      final outOfPeriod = await createForecastContainer(
        fixedCosts: const [bimonthly],
      ).read(fixedCostForecastNotifierProvider(period).future);
      expect(outOfPeriod.total, 0);
      expect(outOfPeriod.byBigCategory, isEmpty);

      // 次回支払日を7/10にすると期間内に1回来る
      final inPeriod = await createForecastContainer(
        fixedCosts: [bimonthly.copyWith(nextPaymentDate: '20250710')],
      ).read(fixedCostForecastNotifierProvider(period).future);
      expect(inPeriod.total, 5000);
    });

    test('年払いは支払月にだけ計上される（月割り平準化しない）', () async {
      const annual = FixedCostEntity(
        id: 50,
        name: '保険',
        variable: 0,
        price: 120000,
        expenseSmallCategoryId: 12,
        intervalNumber: 1,
        intervalUnit: 2,
        firstPaymentDate: '20240710',
        nextPaymentDate: '20250710',
      );

      final paymentMonth = await createForecastContainer(
        fixedCosts: const [annual],
      ).read(fixedCostForecastNotifierProvider(period).future);
      // 12分割の10,000円ではなく、支払月に全額が乗る
      expect(paymentMonth.total, 120000);

      // 支払月でない月（8/25〜9/24）は0円
      final otherMonth =
          await createForecastContainer(fixedCosts: const [annual]).read(
            fixedCostForecastNotifierProvider(
              PeriodValue(
                startDatetime: DateTime(2025, 8, 25),
                endDatetime: DateTime(2025, 9, 24),
              ),
            ).future,
          );
      expect(otherMonth.total, 0);
    });

    test('削除済み（delete_flag=1）のマスタは見込みに含まれない', () async {
      final container = createForecastContainer(
        fixedCosts: [rent(nextPaymentDate: '20250701').copyWith(deleteFlag: 1)],
      );

      final result = await container.read(
        fixedCostForecastNotifierProvider(period).future,
      );

      expect(result.total, 0);
      expect(result.byBigCategory, isEmpty);
    });

    test('大カテゴリー別に集約され、表示順に並ぶ', () async {
      final container = createForecastContainer(
        expenses: const [
          generatedRent,
          // 保険（小12）も大カテゴリー1に集約される
          ExpenseEntity(
            id: 102,
            date: '20250710',
            price: 30000,
            paymentCategoryId: 12,
            memo: '保険',
            fixedCostId: 20,
            isConfirmed: 1,
          ),
          // 電気代（小21）は大カテゴリー2
          ExpenseEntity(
            id: 103,
            date: '20250705',
            price: null,
            paymentCategoryId: 21,
            memo: '電気代',
            fixedCostId: 30,
            isConfirmed: 0,
            estimatedPrice: 6000,
          ),
        ],
        fixedCosts: [rent(nextPaymentDate: '20250801')],
      );

      final result = await container.read(
        fixedCostForecastNotifierProvider(period).future,
      );

      expect(result.total, 116000);
      expect(result.byBigCategory.map((e) => e.expenseBigCategoryId).toList(), [
        1,
        2,
      ]);
      expect(result.amountOf(1), 110000);
      expect(result.amountOf(2), 6000);
    });

    test('固定費が1件も無ければ見込みは0円で内訳も空', () async {
      final container = createForecastContainer();

      final result = await container.read(
        fixedCostForecastNotifierProvider(period).future,
      );

      expect(result.total, 0);
      expect(result.byBigCategory, isEmpty);
      expect(result.amountOf(1), 0);
    });
  });

  group('集計開始日の変更後の期間で見込みが再計算される（KP-005 D-4-2）', () {
    test('変更後の今月期間内に次回支払日が入る固定費だけが計上される', () async {
      // f1: 25日払い（next=8/25）/ f2: 10日払い（next=9/10）。実績行は無し
      final container = createForecastContainer(
        fixedCosts: [
          rent(nextPaymentDate: '20260825'),
          const FixedCostEntity(
            id: 30,
            name: '電気代',
            variable: 1,
            estimatedPrice: 3000,
            expenseSmallCategoryId: 21,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20260110',
            nextPaymentDate: '20260910',
          ),
        ],
      );

      // 旧区切り 8/25〜9/24: 両方入る
      final oldResult = await container.read(
        fixedCostForecastNotifierProvider(
          PeriodValue(
            startDatetime: DateTime(2026, 8, 25),
            endDatetime: DateTime(2026, 9, 24),
          ),
        ).future,
      );
      // 新区切り（開始日1）8/1〜8/31: 9/10 払いは翌月へ移る
      final newResult = await container.read(
        fixedCostForecastNotifierProvider(
          PeriodValue(
            startDatetime: DateTime(2026, 8, 1),
            endDatetime: DateTime(2026, 8, 31),
          ),
        ).future,
      );

      expect(oldResult.total, 80000 + 3000);
      expect(newResult.total, 80000);
      expect(newResult.amountOf(2), 0);
    });
  });
}
