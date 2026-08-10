import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_service.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';

import '../../helper/fake_repositories.dart';
import '../../helper/test_container.dart';

/// テストコードからRefを取り出すためのProvider
final _refProvider = Provider<Ref>((ref) => ref);

void main() {
  group('FixedCostService.populateNextPaymentEntity', () {
    // 月次・1ヶ月ごとの基本エンティティ
    const baseEntity = FixedCostEntity(
      id: 1,
      name: '家賃',
      variable: 0,
      price: 80000,
      fixedCostCategoryId: 1,
      intervalNumber: 1,
      intervalUnit: 1, // 月単位
      firstPaymentDate: '20250601',
    );

    test('月単位: 次回支払予定日を基準に1ヶ月後を設定する', () {
      final entity = baseEntity.copyWith(nextPaymentDate: '20250715');

      final result = FixedCostService().populateNextPaymentEntity(entity);

      expect(result.recentPaymentDate, '20250715');
      expect(result.nextPaymentDate, '20250815');
    });

    test('次回支払予定日が未設定なら初回支払日を基準にする', () {
      final result = FixedCostService().populateNextPaymentEntity(baseEntity);

      expect(result.recentPaymentDate, '20250601');
      expect(result.nextPaymentDate, '20250701');
    });

    test('月単位: 加算先に同じ日が存在しない場合は月末に丸める（1/31 → 2/28）', () {
      final entity = baseEntity.copyWith(nextPaymentDate: '20250131');

      final result = FixedCostService().populateNextPaymentEntity(entity);

      expect(result.nextPaymentDate, '20250228');
    });

    test('3ヶ月ごとの支払いは3ヶ月後になる', () {
      final entity = baseEntity.copyWith(
        intervalNumber: 3,
        nextPaymentDate: '20250715',
      );

      final result = FixedCostService().populateNextPaymentEntity(entity);

      expect(result.nextPaymentDate, '20251015');
    });

    test('年単位: 1年後を設定する', () {
      final entity = baseEntity.copyWith(
        intervalUnit: 2, // 年単位
        nextPaymentDate: '20250715',
      );

      final result = FixedCostService().populateNextPaymentEntity(entity);

      expect(result.recentPaymentDate, '20250715');
      expect(result.nextPaymentDate, '20260715');
    });

    test('年単位: 閏日の1年後は2/28に丸める（2024/2/29 → 2025/2/28）', () {
      final entity = baseEntity.copyWith(
        intervalUnit: 2,
        nextPaymentDate: '20240229',
      );

      final result = FixedCostService().populateNextPaymentEntity(entity);

      expect(result.nextPaymentDate, '20250228');
    });

    test('年をまたぐ月加算（12/15 → 翌年1/15）', () {
      final entity = baseEntity.copyWith(nextPaymentDate: '20251215');

      final result = FixedCostService().populateNextPaymentEntity(entity);

      expect(result.nextPaymentDate, '20260115');
    });
  });

  group('FixedCostService.insertToFixedCostExpense', () {
    test('固定額（variable=0）はマスタの金額で確定済みとして挿入する', () {
      final fakeRepository = FakeFixedCostExpenseRepository();
      final container = createContainer(
        overrides: [
          fixedCostExpenseRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      final ref = container.read(_refProvider);

      const entity = FixedCostEntity(
        id: 10,
        name: '家賃',
        variable: 0,
        price: 80000,
        fixedCostCategoryId: 2,
        intervalNumber: 1,
        intervalUnit: 1,
        firstPaymentDate: '20250601',
      );

      FixedCostService().insertToFixedCostExpense(ref, entity, '20250701');

      expect(fakeRepository.insertedEntities, hasLength(1));
      final inserted = fakeRepository.insertedEntities.first;
      expect(inserted.fixedCostId, 10);
      expect(inserted.fixedCostCategoryId, 2);
      expect(inserted.date, '20250701');
      expect(inserted.price, 80000);
      expect(inserted.name, '家賃');
      expect(inserted.confirmedCostType, 0);
      expect(inserted.isConfirmed, 1);
    });

    test('変動額（variable=1）は金額0円・未確定として挿入する', () {
      final fakeRepository = FakeFixedCostExpenseRepository();
      final container = createContainer(
        overrides: [
          fixedCostExpenseRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      final ref = container.read(_refProvider);

      const entity = FixedCostEntity(
        id: 11,
        name: '電気代',
        variable: 1,
        price: 5000,
        fixedCostCategoryId: 3,
        intervalNumber: 1,
        intervalUnit: 1,
        firstPaymentDate: '20250601',
      );

      FixedCostService().insertToFixedCostExpense(ref, entity, '20250710');

      expect(fakeRepository.insertedEntities, hasLength(1));
      final inserted = fakeRepository.insertedEntities.first;
      expect(inserted.price, 0);
      expect(inserted.confirmedCostType, 1);
      expect(inserted.isConfirmed, 0);
    });
  });
}
