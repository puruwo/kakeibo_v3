import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/monthly_fixed_cost_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';

import 'fixed_cost_read_fixtures.dart';

void main() {
  // 集計期間は2025/6/25〜2025/7/24
  final period = PeriodValue(
    startDatetime: DateTime(2025, 6, 25),
    endDatetime: DateTime(2025, 7, 24),
  );

  group('MonthlyFixedCostUsecaseNotifier', () {
    test('確定済み（isConfirmed=1）の固定費行だけタイル化される', () async {
      final container = createFixedCostReadContainer(
        expenses: const [fixtureConfirmedRent, fixtureUnconfirmedElectricity],
      );

      final result = await container.read(
        monthlyFixedCostNotifierProvider(period).future,
      );

      expect(result, hasLength(1));
      // タイルのidはexpense行のid（T2の申し送り: 確定操作がこの行を指す）
      expect(result.first.id, 100);
      expect(result.first.name, '家賃');
      expect(result.first.price, 80000);
    });

    test('通常支出（fixed_cost_idがNULL）はタイル化されない', () async {
      final container = createFixedCostReadContainer(
        expenses: const [
          fixtureConfirmedRent,
          ExpenseEntity(
            id: 200,
            date: '20250702',
            price: 1200,
            paymentCategoryId: 11,
            memo: 'ランチ',
          ),
        ],
      );

      final result = await container.read(
        monthlyFixedCostNotifierProvider(period).future,
      );

      expect(result.map((e) => e.id).toList(), [100]);
    });

    test('固定費マスタと支出カテゴリーの情報が結合される', () async {
      final container = createFixedCostReadContainer(
        expenses: const [fixtureConfirmedInsurance, fixtureConfirmedRent],
      );

      final result = await container.read(
        monthlyFixedCostNotifierProvider(period).future,
      );

      // 日付昇順で返るため 6/30 の保険が先頭・7/1 の家賃が末尾
      expect(result, hasLength(2));
      final rent = result.last;
      expect(rent.variable, 0);
      expect(rent.intervalNumber, 1);
      expect(rent.intervalUnit, 1);
      expect(rent.nextPaymentDate, '20250801');
      // カテゴリー情報は支出カテゴリー（大→小）から引く
      expect(rent.categoryName, '住居');
      expect(rent.smallCategoryName, '家賃');
      expect(rent.colorCode, 'FFAA00');
      expect(rent.resourcePath, 'assets/images/icon_home.svg');
      // 支払い頻度はマスタの間隔からラベル化される
      expect(rent.frequencyLabel, '毎月');
      expect(result.first.frequencyLabel, '毎年');
    });

    test('yyyyMMddの日付文字列がDateTimeに変換される', () async {
      final container = createFixedCostReadContainer(
        expenses: const [fixtureConfirmedRent],
      );

      final result = await container.read(
        monthlyFixedCostNotifierProvider(period).future,
      );

      expect(result.first.date, DateTime(2025, 7, 1));
    });

    test('期間内に固定費行が無ければ空リストを返す', () async {
      final container = createFixedCostReadContainer();

      final result = await container.read(
        monthlyFixedCostNotifierProvider(period).future,
      );

      expect(result, isEmpty);
    });
  });
}
