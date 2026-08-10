import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/batch/batch_history_usecase.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

import '../helper/fake_repositories.dart';
import '../helper/test_container.dart';

void main() {
  // システム日時2025/7/6固定 → 今の集計期間は6/25〜7/24（終了日20250724）
  late FakeBatchHistoryRepository fakeBatchHistoryRepository;
  late FakeFixedCostRepository fakeFixedCostRepository;
  late FakeFixedCostExpenseRepository fakeFixedCostExpenseRepository;

  ProviderContainer createBatchContainer({
    required String latestBatchDate,
    List<FixedCostEntity>? fixedCostRecords,
  }) {
    fakeBatchHistoryRepository = FakeBatchHistoryRepository(
      initialLatestDate: latestBatchDate,
    );
    fakeFixedCostRepository = FakeFixedCostRepository(
      initialRecords: fixedCostRecords,
    );
    fakeFixedCostExpenseRepository = FakeFixedCostExpenseRepository();
    return createContainer(
      overrides: [
        ...aggregationSettingOverrides(systemDate: DateTime(2025, 7, 6)),
        batchHistoryRepositoryProvider.overrideWithValue(
          fakeBatchHistoryRepository,
        ),
        fixedCostRepositoryProvider.overrideWithValue(fakeFixedCostRepository),
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          fakeFixedCostExpenseRepository,
        ),
      ],
    );
  }

  group('BatchProcessUsecase.grobalBatchProscessing のスキップ判定', () {
    test('実行済み最終日が今の集計期間の終了日と同じなら何もしない', () async {
      final container = createBatchContainer(latestBatchDate: '20250724');
      final usecase = container.read(batchProcessUsecaseProvider);

      final result = await usecase.grobalBatchProscessing();

      expect(result, isFalse);
      expect(fakeBatchHistoryRepository.insertedEntities, isEmpty);
    });

    test('実行済み最終日が今の集計期間の終了日より後でも何もしない', () async {
      final container = createBatchContainer(latestBatchDate: '20250801');
      final usecase = container.read(batchProcessUsecaseProvider);

      final result = await usecase.grobalBatchProscessing();

      expect(result, isFalse);
      expect(fakeBatchHistoryRepository.insertedEntities, isEmpty);
    });
  });

  group('BatchProcessUsecase.grobalBatchProscessing のチャンク分割', () {
    test('1ヶ月未満の遅れは1チャンクで今期間の終了日まで処理する', () async {
      final container = createBatchContainer(latestBatchDate: '20250630');
      final usecase = container.read(batchProcessUsecaseProvider);

      final result = await usecase.grobalBatchProscessing();

      expect(result, isTrue);
      expect(fakeBatchHistoryRepository.insertedEntities, hasLength(1));
      final history = fakeBatchHistoryRepository.insertedEntities.first;
      expect(history.startDate, '20250701');
      expect(history.endDate, '20250724');
      expect(history.status, 1);
    });

    test('長期間の遅れは1ヶ月ずつのチャンクに分割して追いつく', () async {
      // 実行済み最終日4/24 → [4/25〜5/24] [5/25〜6/24] [6/25〜7/24] の3チャンク
      final container = createBatchContainer(latestBatchDate: '20250424');
      final usecase = container.read(batchProcessUsecaseProvider);

      final result = await usecase.grobalBatchProscessing();

      expect(result, isTrue);
      expect(fakeBatchHistoryRepository.insertedEntities, hasLength(3));

      final histories = fakeBatchHistoryRepository.insertedEntities;
      expect(histories[0].startDate, '20250425');
      expect(histories[0].endDate, '20250524');
      expect(histories[1].startDate, '20250525');
      expect(histories[1].endDate, '20250624');
      expect(histories[2].startDate, '20250625');
      expect(histories[2].endDate, '20250724');
    });

    test('期間の途中からの遅れは残り期間だけの端数チャンクになる', () async {
      // 実行済み最終日7/10 → [7/11〜7/24] の1チャンク
      final container = createBatchContainer(latestBatchDate: '20250710');
      final usecase = container.read(batchProcessUsecaseProvider);

      final result = await usecase.grobalBatchProscessing();

      expect(result, isTrue);
      expect(fakeBatchHistoryRepository.insertedEntities, hasLength(1));
      final history = fakeBatchHistoryRepository.insertedEntities.first;
      expect(history.startDate, '20250711');
      expect(history.endDate, '20250724');
    });

    test('バッチ実行でDB更新カウンタが増える（全画面リフレッシュの合図）', () async {
      final container = createBatchContainer(latestBatchDate: '20250424');
      final usecase = container.read(batchProcessUsecaseProvider);
      expect(container.read(updateDBCountNotifierProvider), 0);

      await usecase.grobalBatchProscessing();

      // 1チャンクあたり2回（addExpenseForFixedCost内と履歴記録後）× 3チャンク
      expect(container.read(updateDBCountNotifierProvider), 6);
    });
  });

  group('BatchProcessUsecase と固定費実績生成の連動', () {
    test('チャンク期間内に支払予定のある固定費から実績が生成されマスタが進む', () async {
      final container = createBatchContainer(
        latestBatchDate: '20250624',
        fixedCostRecords: const [
          FixedCostEntity(
            id: 1,
            name: '家賃',
            variable: 0,
            price: 80000,
            fixedCostCategoryId: 1,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20250701',
          ),
        ],
      );
      final usecase = container.read(batchProcessUsecaseProvider);

      final result = await usecase.grobalBatchProscessing();

      expect(result, isTrue);
      // 実績: 支払予定日どおりに1件生成
      expect(fakeFixedCostExpenseRepository.insertedEntities, hasLength(1));
      expect(
        fakeFixedCostExpenseRepository.insertedEntities.first.date,
        '20250701',
      );
      // マスタ: 次回支払日が1ヶ月進む
      expect(fakeFixedCostRepository.updatedEntities, hasLength(1));
      expect(
        fakeFixedCostRepository.updatedEntities.first.nextPaymentDate,
        '20250801',
      );
      // 履歴も記録される
      expect(fakeBatchHistoryRepository.insertedEntities, hasLength(1));
    });

    test('支払予定のない期間は実績を生成せず履歴だけ記録する', () async {
      final container = createBatchContainer(
        latestBatchDate: '20250624',
        fixedCostRecords: const [
          FixedCostEntity(
            id: 2,
            name: '年会費',
            variable: 0,
            price: 10000,
            fixedCostCategoryId: 1,
            intervalNumber: 1,
            intervalUnit: 2,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20260101', // 期間外
          ),
        ],
      );
      final usecase = container.read(batchProcessUsecaseProvider);

      await usecase.grobalBatchProscessing();

      expect(fakeFixedCostExpenseRepository.insertedEntities, isEmpty);
      expect(fakeFixedCostRepository.updatedEntities, isEmpty);
      expect(fakeBatchHistoryRepository.insertedEntities, hasLength(1));
    });

    test('複数チャンクにまたがる月次固定費は各月の実績が順に生成される', () async {
      // 5/25〜7/24の2チャンク分の遅れ。next=6/1の月次固定費は6/1と7/1の2回分が生成される
      final container = createBatchContainer(
        latestBatchDate: '20250524',
        fixedCostRecords: const [
          FixedCostEntity(
            id: 3,
            name: 'サブスク',
            variable: 0,
            price: 1000,
            fixedCostCategoryId: 1,
            intervalNumber: 1,
            intervalUnit: 1,
            firstPaymentDate: '20250101',
            nextPaymentDate: '20250601',
          ),
        ],
      );
      final usecase = container.read(batchProcessUsecaseProvider);

      await usecase.grobalBatchProscessing();

      // チャンク1（5/25〜6/24）で6/1分、チャンク2（6/25〜7/24）で7/1分
      expect(fakeFixedCostExpenseRepository.insertedEntities, hasLength(2));
      expect(
        fakeFixedCostExpenseRepository.insertedEntities[0].date,
        '20250601',
      );
      expect(
        fakeFixedCostExpenseRepository.insertedEntities[1].date,
        '20250701',
      );
      // マスタの支払予定日は最終的に8/1まで進む
      expect(fakeFixedCostRepository.records.first.nextPaymentDate, '20250801');
    });
  });
}
