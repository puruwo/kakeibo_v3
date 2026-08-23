import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_payment_history_summary.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';

void main() {
  // 支払日の新しい順（リポジトリの返却順と同じ）
  const history = [
    // 未確定（予想額 2,500）
    ExpenseEntity(
      id: 5,
      date: '20260825',
      price: null,
      fixedCostId: 1,
      isConfirmed: 0,
      estimatedPrice: 2500,
    ),
    ExpenseEntity(id: 4, date: '20260725', price: 2500, fixedCostId: 1),
    ExpenseEntity(id: 3, date: '20260625', price: 2500, fixedCostId: 1),
    ExpenseEntity(id: 2, date: '20251225', price: 2200, fixedCostId: 1),
    ExpenseEntity(id: 1, date: '20251125', price: 2200, fixedCostId: 1),
  ];

  group('FixedCostPaymentHistorySummary.fromHistory', () {
    test('合計・回数・平均は確定済みの行だけから算出する', () {
      final summary = FixedCostPaymentHistorySummary.fromHistory(history);

      // 未確定の 2,500 は含めない
      expect(summary.totalPrice, 2500 + 2500 + 2200 + 2200);
      expect(summary.confirmedCount, 4);
      expect(summary.averagePrice, 2350);
    });

    test('初回支払日は未確定も含めた最も古い支払日', () {
      final summary = FixedCostPaymentHistorySummary.fromHistory(history);

      expect(summary.firstPaymentDate, '20251125');
    });

    test('年ごとに新しい年が先頭でまとまり、年合計も確定分のみ', () {
      final summary = FixedCostPaymentHistorySummary.fromHistory(history);

      expect(summary.yearGroups.map((g) => g.year), ['2026', '2025']);
      expect(summary.yearGroups[0].records.map((e) => e.id), [5, 4, 3]);
      expect(summary.yearGroups[0].confirmedTotal, 5000);
      expect(summary.yearGroups[1].confirmedTotal, 4400);
    });

    test('確定行が0件なら平均は null・合計は 0', () {
      final summary = FixedCostPaymentHistorySummary.fromHistory(const [
        ExpenseEntity(
          id: 1,
          date: '20260825',
          price: null,
          fixedCostId: 1,
          isConfirmed: 0,
          estimatedPrice: 3000,
        ),
      ]);

      expect(summary.averagePrice, isNull);
      expect(summary.totalPrice, 0);
      expect(summary.confirmedCount, 0);
      expect(summary.yearGroups, hasLength(1));
    });

    test('履歴が空なら初回支払日は null でグループも空', () {
      final summary = FixedCostPaymentHistorySummary.fromHistory(const []);

      expect(summary.firstPaymentDate, isNull);
      expect(summary.yearGroups, isEmpty);
    });
  });
}
