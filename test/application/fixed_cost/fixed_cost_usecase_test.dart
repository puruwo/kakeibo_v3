import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // システム日時2025/7/6固定 → 今の集計期間は6/25〜7/24
  late FakeFixedCostRepository fakeFixedCostRepository;
  late FakeExpenseRepository fakeExpenseRepository;
  late FakeFixedCostExpenseRepository fakeFixedCostExpenseRepository;

  ProviderContainer createUsecaseContainer({
    List<FixedCostEntity>? initialRecords,
    List<ExpenseEntity>? initialExpenses,
  }) {
    fakeExpenseRepository = FakeExpenseRepository(
      initialRecords: initialExpenses,
    );
    fakeFixedCostRepository = FakeFixedCostRepository(
      initialRecords: initialRecords,
      expenseRepository: fakeExpenseRepository,
    );
    fakeFixedCostExpenseRepository = FakeFixedCostExpenseRepository();
    return createContainer(
      overrides: [
        ...aggregationSettingOverrides(systemDate: DateTime(2025, 7, 6)),
        fixedCostRepositoryProvider.overrideWithValue(fakeFixedCostRepository),
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
        // T6までは多重生成防止で旧テーブルも検査するため、Fakeを積んでおく
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          fakeFixedCostExpenseRepository,
        ),
      ],
    );
  }

  // バリデーションが通る基本の登録エンティティ（初回支払いは今月の期間内）
  // カテゴリーの参照先は支出小カテゴリー（仕様 §3）
  const validEntity = FixedCostEntity(
    name: 'サブスク',
    variable: 0,
    price: 1000,
    fixedCostCategoryId: 1,
    expenseSmallCategoryId: 11,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250710',
  );

  group('FixedCostUsecase.add のバリデーション', () {
    test('初回支払日が今の集計期間より前ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () => usecase.add(
          fixedCostEntity: validEntity.copyWith(firstPaymentDate: '20250624'),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '今月の集計期間以降の日付を入力してください',
          ),
        ),
      );
    });

    test('名前が空ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () => usecase.add(fixedCostEntity: validEntity.copyWith(name: '')),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '名前を入力してください',
          ),
        ),
      );
    });

    test('固定額で金額0円以下ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () => usecase.add(fixedCostEntity: validEntity.copyWith(price: 0)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '0円以上で入力してください',
          ),
        ),
      );
    });

    test('金額が上限（99,999,999円）以上ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () =>
            usecase.add(fixedCostEntity: validEntity.copyWith(price: 99999999)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '金額の入力値が大き過ぎます',
          ),
        ),
      );
    });

    test('支出小カテゴリー未選択ならエラー', () async {
      // 旧列 fixedCostCategoryId が入っていても、判定に使うのは小カテゴリーID
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () => usecase.add(
          fixedCostEntity: validEntity.copyWith(expenseSmallCategoryId: 0),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'カテゴリーを選択してください',
          ),
        ),
      );
    });

    test('変動額（variable=1）は金額0円でも登録できる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.add(
        fixedCostEntity: validEntity.copyWith(variable: 1, price: 0),
      );

      expect(fakeFixedCostRepository.insertedEntities, hasLength(1));
    });
  });

  group('FixedCostUsecase.add の登録処理', () {
    test('初回支払いが今月内なら支払予定日を進めてexpenseに実績も作成する', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.add(fixedCostEntity: validEntity);

      // マスタ: 次回支払日=初回+1ヶ月、最近支払日=初回
      expect(fakeFixedCostRepository.insertedEntities, hasLength(1));
      final master = fakeFixedCostRepository.insertedEntities.first;
      expect(master.recentPaymentDate, '20250710');
      expect(master.nextPaymentDate, '20250810');

      // 実績: 初回支払日でexpenseに1件生成される
      expect(fakeExpenseRepository.insertedFixedCostExpenses, hasLength(1));
      final expense = fakeExpenseRepository.insertedFixedCostExpenses.first;
      expect(expense.date, '20250710');
      expect(expense.price, 1000);
      expect(expense.paymentCategoryId, 11);
      expect(expense.isConfirmed, 1);

      // 旧テーブルへの書き込みは停止している
      expect(fakeFixedCostExpenseRepository.insertedEntities, isEmpty);
    });

    test('初回支払いが来月以降なら実績は作らず初回日を次回支払日に設定する', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.add(
        fixedCostEntity: validEntity.copyWith(firstPaymentDate: '20250801'),
      );

      expect(fakeFixedCostRepository.insertedEntities, hasLength(1));
      final master = fakeFixedCostRepository.insertedEntities.first;
      expect(master.nextPaymentDate, '20250801');
      expect(master.recentPaymentDate, isNull);

      // 今月の支払いはないので実績は生成されない
      expect(fakeExpenseRepository.insertedFixedCostExpenses, isEmpty);
    });
  });

  group('FixedCostUsecase.addExpenseForFixedCost（バッチの1ヶ月分処理）', () {
    final period = PeriodValue(
      startDatetime: DateTime(2025, 6, 25),
      endDatetime: DateTime(2025, 7, 24),
    );

    test('期間内に支払予定のある固定費だけ実績を作成しマスタの支払日を進める', () async {
      final container = createUsecaseContainer(
        initialRecords: const [
          // 期間内の支払い（対象）
          FixedCostEntity(
            id: 1,
            name: '家賃',
            variable: 0,
            price: 80000,
            fixedCostCategoryId: 1,
            expenseSmallCategoryId: 11,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20250701',
          ),
          // 期間外の支払い（対象外）
          FixedCostEntity(
            id: 2,
            name: '保険',
            variable: 0,
            price: 5000,
            fixedCostCategoryId: 1,
            expenseSmallCategoryId: 11,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20250801',
          ),
          // 期間内だが削除済み（対象外）
          FixedCostEntity(
            id: 3,
            name: '解約済みサブスク',
            variable: 0,
            price: 500,
            fixedCostCategoryId: 1,
            expenseSmallCategoryId: 11,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20250710',
            deleteFlag: 1,
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      // 実績は期間内の1件だけ生成される
      expect(fakeExpenseRepository.insertedFixedCostExpenses, hasLength(1));
      final expense = fakeExpenseRepository.insertedFixedCostExpenses.first;
      expect(expense.fixedCostId, 1);
      expect(expense.date, '20250701');
      expect(expense.price, 80000);

      // マスタは支払予定日が1ヶ月進む
      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      final updated = fakeFixedCostRepository.updatedEntities.first;
      expect(updated.id, 1);
      expect(updated.recentPaymentDate, '20250701');
      expect(updated.nextPaymentDate, '20250801');
    });

    test('変動額の固定費は実額なし・予想額つきの未確定の実績が作られる', () async {
      final container = createUsecaseContainer(
        initialRecords: const [
          FixedCostEntity(
            id: 4,
            name: '電気代',
            variable: 1,
            price: 0,
            estimatedPrice: 6000,
            fixedCostCategoryId: 2,
            expenseSmallCategoryId: 12,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20250705',
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(fakeExpenseRepository.insertedFixedCostExpenses, hasLength(1));
      final expense = fakeExpenseRepository.insertedFixedCostExpenses.first;
      expect(expense.price, isNull);
      expect(expense.estimatedPrice, 6000);
      expect(expense.isConfirmed, 0);
    });

    test('期間内に支払予定がなければ何もしない', () async {
      final container = createUsecaseContainer(initialRecords: const []);
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.addExpenseForFixedCost(period);

      expect(fakeExpenseRepository.insertedFixedCostExpenses, isEmpty);
      expect(fakeFixedCostRepository.updatedEntities, isEmpty);
    });
  });

  group('FixedCostUsecase.updateEstimatedPrice', () {
    // 変動固定費のマスタ雛形（推定額の再計算対象）
    const variableMaster = FixedCostEntity(
      id: 5,
      name: '電気代',
      variable: 1,
      price: 0,
      estimatedPrice: 5000,
      fixedCostCategoryId: 2,
      expenseSmallCategoryId: 12,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    );

    /// 確定済みの固定費行（実額あり）
    ExpenseEntity confirmedRow({
      required int id,
      required int price,
      int fixedCostId = 5,
      String date = '20250601',
    }) => ExpenseEntity(
      id: id,
      date: date,
      price: price,
      paymentCategoryId: 12,
      fixedCostId: fixedCostId,
      isConfirmed: 1,
    );

    test('変動額の固定費は確定行の平均で想定額を更新する', () async {
      // 6000と7001の平均は6500.5 → 切り捨てて6500
      final container = createUsecaseContainer(
        initialRecords: const [variableMaster],
        initialExpenses: [
          confirmedRow(id: 100, price: 6000),
          confirmedRow(id: 101, price: 7001, date: '20250701'),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.updateEstimatedPrice(fixedCostId: 5);

      expect(
        fakeFixedCostRepository.records.single.estimatedPrice,
        6500,
      );
    });

    test('再計算後は未確定行の予想額も同期される', () async {
      final container = createUsecaseContainer(
        initialRecords: const [variableMaster],
        initialExpenses: [
          confirmedRow(id: 100, price: 8000),
          // 同じマスタの未確定行（同期の対象）
          const ExpenseEntity(
            id: 101,
            date: '20250705',
            price: null,
            paymentCategoryId: 12,
            fixedCostId: 5,
            isConfirmed: 0,
            estimatedPrice: 5000,
          ),
          // 別マスタの未確定行（同期の対象外）
          const ExpenseEntity(
            id: 102,
            date: '20250705',
            price: null,
            paymentCategoryId: 13,
            fixedCostId: 9,
            isConfirmed: 0,
            estimatedPrice: 3000,
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.updateEstimatedPrice(fixedCostId: 5);

      expect(
        fakeExpenseRepository.records
            .firstWhere((e) => e.id == 101)
            .estimatedPrice,
        8000,
      );
      expect(
        fakeExpenseRepository.records
            .firstWhere((e) => e.id == 102)
            .estimatedPrice,
        3000,
      );
      // 実額には書き込まない（実績の誤上書き防止。仕様 §6.5）
      expect(
        fakeExpenseRepository.records.firstWhere((e) => e.id == 101).price,
        isNull,
      );
    });

    test('固定額の固定費は何もしない', () async {
      final container = createUsecaseContainer(
        initialRecords: const [
          FixedCostEntity(
            id: 6,
            name: '家賃',
            variable: 0,
            price: 80000,
            fixedCostCategoryId: 1,
            expenseSmallCategoryId: 11,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
          ),
        ],
        initialExpenses: [confirmedRow(id: 100, price: 90000, fixedCostId: 6)],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.updateEstimatedPrice(fixedCostId: 6);

      expect(fakeFixedCostRepository.updatedEntities, isEmpty);
    });

    test('確定行が0件なら想定額を更新しない（最後の値を保持する）', () async {
      // 現行の「実績なし時は更新なし」を踏襲する（仕様 §6.5 のフォールバック）
      final container = createUsecaseContainer(
        initialRecords: const [variableMaster],
        initialExpenses: const [
          // 未確定行しかない＝平均の根拠が無い
          ExpenseEntity(
            id: 100,
            date: '20250705',
            price: null,
            paymentCategoryId: 12,
            fixedCostId: 5,
            isConfirmed: 0,
            estimatedPrice: 5000,
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.updateEstimatedPrice(fixedCostId: 5);

      expect(fakeFixedCostRepository.updatedEntities, isEmpty);
      expect(fakeFixedCostRepository.records.single.estimatedPrice, 5000);
    });

    test('更新されるのは指定したIDのマスタだけ', () async {
      // 支出IDとマスタIDの取り違えで別マスタを書き換えないことの確認
      final container = createUsecaseContainer(
        initialRecords: [
          variableMaster.copyWith(id: 8),
          variableMaster.copyWith(id: 9, name: 'ガス代', estimatedPrice: 3000),
        ],
        initialExpenses: [confirmedRow(id: 100, price: 8000, fixedCostId: 8)],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.updateEstimatedPrice(fixedCostId: 8);

      expect(fakeFixedCostRepository.updatedEntities.single.id, 8);
      // 別マスタの想定額は据え置き
      expect(
        fakeFixedCostRepository.records
            .firstWhere((e) => e.id == 9)
            .estimatedPrice,
        3000,
      );
    });

    test('存在しないIDなら既定エンティティのvariable=0で何もしない', () async {
      // fetchは該当なしのときid:0・variable:0の既定エンティティを返す
      final container = createUsecaseContainer(initialRecords: const []);
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.updateEstimatedPrice(fixedCostId: 999);

      expect(fakeFixedCostRepository.updatedEntities, isEmpty);
    });
  });

  group('FixedCostUsecase.edit', () {
    const originalEntity = FixedCostEntity(
      id: 7,
      name: 'ジム',
      variable: 0,
      price: 10000,
      fixedCostCategoryId: 1,
      expenseSmallCategoryId: 11,
      intervalNumber: 1,
      intervalUnit: 1,
      firstPaymentDate: '20250101',
    );

    test('変更がなければエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      expect(
        () => usecase.edit(
          originalEntity: originalEntity,
          editEntity: originalEntity,
        ),
        throwsA(
          isA<AppException>().having((e) => e.message, 'message', '変更がありません'),
        ),
      );
    });

    test('カテゴリー変更なしの編集はマスタ更新のみ', () async {
      final container = createUsecaseContainer(
        initialRecords: const [originalEntity],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.edit(
        originalEntity: originalEntity,
        editEntity: originalEntity.copyWith(price: 12000),
      );

      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      expect(fakeFixedCostRepository.updatedEntities.first.price, 12000);
      // 過去実績のカテゴリー書き換えは発生しない
      expect(fakeExpenseRepository.changedCategoryArgs, isEmpty);
    });

    test('カテゴリー変更ありの編集は過去実績のカテゴリーも一括変更する', () async {
      final container = createUsecaseContainer(
        initialRecords: const [originalEntity],
        // 過去実績2件（マスタID=7に紐づく）
        initialExpenses: const [
          ExpenseEntity(
            id: 100,
            date: '20250501',
            price: 10000,
            paymentCategoryId: 11,
            fixedCostId: 7,
          ),
          ExpenseEntity(
            id: 101,
            date: '20250601',
            price: 10000,
            paymentCategoryId: 11,
            fixedCostId: 7,
          ),
          // 別マスタの実績（変更対象外）
          ExpenseEntity(
            id: 102,
            date: '20250601',
            price: 500,
            paymentCategoryId: 11,
            fixedCostId: 8,
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.edit(
        originalEntity: originalEntity,
        editEntity: originalEntity.copyWith(expenseSmallCategoryId: 33),
      );

      // 過去実績2件が新カテゴリーに更新される
      expect(fakeExpenseRepository.changedCategoryArgs, [
        (fixedCostId: 7, expenseSmallCategoryId: 33),
      ]);
      expect(
        fakeExpenseRepository.records
            .where((e) => e.fixedCostId == 7)
            .map((e) => e.paymentCategoryId),
        everyElement(33),
      );
      // 別マスタの実績は据え置き
      expect(
        fakeExpenseRepository.records
            .firstWhere((e) => e.id == 102)
            .paymentCategoryId,
        11,
      );
      // マスタも更新される
      expect(
        fakeFixedCostRepository.updatedEntities.single.expenseSmallCategoryId,
        33,
      );
    });

    test('マスタの推定額を手動編集すると未確定行の予想額も同期される', () async {
      final container = createUsecaseContainer(
        initialRecords: const [originalEntity],
        initialExpenses: const [
          ExpenseEntity(
            id: 100,
            date: '20250705',
            price: null,
            paymentCategoryId: 11,
            fixedCostId: 7,
            isConfirmed: 0,
            estimatedPrice: 5000,
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.edit(
        originalEntity: originalEntity,
        editEntity: originalEntity.copyWith(estimatedPrice: 9000),
      );

      expect(
        fakeExpenseRepository.records.single.estimatedPrice,
        9000,
      );
    });
  });

  group('FixedCostUsecase.delete', () {
    test('deleteWithUnpaidExpensesに委譲し、運用日付を基準日として渡す', () async {
      // 単なる論理削除ではなく、未払い実績の連動削除とセットで委譲する（→ ADR-007）
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.delete(id: 42);

      // 基準シナリオのシステム日時 2025/7/6 が today として渡る
      expect(fakeFixedCostRepository.deletedWithUnpaidExpensesArgs, [
        (id: 42, today: '20250706'),
      ]);
    });

    test('未確定行と支払日未到来の確定行は消え、到来済みの確定行は残る', () async {
      // 支払日が到来済みの記録は、実際に払った事実として履歴に残す（→ ADR-007）
      final container = createUsecaseContainer(
        initialRecords: const [
          FixedCostEntity(
            id: 42,
            name: 'サブスク',
            variable: 1,
            fixedCostCategoryId: 1,
            expenseSmallCategoryId: 11,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
          ),
        ],
        initialExpenses: const [
          // 到来済みの確定行（残る）
          ExpenseEntity(
            id: 100,
            date: '20250705',
            price: 1000,
            paymentCategoryId: 11,
            fixedCostId: 42,
          ),
          // 運用日付ちょうどの確定行（境界値・残る）
          ExpenseEntity(
            id: 101,
            date: '20250706',
            price: 1000,
            paymentCategoryId: 11,
            fixedCostId: 42,
          ),
          // 支払日未到来の確定行（消える）
          ExpenseEntity(
            id: 102,
            date: '20250707',
            price: 1000,
            paymentCategoryId: 11,
            fixedCostId: 42,
          ),
          // 到来済みだが未確定の行（消える）
          ExpenseEntity(
            id: 103,
            date: '20250701',
            price: null,
            paymentCategoryId: 11,
            fixedCostId: 42,
            isConfirmed: 0,
            estimatedPrice: 1000,
          ),
          // 別マスタの未確定行（残る）
          ExpenseEntity(
            id: 104,
            date: '20250701',
            price: null,
            paymentCategoryId: 11,
            fixedCostId: 43,
            isConfirmed: 0,
            estimatedPrice: 1000,
          ),
        ],
      );
      final usecase = container.read(fixedCostUsecaseProvider);

      await usecase.delete(id: 42);

      expect(fakeExpenseRepository.records.map((e) => e.id), [100, 101, 104]);
      // 残った確定行の fixed_cost_id は保持する（通常支出化しない。仕様 §6.4）
      expect(
        fakeExpenseRepository.records.first.fixedCostId,
        42,
      );
      // マスタは論理削除
      expect(fakeFixedCostRepository.records.single.deleteFlag, 1);
    });
  });
}
