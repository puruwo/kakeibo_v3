import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_unconfirmed_fixed_cost_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';

import 'fixed_cost_read_fixtures.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  // 「未確定行のexpense id(=101)と同じidを持つ別マスタ」。
  // idを取り違えるとこちらの情報（想定額999円）がタイルに載ってしまう
  const decoyMaster = FixedCostEntity(
    id: 101,
    name: '別の固定費',
    variable: 1,
    estimatedPrice: 999,
    fixedCostCategoryId: 2,
    expenseSmallCategoryId: 21,
    intervalNumber: 2,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
  );

  group('MonthlyUnconfirmedFixedCostUsecaseNotifier', () {
    test('未確定（isConfirmed=0）の固定費行だけタイル化される', () async {
      final container = createFixedCostReadContainer(
        expenses: const [fixtureConfirmedRent, fixtureUnconfirmedElectricity],
      );

      final result = await container.read(
        monthlyUnconfirmedFixedCostNotifierProvider(period).future,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 101);
      expect(result.first.name, '電気代');
      expect(result.first.date, DateTime(2025, 7, 5));
    });

    test('未確定行の予想額と支出カテゴリー情報がタイルに載る', () async {
      final container = createFixedCostReadContainer(
        expenses: const [fixtureUnconfirmedElectricity],
      );

      final result = await container.read(
        monthlyUnconfirmedFixedCostNotifierProvider(period).future,
      );

      expect(result.first.estimatedPrice, 6000);
      expect(result.first.categoryName, '光熱費');
      expect(result.first.smallCategoryName, '電気');
      expect(result.first.frequencyLabel, '毎月');
    });

    test('タイルのidはexpense行のid・fixedCostIdは固定費マスタIDになる', () async {
      final container = createFixedCostReadContainer(
        expenses: const [fixtureUnconfirmedElectricity],
        fixedCosts: [...fixtureFixedCosts, decoyMaster],
      );

      final result = await container.read(
        monthlyUnconfirmedFixedCostNotifierProvider(period).future,
      );

      // 確定操作は id で expense 行を更新し、fixedCostId で想定額を再計算する。
      // 取り違えると別マスタ（id=101）の情報が載る
      expect(result.first.id, 101);
      expect(result.first.fixedCostId, 30);
      expect(result.first.estimatedPrice, isNot(999));
    });

    test('期間内に未確定の固定費行が無ければ空リストを返す', () async {
      final container = createFixedCostReadContainer(
        expenses: const [fixtureConfirmedRent],
      );

      final result = await container.read(
        monthlyUnconfirmedFixedCostNotifierProvider(period).future,
      );

      expect(result, isEmpty);
    });
  });
}
