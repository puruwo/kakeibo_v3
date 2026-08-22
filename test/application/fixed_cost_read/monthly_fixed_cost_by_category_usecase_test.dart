import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_by_category_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_confirmed_fixed_cost_tile_value/monthly_confirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';

import 'fixed_cost_read_fixtures.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  // 確定済みの電気代（7/10）。未確定の電気代（7/5）と同じ大カテゴリー2に入る
  const confirmedElectricity = ExpenseEntity(
    id: 105,
    date: '20250710',
    price: 7200,
    paymentCategoryId: 21,
    memo: '電気代',
    fixedCostId: 30,
    isConfirmed: 1,
    estimatedPrice: 6000,
  );

  group('MonthlyFixedCostByCategoryUsecaseNotifier', () {
    test('確定済みと未確定がタイルの型で区別されて同じグループに入る', () async {
      final container = createFixedCostReadContainer(
        expenses: const [
          fixtureConfirmedRent,
          confirmedElectricity,
          fixtureUnconfirmedElectricity,
        ],
      );

      final result = await container.read(
        monthlyFixedCostByCategoryNotifierProvider(period).future,
      );

      expect(result, hasLength(2));
      final utility = result.firstWhere((e) => e.expenseBigCategoryId == 2);
      expect(utility.items, hasLength(2));
      // 日付昇順なので 7/5 の未確定分が先、7/10 の確定分が後
      expect(utility.items.first, isA<MonthlyUnconfirmedFixedCostTileValue>());
      expect(utility.items.last, isA<MonthlyConfirmedFixedCostTileValue>());

      final housing = result.firstWhere((e) => e.expenseBigCategoryId == 1);
      expect(housing.items, hasLength(1));
      expect(housing.items.first, isA<MonthlyConfirmedFixedCostTileValue>());
    });

    test('グループのカテゴリー情報は支出大カテゴリーから引かれる', () async {
      final container = createFixedCostReadContainer(
        expenses: const [
          fixtureConfirmedRent,
          fixtureUnconfirmedElectricity,
        ],
      );

      final result = await container.read(
        monthlyFixedCostByCategoryNotifierProvider(period).future,
      );

      final housing = result.firstWhere((e) => e.expenseBigCategoryId == 1);
      expect(housing.categoryName, housing.items.first.categoryName);
      expect(housing.colorCode, housing.items.first.colorCode);
      expect(housing.resourcePath, housing.items.first.resourcePath);
      expect(housing.categoryName, '住居');

      final utility = result.firstWhere((e) => e.expenseBigCategoryId == 2);
      expect(utility.categoryName, '光熱費');
      expect(utility.resourcePath, 'assets/images/icon_utility.svg');
    });

    test('同じ大カテゴリーの別の小カテゴリーは1グループにまとまる', () async {
      // 家賃（小11）と保険（小12）はどちらも大カテゴリー1（住居）
      final container = createFixedCostReadContainer(
        expenses: const [fixtureConfirmedRent, fixtureConfirmedInsurance],
      );

      final result = await container.read(
        monthlyFixedCostByCategoryNotifierProvider(period).future,
      );

      expect(result, hasLength(1));
      expect(result.single.expenseBigCategoryId, 1);
      // 2行目に出す小カテゴリー名は行ごとに保持される（仕様 §8.5 案A）
      expect(
        result.single.items.map((e) => e.smallCategoryName).toList(),
        ['保険', '家賃'],
      );
    });

    test('未確定タイルのidはexpense行のid・fixedCostIdは固定費マスタIDになる', () async {
      final container = createFixedCostReadContainer(
        expenses: const [fixtureUnconfirmedElectricity],
      );

      final result = await container.read(
        monthlyFixedCostByCategoryNotifierProvider(period).future,
      );

      final tile =
          result.single.items.single as MonthlyUnconfirmedFixedCostTileValue;
      expect(tile.id, 101);
      expect(tile.fixedCostId, 30);
      expect(tile.estimatedPrice, 6000);
    });

    test('期間内に固定費行が無ければ空リストを返す', () async {
      final container = createFixedCostReadContainer();

      final result = await container.read(
        monthlyFixedCostByCategoryNotifierProvider(period).future,
      );

      expect(result, isEmpty);
    });
  });
}
