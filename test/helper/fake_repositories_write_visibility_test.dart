import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';

import 'fake_repositories.dart';

/// Fakeの書き込み系が「本物と同じように取得系へ反映されるか」の回帰テスト。
///
/// 本物のDBは書き込み直後からSELECTの対象になる（消えた／変わったが見える）ため、
/// Fakeが記録用リストへ積むだけだと本物より甘くなり、
/// 「削除したら一覧から消える」類の検証が素通りする。
///
/// ここでは usecase 経由のテストでは見えない「状態への反映」を扱う
/// （FixedCostUsecase.delete のテストは deleteWithUnpaidExpenses へ渡した
/// 引数の記録しか検証しないため、論理削除が取得系に効くかはここで押さえる）。
void main() {
  // 固定費マスタの雛形。id と deleteFlag だけをテストごとに変える
  const template = FixedCostEntity(
    id: 0,
    name: '家賃',
    variable: 0,
    price: 80000,
    intervalNumber: 1,
    intervalUnit: 0,
    firstPaymentDate: '20250625',
    recentPaymentDate: null,
    nextPaymentDate: null,
    deleteFlag: 0,
  );

  group('FakeFixedCostRepository.deleteWithUnpaidExpenses', () {
    // 運用日付。Fakeは実績を持たないためマスタ側の論理削除だけに効く
    const today = '20250706';

    test('削除したマスタは fetchAllActive に含まれない（論理削除）', () async {
      // ID=10（削除対象）とID=11（残る方）を区別できるよう2件置く
      final repository = FakeFixedCostRepository(
        initialRecords: [
          template.copyWith(id: 10),
          template.copyWith(id: 11, name: '通信費'),
        ],
      );

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      final active = await repository.fetchAllActive();
      expect(active.map((e) => e.id), [11]);
    });

    test('論理削除なのでレコード自体は残り deleteFlag が1になる', () async {
      // 本物は DELETE ではなく delete_flag=1 の UPDATE のため、行は消えない
      final repository = FakeFixedCostRepository(
        initialRecords: [template.copyWith(id: 10)],
      );

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      expect(repository.records, hasLength(1));
      expect(repository.records.single.deleteFlag, 1);
      // 検証用の記録リストは従来どおり残す
      expect(repository.deletedWithUnpaidExpensesArgs, [
        (id: 10, today: today),
      ]);
    });

    test('連動する支出Fakeを渡すと未払い実績も取得系から消える', () async {
      // 本物はマスタの論理削除とexpenseの未払い行削除を1トランザクションで行う
      final expenseRepository = FakeExpenseRepository(
        initialRecords: const [
          // 支払日到来済みの確定行（残る）
          ExpenseEntity(id: 1, date: '20250705', price: 1000, fixedCostId: 10),
          // 未確定行（消える）
          ExpenseEntity(
            id: 2,
            date: '20250705',
            price: null,
            fixedCostId: 10,
            isConfirmed: 0,
            estimatedPrice: 1000,
          ),
          // 支払日未到来の確定行（消える）
          ExpenseEntity(id: 3, date: '20250710', price: 1000, fixedCostId: 10),
        ],
      );
      final repository = FakeFixedCostRepository(
        initialRecords: [template.copyWith(id: 10)],
        expenseRepository: expenseRepository,
      );

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      expect(expenseRepository.records.map((e) => e.id), [1]);
    });
  });

  group('FakeExpenseRepository の固定費系クエリ', () {
    /// 固定費行の雛形（マスタID=10に紐づく）
    const fixedCostRow = ExpenseEntity(
      id: 1,
      date: '20250701',
      price: null,
      paymentCategoryId: 12,
      fixedCostId: 10,
      isConfirmed: 0,
      estimatedPrice: 5000,
    );

    test('挿入した固定費行は直後の重複判定・期間取得から見える', () async {
      final repository = FakeExpenseRepository();

      final id = await repository.insertFixedCostRecord(fixedCostRow);

      expect(id, isPositive);
      expect(
        await repository.existsByFixedCostIdAndDate(
          fixedCostId: 10,
          date: '20250701',
        ),
        isTrue,
      );
      final unconfirmed = await repository
          .fetchUnconfirmedFixedCostRecordByPeriod(
            period: PeriodValue(
              startDatetime: DateTime(2025, 6, 25),
              endDatetime: DateTime(2025, 7, 24),
            ),
          );
      expect(unconfirmed, hasLength(1));
    });

    test('確定させた行は未確定一覧から消え、平均の根拠に入る', () async {
      final repository = FakeExpenseRepository(
        initialRecords: const [fixedCostRow],
      );

      await repository.confirmFixedCostRecord(id: 1, price: 6000);

      final unconfirmed = await repository
          .fetchUnconfirmedFixedCostRecordByPeriod(
            period: PeriodValue(
              startDatetime: DateTime(2025, 6, 25),
              endDatetime: DateTime(2025, 7, 24),
            ),
          );
      expect(unconfirmed, isEmpty);
      expect(
        await repository.fetchConfirmedFixedCostPriceAverage(fixedCostId: 10),
        6000,
      );
    });

    test('確定行が0件なら平均はnull（更新しない判定に使う）', () async {
      final repository = FakeExpenseRepository(
        initialRecords: const [fixedCostRow],
      );

      expect(
        await repository.fetchConfirmedFixedCostPriceAverage(fixedCostId: 10),
        isNull,
      );
    });

    test('カテゴリー一括変更は同じマスタの行にだけ効く', () async {
      final repository = FakeExpenseRepository(
        initialRecords: const [
          fixedCostRow,
          ExpenseEntity(
            id: 2,
            date: '20250701',
            price: 500,
            paymentCategoryId: 12,
            fixedCostId: 11,
          ),
          // 通常支出（fixed_cost_id が NULL）は対象外
          ExpenseEntity(id: 3, date: '20250701', price: 300,
              paymentCategoryId: 12),
        ],
      );

      await repository.updateSmallCategoryByFixedCostId(
        fixedCostId: 10,
        expenseSmallCategoryId: 33,
      );

      expect(
        repository.records.map((e) => e.paymentCategoryId),
        [33, 12, 12],
      );
    });
  });
}
