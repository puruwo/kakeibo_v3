import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_expense/fixed_cost_expense_usecase.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

void main() {
  late FakeFixedCostRepository fakeFixedCostRepository;
  late FakeFixedCostExpenseRepository fakeFixedCostExpenseRepository;

  ProviderContainer createUsecaseContainer({
    List<FixedCostEntity>? fixedCosts,
    List<FixedCostExpenseEntity>? fixedCostExpenses,
  }) {
    fakeFixedCostRepository = FakeFixedCostRepository(
      initialRecords: fixedCosts,
    );
    fakeFixedCostExpenseRepository = FakeFixedCostExpenseRepository(
      initialRecords: fixedCostExpenses,
    );
    return createContainer(
      overrides: [
        fixedCostRepositoryProvider.overrideWithValue(fakeFixedCostRepository),
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          fakeFixedCostExpenseRepository,
        ),
      ],
    );
  }

  // 未確定タイル（id=固定費支出ID、fixedCostId=固定費マスタID）
  MonthlyUnconfirmedFixedCostTileValue buildTile({
    int id = 100,
    int fixedCostId = 10,
  }) {
    return MonthlyUnconfirmedFixedCostTileValue(
      id: id,
      date: DateTime(2025, 7, 10),
      fixedCostId: fixedCostId,
      name: '電気代',
      variable: 1,
      intervalNumber: 1,
      intervalUnit: 1,
      estimatedPrice: 6000,
      categoryName: '光熱費',
      colorCode: 'FFFFFF',
      resourcePath: 'assets/images/icon_utility.svg',
      frequencyLabel: '毎月',
    );
  }

  group('FixedCostExpenseUsecase.confirmExpense', () {
    test('確定金額が0円以下ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostExpenseUsecaseProvider);

      await expectLater(
        () => usecase.confirmExpense(tileValue: buildTile(), confirmedPrice: 0),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '0円以上で入力してください',
          ),
        ),
      );
    });

    test('確定金額が上限（1,888,888円）以上ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostExpenseUsecaseProvider);

      await expectLater(
        () => usecase.confirmExpense(
          tileValue: buildTile(),
          confirmedPrice: 1888888,
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '金額の入力値が大き過ぎます',
          ),
        ),
      );
    });

    test('正常時は固定費支出IDと確定金額がリポジトリに渡る', () async {
      final container = createUsecaseContainer(
        fixedCosts: const [
          FixedCostEntity(
            id: 10,
            name: '電気代',
            variable: 1,
            fixedCostCategoryId: 2,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
          ),
        ],
      );
      final usecase = container.read(fixedCostExpenseUsecaseProvider);

      await usecase.confirmExpense(
        tileValue: buildTile(id: 100, fixedCostId: 10),
        confirmedPrice: 7200,
      );
      expect(fakeFixedCostExpenseRepository.confirmedExpenses, hasLength(1));
      final confirmed = fakeFixedCostExpenseRepository.confirmedExpenses.first;
      expect(confirmed.id, 100);
      expect(confirmed.price, 7200);
    });

    test('確定後は固定費支出IDではなく固定費マスタIDの想定額が更新される', () async {
      final container = createUsecaseContainer(
        fixedCosts: const [
          // 確定操作の対象となる固定費マスタ（変動費）
          FixedCostEntity(
            id: 10,
            name: '電気代',
            variable: 1,
            estimatedPrice: 5000,
            fixedCostCategoryId: 2,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
          ),
          // 固定費支出IDと同じidを持つ別マスタ（取り違えたらこちらが更新される）
          FixedCostEntity(
            id: 100,
            name: '通信費',
            variable: 1,
            estimatedPrice: 3000,
            fixedCostCategoryId: 3,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
          ),
        ],
      );
      fakeFixedCostExpenseRepository.estimatedPriceResult = 7200;
      final usecase = container.read(fixedCostExpenseUsecaseProvider);

      await usecase.confirmExpense(
        tileValue: buildTile(id: 100, fixedCostId: 10),
        confirmedPrice: 7200,
      );
      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      final updated = fakeFixedCostRepository.updatedEntities.first;
      expect(updated.id, 10);
      expect(updated.estimatedPrice, 7200);
    });

    test('確定するとDBの更新回数がインクリメントされる', () async {
      final container = createUsecaseContainer(
        fixedCosts: const [
          FixedCostEntity(
            id: 10,
            name: '電気代',
            variable: 0,
            fixedCostCategoryId: 2,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
          ),
        ],
      );
      final usecase = container.read(fixedCostExpenseUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);
      expect(dbCount.read(), 0);

      await usecase.confirmExpense(
        tileValue: buildTile(id: 100, fixedCostId: 10),
        confirmedPrice: 7200,
      );

      // 固定額の固定費なので想定額更新は何もせず、カウンタは1のまま
      expect(dbCount.read(), 1);
    });
  });

  group('FixedCostExpenseUsecase.edit', () {
    const entity = FixedCostExpenseEntity(
      id: 100,
      fixedCostId: 10,
      fixedCostCategoryId: 2,
      date: '20250710',
      price: 7200,
      name: '電気代',
    );

    test('金額が0円以下／上限以上ならエラー', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostExpenseUsecaseProvider);

      await expectLater(
        () => usecase.edit(entity: entity.copyWith(price: 0)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '0円以上で入力してください',
          ),
        ),
      );
      await expectLater(
        () => usecase.edit(entity: entity.copyWith(price: 1888888)),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            '金額の入力値が大き過ぎます',
          ),
        ),
      );
      expect(fakeFixedCostExpenseRepository.updatedEntities, isEmpty);
    });

    test('正常時はリポジトリのupdateに委譲する', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostExpenseUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);

      await usecase.edit(entity: entity.copyWith(price: 8000));

      expect(fakeFixedCostExpenseRepository.updatedEntities, hasLength(1));
      expect(fakeFixedCostExpenseRepository.updatedEntities.first.price, 8000);
      expect(dbCount.read(), 1);
    });
  });

  group('FixedCostExpenseUsecase.delete', () {
    test('リポジトリのdeleteに委譲する', () async {
      final container = createUsecaseContainer();
      final usecase = container.read(fixedCostExpenseUsecaseProvider);
      final dbCount = listenUpdateDBCount(container);

      await usecase.delete(id: 100);

      expect(fakeFixedCostExpenseRepository.deletedIds, [100]);
      expect(dbCount.read(), 1);
    });
  });
}
