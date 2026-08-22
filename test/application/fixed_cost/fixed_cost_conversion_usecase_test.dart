// FixedCostConversionUsecase（既存の支出レコードの固定費化）のテスト
//
// 当該レコードから固定費マスタを作り、その行に fixed_cost_id を付与する。
// 過去分の遡及生成は行わず、次回支払日は今日より後の最初の支払日に進める
// （仕様 §6.2・§6.6）。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_conversion_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  // システム日時2025/7/6固定
  late FakeFixedCostRepository fakeFixedCostRepository;
  late FakeExpenseRepository fakeExpenseRepository;

  ProviderContainer createUsecaseContainer({
    List<ExpenseEntity>? expenses,
  }) {
    fakeExpenseRepository = FakeExpenseRepository(initialRecords: expenses);
    fakeFixedCostRepository = FakeFixedCostRepository(
      expenseRepository: fakeExpenseRepository,
    );
    return createContainer(
      overrides: [
        ...aggregationSettingOverrides(systemDate: DateTime(2025, 7, 6)),
        fixedCostRepositoryProvider.overrideWithValue(fakeFixedCostRepository),
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
      ],
    );
  }

  // 固定費化する支出レコード（7/1に5000円・小カテゴリー12）
  const targetRow = ExpenseEntity(
    id: 100,
    date: '20250701',
    price: 5000,
    paymentCategoryId: 12,
    memo: '電気代',
  );

  group('FixedCostConversionUsecase.convertToFixedCost のバリデーション', () {
    test('名称が空ならエラー', () async {
      final container = createUsecaseContainer(expenses: const [targetRow]);
      final usecase = container.read(fixedCostConversionUsecaseProvider);

      await expectLater(
        () => usecase.convertToFixedCost(
          expenseEntity: targetRow,
          name: '',
          variable: 0,
          intervalNumber: 1,
          intervalUnit: 1,
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '名前を入力してください',
          ),
        ),
      );
      expect(fakeFixedCostRepository.insertedEntities, isEmpty);
    });

    test('実額のない行（未確定行）は固定費化できない', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostConversionUsecaseProvider);

      await expectLater(
        () => usecase.convertToFixedCost(
          expenseEntity: targetRow.copyWith(price: null),
          name: '電気代',
          variable: 0,
          intervalNumber: 1,
          intervalUnit: 1,
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '0円以上で入力してください',
          ),
        ),
      );
    });

    test('支払い周期が不正ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostConversionUsecaseProvider);

      await expectLater(
        () => usecase.convertToFixedCost(
          expenseEntity: targetRow,
          name: '電気代',
          variable: 0,
          intervalNumber: 0,
          intervalUnit: 1,
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '支払い頻度を選択してください',
          ),
        ),
      );
    });

    test('すでに固定費化済みの行は再度固定費化できない', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostConversionUsecaseProvider);

      await expectLater(
        () => usecase.convertToFixedCost(
          expenseEntity: targetRow.copyWith(fixedCostId: 5),
          name: '電気代',
          variable: 0,
          intervalNumber: 1,
          intervalUnit: 1,
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'すでに固定費として登録されています',
          ),
        ),
      );
    });
  });

  group('FixedCostConversionUsecase.convertToFixedCost の登録処理', () {
    test('当該レコードの内容でマスタを作り、行にfixed_cost_idを付与する', () async {
      final container = createUsecaseContainer(expenses: const [targetRow]);
      final usecase = container.read(fixedCostConversionUsecaseProvider);

      await usecase.convertToFixedCost(
        expenseEntity: targetRow,
        name: '電気代',
        variable: 0,
        intervalNumber: 1,
        intervalUnit: 1,
      );

      expect(fakeFixedCostRepository.insertedEntities, hasLength(1));
      final master = fakeFixedCostRepository.insertedEntities.first;
      expect(master.name, '電気代');
      // カテゴリーは当該行の支出小カテゴリーを引き継ぐ
      expect(master.expenseSmallCategoryId, 12);
      // 旧列はT6で削除するまで0を入れておく
      expect(master.fixedCostCategoryId, 0);
      expect(master.price, 5000);
      // 推定額は当該行の金額で初期化する（仕様 §6.5）
      expect(master.estimatedPrice, 5000);
      expect(master.firstPaymentDate, '20250701');
      expect(master.recentPaymentDate, '20250701');

      // 当該行に fixed_cost_id が付き、確定済み扱いになる
      final row = fakeExpenseRepository.records.single;
      expect(row.fixedCostId, fakeFixedCostRepository.records.single.id);
      expect(row.isConfirmed, 1);
      expect(row.price, 5000);
    });

    test('次回支払日は今日より後の最初の支払日になる（遡及生成しない）', () async {
      // 3ヶ月前の支出を固定費化しても、4/1・5/1・6/1・7/1の実績は作らない
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostConversionUsecaseProvider);

      await usecase.convertToFixedCost(
        expenseEntity: targetRow.copyWith(date: '20250301'),
        name: '電気代',
        variable: 0,
        intervalNumber: 1,
        intervalUnit: 1,
      );

      // システム日時2025/7/6を超える最初の支払日
      expect(
        fakeFixedCostRepository.insertedEntities.first.nextPaymentDate,
        '20250801',
      );
      // 過去分の実績は生成されない
      expect(fakeExpenseRepository.insertedFixedCostExpenses, isEmpty);
    });

    test('支払日が今日ちょうどでも次の周期へ進める', () async {
      // 当該レコードの支払いは記録済みなので、同じ日を次回支払日にはしない
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostConversionUsecaseProvider);

      await usecase.convertToFixedCost(
        expenseEntity: targetRow.copyWith(date: '20250706'),
        name: '電気代',
        variable: 0,
        intervalNumber: 1,
        intervalUnit: 1,
      );

      expect(
        fakeFixedCostRepository.insertedEntities.first.nextPaymentDate,
        '20250806',
      );
    });

    test('年払いの固定費化も今日より後の支払日になる', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostConversionUsecaseProvider);

      await usecase.convertToFixedCost(
        expenseEntity: targetRow.copyWith(date: '20230510'),
        name: '年会費',
        variable: 0,
        intervalNumber: 1,
        intervalUnit: 2,
      );

      expect(
        fakeFixedCostRepository.insertedEntities.first.nextPaymentDate,
        '20260510',
      );
    });

    test('変動型は紐づいた確定行1件の金額が推定額になる', () async {
      final container = createUsecaseContainer(expenses: const [targetRow]);
      final usecase = container.read(fixedCostConversionUsecaseProvider);

      await usecase.convertToFixedCost(
        expenseEntity: targetRow,
        name: '電気代',
        variable: 1,
        intervalNumber: 1,
        intervalUnit: 1,
      );

      expect(fakeFixedCostRepository.records.single.estimatedPrice, 5000);
    });

    test('固定費化するとDBの更新回数がインクリメントされる', () async {
      final container = createUsecaseContainer(expenses: const [targetRow]);
      final usecase = container.read(fixedCostConversionUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);

      await usecase.convertToFixedCost(
        expenseEntity: targetRow,
        name: '電気代',
        variable: 0,
        intervalNumber: 1,
        intervalUnit: 1,
      );

      expect(dbCount.read(), 1);
    });
  });
}
