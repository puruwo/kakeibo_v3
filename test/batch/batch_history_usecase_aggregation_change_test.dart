// 集計開始日を変更したときの月次バッチの挙動（KP-005 テストケース D-3）
//
// Wiki「月次バッチ処理 › 集計開始日を変更したときの挙動」（2026-08-11 実機検証）を
// 自動テストで固定する。要点:
//   - 後ろへずらす: batch_history に1ヶ月未満の行が1本残る（実績は正しい）
//   - 前へずらす: 実行済み最終日が新期間終了日を追い越し、最大1ヶ月バッチが止まる → 次期間で自己修復
//   - どの場合も固定費実績の取りこぼし・二重生成は起きない
//
// 「設定変更」は aggregationSettingOverrides の startDay を変えた別コンテナで表現し、
// Fake（batch_history・fixed_cost・expense）を共有して状態を引き継ぐ。
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/batch/batch_history_usecase.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';

import '../helper/fake_repositories.dart';
import '../helper/test_container.dart';

/// 今日。旧設定（25日始まり）では今月 = 8/25〜9/24
final _today = DateTime(2026, 8, 29);

/// f1: 月次・支払日25日・固定額 5,000
FixedCostEntity _f1({required String nextPaymentDate}) => FixedCostEntity(
  id: 1,
  name: '家賃',
  variable: 0,
  price: 5000,
  expenseSmallCategoryId: 11,
  intervalNumber: 1,
  intervalUnit: 1,
  firstPaymentDate: '20260125',
  nextPaymentDate: nextPaymentDate,
);

/// f2: 月次・支払日10日・変動額（推定 3,000）
FixedCostEntity _f2({required String nextPaymentDate}) => FixedCostEntity(
  id: 2,
  name: '電気代',
  variable: 1,
  estimatedPrice: 3000,
  expenseSmallCategoryId: 21,
  intervalNumber: 1,
  intervalUnit: 1,
  firstPaymentDate: '20260110',
  nextPaymentDate: nextPaymentDate,
);

void main() {
  late FakeBatchHistoryRepository fakeBatchHistoryRepository;
  late FakeFixedCostRepository fakeFixedCostRepository;
  late FakeExpenseRepository fakeExpenseRepository;

  /// 共有する Fake を組み立てる（テストごとに1回）
  void setUpFakes({
    required String latestBatchDate,
    required List<FixedCostEntity> fixedCosts,
    List<ExpenseEntity> expenses = const [],
  }) {
    fakeBatchHistoryRepository = FakeBatchHistoryRepository(
      initialLatestDate: latestBatchDate,
    );
    fakeExpenseRepository = FakeExpenseRepository(initialRecords: expenses);
    fakeFixedCostRepository = FakeFixedCostRepository(
      initialRecords: fixedCosts,
      expenseRepository: fakeExpenseRepository,
    );
  }

  /// 開始日 [startDay]・システム日時 [systemDate] のコンテナ（＝その設定での起動）
  ProviderContainer createBatchContainer({
    required int startDay,
    DateTime? systemDate,
  }) {
    return createContainer(
      overrides: [
        ...aggregationSettingOverrides(
          startDay: startDay,
          systemDate: systemDate ?? _today,
        ),
        batchHistoryRepositoryProvider.overrideWithValue(
          fakeBatchHistoryRepository,
        ),
        fixedCostRepositoryProvider.overrideWithValue(fakeFixedCostRepository),
        expenseRepositoryProvider.overrideWithValue(fakeExpenseRepository),
      ],
    );
  }

  Future<bool> runBatch({required int startDay, DateTime? systemDate}) {
    return createBatchContainer(
      startDay: startDay,
      systemDate: systemDate,
    ).read(batchProcessUsecaseProvider).grobalBatchProscessing();
  }

  /// f1 の実績日（yyyyMMdd）一覧
  List<String> f1RecordDates() => fakeExpenseRepository.records
      .where((e) => e.fixedCostId == 1)
      .map((e) => e.date)
      .toList();

  group('開始日を後ろへずらす（25→28）', () {
    test('1ヶ月未満の履歴行が1本残るが、f1 の実績は各支払日1件ずつ生成される', () async {
      // 8/24 まで実行済み。新しい今月は 8/28〜9/27
      setUpFakes(
        latestBatchDate: '20260824',
        fixedCosts: [_f1(nextPaymentDate: '20260825')],
      );

      final result = await runBatch(startDay: 28);

      expect(result, isTrue);
      // チャンクは [8/25〜9/24]（1ヶ月）と [9/25〜9/27]（3日間の歪な行）の2本
      final histories = fakeBatchHistoryRepository.insertedEntities;
      expect(histories, hasLength(2));
      expect(histories[0].startDate, '20260825');
      expect(histories[0].endDate, '20260924');
      expect(histories[1].startDate, '20260925');
      expect(histories[1].endDate, '20260927');
      // 実績は 8/25・9/25 の2件。重複なし
      expect(f1RecordDates(), ['20260825', '20260925']);
      expect(fakeFixedCostRepository.records.first.nextPaymentDate, '20261025');
    });
  });

  group('開始日を前へずらす（25→20）', () {
    test('実行済み最終日が新期間終了日より前なら通常どおり処理される', () async {
      // 8/24 まで実行済み。新しい今月は 8/20〜9/19 → 8/25〜9/19 が処理される
      setUpFakes(
        latestBatchDate: '20260824',
        fixedCosts: [_f1(nextPaymentDate: '20260825')],
      );

      final result = await runBatch(startDay: 20);

      expect(result, isTrue);
      final histories = fakeBatchHistoryRepository.insertedEntities;
      expect(histories, hasLength(1));
      expect(histories.single.startDate, '20260825');
      expect(histories.single.endDate, '20260919');
      expect(f1RecordDates(), ['20260825']);
    });

    test('実行済み最終日が新期間終了日を追い越していると何もしない（最大1ヶ月の停止）', () async {
      // 9/24 まで実行済み（8/25 の実績も生成済み）。新しい今月の終了日 9/19 ≤ 9/24
      setUpFakes(
        latestBatchDate: '20260924',
        fixedCosts: [_f1(nextPaymentDate: '20260925')],
        expenses: const [
          ExpenseEntity(
            id: 100,
            date: '20260825',
            price: 5000,
            paymentCategoryId: 11,
            fixedCostId: 1,
          ),
        ],
      );

      final result = await runBatch(startDay: 20);

      expect(result, isFalse);
      expect(fakeBatchHistoryRepository.insertedEntities, isEmpty);
      // 二重生成なし
      expect(f1RecordDates(), ['20260825']);
    });

    test('次の期間に入ると 9/25〜10/19 が処理されて自己修復する', () async {
      // 上のケースの続き: システム日時を 9/20 に進めて再起動
      setUpFakes(
        latestBatchDate: '20260924',
        fixedCosts: [_f1(nextPaymentDate: '20260925')],
        expenses: const [
          ExpenseEntity(
            id: 100,
            date: '20260825',
            price: 5000,
            paymentCategoryId: 11,
            fixedCostId: 1,
          ),
        ],
      );
      expect(await runBatch(startDay: 20), isFalse);

      final result = await runBatch(
        startDay: 20,
        systemDate: DateTime(2026, 9, 20),
      );

      expect(result, isTrue);
      final histories = fakeBatchHistoryRepository.insertedEntities;
      expect(histories, hasLength(1));
      expect(histories.single.startDate, '20260925');
      expect(histories.single.endDate, '20261019');
      // 9/25 の実績が1件だけ生成される
      expect(f1RecordDates(), ['20260825', '20260925']);
    });
  });

  group('同一支払日の実績は再生成されない', () {
    test('開始日を1に変更しても f2 の 8/10 実績は増えず next_payment_date は 9/10 に進む', () async {
      // f2 は 8/10 の実績生成済みだが、マスタの next_payment_date が 8/10 のまま
      // （バッチ途中の状態）。新しい今月は 8/1〜8/31 → 8/25〜8/31 が処理される
      setUpFakes(
        latestBatchDate: '20260824',
        fixedCosts: [_f2(nextPaymentDate: '20260810')],
        expenses: const [
          ExpenseEntity(
            id: 200,
            date: '20260810',
            price: null,
            paymentCategoryId: 21,
            fixedCostId: 2,
            isConfirmed: 0,
            estimatedPrice: 3000,
          ),
        ],
      );

      final result = await runBatch(startDay: 1);

      expect(result, isTrue);
      final f2Records = fakeExpenseRepository.records.where(
        (e) => e.fixedCostId == 2,
      );
      expect(f2Records.map((e) => e.date), ['20260810']);
      expect(fakeExpenseRepository.insertedFixedCostRecords, isEmpty);
      expect(fakeFixedCostRepository.records.first.nextPaymentDate, '20260910');
    });
  });

  group('設定変更→バッチ→元に戻す→バッチ', () {
    test('実績の件数は設定を変更しなかった場合と一致する', () async {
      // 基準: 開始日25のまま 7/24 から追いつく → 7/25・8/25 の2件
      setUpFakes(
        latestBatchDate: '20260724',
        fixedCosts: [_f1(nextPaymentDate: '20260725')],
      );
      await runBatch(startDay: 25);
      final baselineDates = f1RecordDates();
      expect(baselineDates, ['20260725', '20260825']);

      // 比較: 20 に変更して追いつく → 25 に戻してもう一度
      setUpFakes(
        latestBatchDate: '20260724',
        fixedCosts: [_f1(nextPaymentDate: '20260725')],
      );
      await runBatch(startDay: 20);
      // 8/20〜9/19 の区切りで [7/25〜8/24][8/25〜9/19] が処理される
      expect(fakeBatchHistoryRepository.insertedEntities, hasLength(2));
      await runBatch(startDay: 25);
      // 戻した後は 9/20〜9/24 の端数チャンクが1本追加されるだけ
      expect(fakeBatchHistoryRepository.insertedEntities, hasLength(3));
      expect(
        fakeBatchHistoryRepository.insertedEntities.last.startDate,
        '20260920',
      );
      expect(
        fakeBatchHistoryRepository.insertedEntities.last.endDate,
        '20260924',
      );

      expect(f1RecordDates(), baselineDates);
    });
  });
}
