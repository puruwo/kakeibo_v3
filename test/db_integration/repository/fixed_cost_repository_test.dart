// ImplementsFixedCostRepository のDB結合テスト
//
// 固定費マスタは「論理削除（delete_flag）」と「次回支払日での期間絞り」が肝。
// 特に fetchNextPeriodPayment の delete_flag = 0 条件は、
// 削除済み固定費が翌期間の支払予定として復活していた本番バグの修正点なので、
// 回帰検知としてここで固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/repository/fixed_cost_repository.dart';

import '../../helper/db_test_helper.dart';

/// 基準シナリオの集計期間（開始日25日設定で 2025/7/6 を選んだときの期間）
final _period = PeriodValue(
  startDatetime: DateTime(2025, 6, 25),
  endDatetime: DateTime(2025, 7, 24),
);

/// 次回支払日の境界・論理削除を一度に検証できる標準フィクスチャ
///
/// | id | 名前       | 次回支払日 | 位置          | delete_flag |
/// |----|------------|------------|---------------|-------------|
/// | 1  | 期間前      | 2025-06-24 | 期間開始前日   | 0           |
/// | 2  | 開始日ちょうど | 2025-06-25 | 期間開始日     | 0           |
/// | 3  | 期間中      | 2025-07-01 | 期間中         | 0           |
/// | 4  | 削除済み    | 2025-07-01 | 期間中         | 1           |
/// | 5  | 終了日ちょうど | 2025-07-24 | 期間終了日     | 0           |
/// | 6  | 期間後      | 2025-07-25 | 期間終了翌日   | 0           |
Future<void> _seedStandardFixedCosts() async {
  await insertFixedCostRow(
    id: 1,
    name: '期間前',
    price: 1000,
    nextPaymentDate: '20250624',
  );
  await insertFixedCostRow(
    id: 2,
    name: '開始日ちょうど',
    price: 2000,
    nextPaymentDate: '20250625',
  );
  await insertFixedCostRow(
    id: 3,
    name: '期間中',
    price: 3000,
    nextPaymentDate: '20250701',
  );
  await insertFixedCostRow(
    id: 4,
    name: '削除済み',
    price: 4000,
    nextPaymentDate: '20250701',
    deleteFlag: 1,
  );
  await insertFixedCostRow(
    id: 5,
    name: '終了日ちょうど',
    price: 5000,
    nextPaymentDate: '20250724',
  );
  await insertFixedCostRow(
    id: 6,
    name: '期間後',
    price: 6000,
    nextPaymentDate: '20250725',
  );
}

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsFixedCostRepository();

  group('fetchAll', () {
    test('論理削除済みも含めて全件をid昇順で返す', () async {
      await _seedStandardFixedCosts();

      final results = await repository.fetchAll();

      // delete_flag = 1 の id=4 も含まれる
      expect(results.map((e) => e.id).toList(), [1, 2, 3, 4, 5, 6]);
    });

    test('1件も無いなら空リストを返す', () async {
      final results = await repository.fetchAll();

      expect(results, isEmpty);
    });

    test('price・estimatedPriceがNULLでも0へフォールバックしてマッピングされる', () async {
      // fixed_cost の price / estimated_price / recent_payment_date はNULL許容
      await insertFixedCostRow(
        id: 1,
        name: 'サブスクA',
        variable: 1,
        intervalNumber: 3,
        intervalUnit: 2,
        firstPaymentDate: '20240401',
        nextPaymentDate: '20250701',
      );

      final results = await repository.fetchAll();

      expect(
        results.single,
        const FixedCostEntity(
          id: 1,
          name: 'サブスクA',
          variable: 1,
          price: 0,
          estimatedPrice: 0,
          // insertFixedCostRow の既定値（v10で追加された支出小カテゴリー参照）
          expenseSmallCategoryId: 1,
          intervalNumber: 3,
          intervalUnit: 2,
          firstPaymentDate: '20240401',
          recentPaymentDate: null,
          nextPaymentDate: '20250701',
          deleteFlag: 0,
        ),
      );
    });
  });

  group('fetchAllActive', () {
    test('delete_flag = 0 の固定費だけをid昇順で返す', () async {
      await _seedStandardFixedCosts();

      final results = await repository.fetchAllActive();

      // 論理削除済みの id=4 が落ちる
      expect(results.map((e) => e.id).toList(), [1, 2, 3, 5, 6]);
    });

    test('全て論理削除済みなら空リストを返す', () async {
      await insertFixedCostRow(
        id: 1,
        name: '削除済み',
        deleteFlag: 1,
      );

      final results = await repository.fetchAllActive();

      expect(results, isEmpty);
    });
  });

  group('fetch', () {
    test('id指定でその固定費を返す', () async {
      await _seedStandardFixedCosts();

      final result = await repository.fetch(fixedCostId: 3);

      expect(result.id, 3);
      expect(result.name, '期間中');
      expect(result.price, 3000);
    });

    test('論理削除済みでもid指定なら取得できる', () async {
      await _seedStandardFixedCosts();

      final result = await repository.fetch(fixedCostId: 4);

      expect(result.id, 4);
      expect(result.deleteFlag, 1);
    });

    test('存在しないidなら空の既定エンティティを返す', () async {
      await _seedStandardFixedCosts();

      final result = await repository.fetch(fixedCostId: 999);

      // 0件時は jsonList[0] で例外→catch節の既定値が返る
      expect(result.id, 0);
      expect(result.name, '');
      expect(result.price, 0);
      expect(result.nextPaymentDate, isNull);
    });
  });

  group('fetchNextPeriodPayment', () {
    test('次回支払日が期間終了日以前の固定費をid降順で返す', () async {
      await _seedStandardFixedCosts();

      final results = await repository.fetchNextPeriodPayment(period: _period);

      // ORDER BY _id DESC。id=4は論理削除済み・id=6は期間終了翌日なので除外される
      // id=1（期間開始前日）は取り残しとして拾う（下限が無い）
      expect(results.map((e) => e.id).toList(), [5, 3, 2, 1]);
    });

    test('期間開始日ちょうどの固定費を含む', () async {
      await _seedStandardFixedCosts();

      final results = await repository.fetchNextPeriodPayment(period: _period);

      expect(results.map((e) => e.nextPaymentDate), contains('20250625'));
    });

    test('期間終了日ちょうどの固定費を含む（next_payment_date <= 終了日）', () async {
      await _seedStandardFixedCosts();

      final results = await repository.fetchNextPeriodPayment(period: _period);

      expect(results.map((e) => e.nextPaymentDate), contains('20250724'));
    });

    test('期間終了翌日の固定費は含まない', () async {
      await _seedStandardFixedCosts();

      final results = await repository.fetchNextPeriodPayment(period: _period);

      expect(results.map((e) => e.id), isNot(contains(6)));
    });

    test('期間開始日より前に取り残された固定費も含む（下限を設けない）', () async {
      // 過去のバッチで取りこぼしてnext_payment_dateが過去日のまま固定された
      // マスタを拾えないと、その固定費の実績が二度と生成されない（→ ADR-007）
      await _seedStandardFixedCosts();

      final results = await repository.fetchNextPeriodPayment(period: _period);

      expect(results.map((e) => e.id), contains(1));
    });

    test('数ヶ月前に取り残された固定費も拾える', () async {
      await insertFixedCostRow(
        id: 1,
        name: '3ヶ月取り残し',
        nextPaymentDate: '20250401',
      );

      final results = await repository.fetchNextPeriodPayment(period: _period);

      expect(results.map((e) => e.id).toList(), [1]);
    });

    test('論理削除済みの固定費は期間内でも含まない', () async {
      // 削除済み固定費が翌期間の支払予定として復活していた不具合の回帰検知
      await _seedStandardFixedCosts();

      final results = await repository.fetchNextPeriodPayment(period: _period);

      expect(results.map((e) => e.id), isNot(contains(4)));
      expect(results.every((e) => e.deleteFlag == 0), isTrue);
    });

    test('期間内が論理削除済みだけなら空リストを返す', () async {
      await insertFixedCostRow(
        id: 1,
        name: '削除済み',
        nextPaymentDate: '20250701',
        deleteFlag: 1,
      );

      final results = await repository.fetchNextPeriodPayment(period: _period);

      expect(results, isEmpty);
    });

    test('年跨ぎの期間（12/25〜1/24）でも取得できる', () async {
      await insertFixedCostRow(
        id: 1,
        name: '期間前',
        nextPaymentDate: '20241224',
      );
      await insertFixedCostRow(
        id: 2,
        name: '開始日',
        nextPaymentDate: '20241225',
      );
      await insertFixedCostRow(
        id: 3,
        name: '年明け',
        nextPaymentDate: '20250101',
      );
      await insertFixedCostRow(
        id: 4,
        name: '終了日',
        nextPaymentDate: '20250124',
      );
      await insertFixedCostRow(
        id: 5,
        name: '期間後',
        nextPaymentDate: '20250125',
      );

      final results = await repository.fetchNextPeriodPayment(
        period: PeriodValue(
          startDatetime: DateTime(2024, 12, 25),
          endDatetime: DateTime(2025, 1, 24),
        ),
      );

      // id=5（期間終了翌日）だけが外れる。id=1は取り残しとして拾う
      expect(results.map((e) => e.id).toList(), [4, 3, 2, 1]);
    });

    test('該当が無いなら空リストを返す', () async {
      await _seedStandardFixedCosts();

      final results = await repository.fetchNextPeriodPayment(
        period: PeriodValue(
          startDatetime: DateTime(2020, 1, 1),
          endDatetime: DateTime(2020, 1, 31),
        ),
      );

      expect(results, isEmpty);
    });
  });

  group('fetchEstimatedPriceById', () {
    test('id指定で推定支出額を返す', () async {
      await insertFixedCostRow(
        id: 1,
        name: '電気代',
        variable: 1,
        estimatedPrice: 7800,
      );

      final result = await repository.fetchEstimatedPriceById(id: 1);

      expect(result, 7800);
    });

    test('estimated_priceがNULLなら0を返す', () async {
      await insertFixedCostRow(id: 1, name: '家賃');

      final result = await repository.fetchEstimatedPriceById(id: 1);

      expect(result, 0);
    });

    test('存在しないidなら0を返す', () async {
      await insertFixedCostRow(
        id: 1,
        name: '電気代',
        estimatedPrice: 7800,
      );

      final result = await repository.fetchEstimatedPriceById(id: 999);

      expect(result, 0);
    });

    test('論理削除済みでも推定額を返す（delete_flagで絞らない）', () async {
      await insertFixedCostRow(
        id: 1,
        name: '削除済み',
        estimatedPrice: 5000,
        deleteFlag: 1,
      );

      final result = await repository.fetchEstimatedPriceById(id: 1);

      expect(result, 5000);
    });
  });

  group('insert', () {
    test('1件追加され、採番されたidと保存値が一致する', () async {
      final id = await repository.insert(
        const FixedCostEntity(
          name: 'Netflix',
          variable: 0,
          price: 1490,
          estimatedPrice: 1490,
          intervalNumber: 1,
          intervalUnit: 1,
          firstPaymentDate: '20250601',
          recentPaymentDate: '20250601',
          nextPaymentDate: '20250701',
        ),
      );

      final results = await repository.fetchAll();
      expect(results.single.id, id);
      expect(
        results.single,
        FixedCostEntity(
          id: id,
          name: 'Netflix',
          variable: 0,
          price: 1490,
          estimatedPrice: 1490,
          intervalNumber: 1,
          intervalUnit: 1,
          firstPaymentDate: '20250601',
          recentPaymentDate: '20250601',
          nextPaymentDate: '20250701',
          deleteFlag: 0,
        ),
      );
    });

    test('idはエンティティの値ではなくAUTOINCREMENTで採番される', () async {
      // 既存の最大idの次が採番される
      await insertFixedCostRow(id: 50, name: '既存');

      final id = await repository.insert(
        const FixedCostEntity(
          id: 1,
          name: '新規',
          variable: 0,
          intervalNumber: 1,
          intervalUnit: 1,
          firstPaymentDate: '20250601',
          nextPaymentDate: '20250701',
        ),
      );

      expect(id, 51);
    });
  });

  group('update', () {
    test('指定idの行だけが書き換わる', () async {
      await _seedStandardFixedCosts();

      await repository.update(
        const FixedCostEntity(
          id: 3,
          name: '変更後',
          variable: 1,
          price: 9999,
          estimatedPrice: 8888,
          expenseSmallCategoryId: 5,
          intervalNumber: 2,
          intervalUnit: 2,
          firstPaymentDate: '20240101',
          recentPaymentDate: '20250601',
          nextPaymentDate: '20250801',
          deleteFlag: 0,
        ),
      );

      final results = await repository.fetchAll();
      final updated = results.firstWhere((e) => e.id == 3);
      expect(updated.name, '変更後');
      expect(updated.price, 9999);
      expect(updated.estimatedPrice, 8888);
      expect(updated.expenseSmallCategoryId, 5);
      expect(updated.nextPaymentDate, '20250801');

      // 他の行は変化しない
      expect(results.firstWhere((e) => e.id == 2).price, 2000);
      expect(results.length, 6);
    });

    test('recentPaymentDate・nextPaymentDateがnullなら空文字で保存される', () async {
      await insertFixedCostRow(
        id: 1,
        name: '家賃',
        recentPaymentDate: '20250601',
        nextPaymentDate: '20250701',
      );

      await repository.update(
        const FixedCostEntity(
          id: 1,
          name: '家賃',
          variable: 0,
          intervalNumber: 1,
          intervalUnit: 1,
          firstPaymentDate: '20250101',
          recentPaymentDate: null,
          nextPaymentDate: null,
        ),
      );

      final results = await repository.fetchAll();
      // update側で `?? ''` されるためNULLではなく空文字になる
      expect(results.single.recentPaymentDate, '');
      expect(results.single.nextPaymentDate, '');
    });

    test('idがnullなら（WHERE _id = -1 になり）1件も更新されない', () async {
      await _seedStandardFixedCosts();

      await repository.update(
        const FixedCostEntity(
          id: null,
          name: '変更後',
          variable: 0,
          price: 9999,
          intervalNumber: 1,
          intervalUnit: 1,
          firstPaymentDate: '20250101',
          nextPaymentDate: '20250701',
        ),
      );

      final results = await repository.fetchAll();
      expect(results.map((e) => e.price).toList(), [
        1000,
        2000,
        3000,
        4000,
        5000,
        6000,
      ]);
    });
  });

  group('deleteWithUnpaidExpenses', () {
    // 運用日付。この日を境に「支払日が到来済みか」を判定する
    const today = '20250706';

    /// 固定費10に紐づく実績を、確定状態と支払日の組み合わせで一通り用意する
    ///
    /// | id | 固定費 | 日付       | 位置          | 確定 | 期待     |
    /// |----|-------|------------|---------------|------|----------|
    /// | 1  | 10    | 2025-06-01 | 到来済み       | 1    | 残る     |
    /// | 2  | 10    | 2025-07-06 | 運用日付ちょうど | 1    | 残る     |
    /// | 3  | 10    | 2025-07-07 | 未到来         | 1    | 消える   |
    /// | 4  | 10    | 2025-06-05 | 到来済み       | 0    | 消える   |
    /// | 5  | 20    | 2025-07-20 | 未到来         | 1    | 残る（別マスタ） |
    Future<void> seedExpenses() async {
      await insertExpenseRow(
        id: 1,
        fixedCostId: 10,
        date: '20250601',
        price: 1000,
        memo: '支払済み',
        isConfirmed: 1,
      );
      await insertExpenseRow(
        id: 2,
        fixedCostId: 10,
        date: '20250706',
        price: 1000,
        memo: '当日',
        isConfirmed: 1,
      );
      await insertExpenseRow(
        id: 3,
        fixedCostId: 10,
        date: '20250707',
        price: 1000,
        memo: '未到来だが確定扱い',
        isConfirmed: 1,
      );
      await insertExpenseRow(
        id: 4,
        fixedCostId: 10,
        date: '20250605',
        price: null,
        estimatedPrice: 1000,
        memo: '未確定',
        isConfirmed: 0,
      );
      await insertExpenseRow(
        id: 5,
        fixedCostId: 20,
        date: '20250720',
        price: 3000,
        memo: '別マスタ',
        isConfirmed: 1,
      );
    }

    /// 残っている実績のidを昇順で返す
    Future<List<int>> remainingExpenseIds() async {
      final rows = await DatabaseHelper.instance.query(
        'SELECT ${SqfExpense.id} as id '
        'FROM ${SqfExpense.tableName} '
        'WHERE ${SqfExpense.fixedCostId} IS NOT NULL '
        'ORDER BY ${SqfExpense.id} ASC',
      );
      return rows.map((e) => e['id'] as int).toList();
    }

    Future<void> seedTwoMasters() async {
      await insertFixedCostRow(
        id: 10,
        name: '解約するサブスク',
        price: 1000,
      );
      await insertFixedCostRow(
        id: 20,
        name: '継続するサブスク',
        price: 3000,
      );
    }

    test('未確定の実績は支払日が到来済みでも削除される', () async {
      await seedTwoMasters();
      await seedExpenses();

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      // id=4（未確定・6/5）が消える
      expect(await remainingExpenseIds(), isNot(contains(4)));
    });

    test('支払日が運用日付より後なら確定済みでも削除される', () async {
      // 変動なし固定費は生成時点でis_confirmed=1になるため、
      // これが無いと解約後も当月分が支出に残り続ける
      await seedTwoMasters();
      await seedExpenses();

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      expect(await remainingExpenseIds(), isNot(contains(3)));
    });

    test('支払日が到来済みの確定実績は履歴として残る', () async {
      await seedTwoMasters();
      await seedExpenses();

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      expect(await remainingExpenseIds(), contains(1));
    });

    test('支払日が運用日付ちょうどなら「到来済み」として残る（境界値）', () async {
      // 条件は date > today なので、当日は削除されない
      await seedTwoMasters();
      await seedExpenses();

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      expect(await remainingExpenseIds(), contains(2));
    });

    test('他のマスタに紐づく実績は巻き込まれない', () async {
      await seedTwoMasters();
      await seedExpenses();

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      // id=5は固定費20の未到来分だが、削除対象は固定費10だけ
      expect(await remainingExpenseIds(), [1, 2, 5]);
    });

    test('マスタは物理削除されずdelete_flagが1になる', () async {
      await seedTwoMasters();
      await seedExpenses();

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      // 行数は減らない
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfFixedCost.tableName),
        2,
      );
      final all = await repository.fetchAll();
      expect(all.firstWhere((e) => e.id == 10).deleteFlag, 1);
      // 他のマスタは触らない
      expect(all.firstWhere((e) => e.id == 20).deleteFlag, 0);
      // アクティブ一覧からは消える
      final active = await repository.fetchAllActive();
      expect(active.map((e) => e.id).toList(), [20]);
    });

    test('存在しないidを指定してもマスタも実績も変わらない', () async {
      await seedTwoMasters();
      await seedExpenses();

      await repository.deleteWithUnpaidExpenses(id: 999, today: today);

      // どのマスタも論理削除されない
      final all = await repository.fetchAll();
      expect(all.every((e) => e.deleteFlag == 0), isTrue);
      // 実績も1件も消えない
      expect(await remainingExpenseIds(), [1, 2, 3, 4, 5]);
    });

    test('削除後は次回支払予定にも未確定リストにも出てこない', () async {
      await seedTwoMasters();
      await seedExpenses();

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      final results = await repository.fetchNextPeriodPayment(period: _period);
      expect(results.map((e) => e.id), isNot(contains(10)));
    });

    test('実績が1件も無いマスタでも論理削除だけは成功する', () async {
      await seedTwoMasters();

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      final all = await repository.fetchAll();
      expect(all.firstWhere((e) => e.id == 10).deleteFlag, 1);
    });
  });

  group('fetchNextPeriodPayment の例外伝播', () {
    test('SQLが失敗したら空リストではなく例外が呼び出し元へ伝わる', () async {
      // 空リストを返すと、バッチが「取得失敗」と「対象0件」を区別できず、
      // SQLエラーでも成功として記録され、その月の固定費が二度と生成されない（→ ADR-007）
      await DatabaseHelper.instance.query(
        'DROP TABLE ${SqfFixedCost.tableName}',
      );

      expect(
        () => repository.fetchNextPeriodPayment(period: _period),
        throwsA(anything),
      );
    });
  });

  // ---------------------------------------------------------------------
  // v10で追加した、expenseの固定費行と連動する書き込み
  // ---------------------------------------------------------------------

  group('deleteWithUnpaidExpenses（expenseの固定費行）', () {
    // 運用日付。この日を境に「支払日が到来済みか」を判定する
    const today = '20250706';

    /// マスタ10に紐づくexpenseの固定費行を、確定状態と支払日の組み合わせで用意する
    ///
    /// | id | 固定費 | 日付       | 確定 | 期待             |
    /// |----|-------|------------|------|------------------|
    /// | 1  | 10    | 2025-06-01 | 1    | 残る             |
    /// | 2  | 10    | 2025-07-06 | 1    | 残る（当日・境界値） |
    /// | 3  | 10    | 2025-07-07 | 1    | 消える（未到来）   |
    /// | 4  | 10    | 2025-06-05 | 0    | 消える（未確定）   |
    /// | 5  | 20    | 2025-07-20 | 1    | 残る（別マスタ）   |
    Future<void> seedExpenseRows() async {
      await insertExpenseRow(
          id: 1, date: '20250601', price: 1000, fixedCostId: 10);
      await insertExpenseRow(
          id: 2, date: '20250706', price: 1000, fixedCostId: 10);
      await insertExpenseRow(
          id: 3, date: '20250707', price: 1000, fixedCostId: 10);
      await insertExpenseRow(
        id: 4,
        date: '20250605',
        price: null,
        fixedCostId: 10,
        isConfirmed: 0,
        estimatedPrice: 1000,
      );
      await insertExpenseRow(
          id: 5, date: '20250720', price: 1000, fixedCostId: 20);
      // 固定費に紐づかない通常支出（消えてはいけない）
      await insertExpenseRow(id: 6, date: '20250707', price: 500);
    }

    Future<List<int>> remainingExpenseIds() async {
      final rows = await DatabaseHelper.instance.query(
        'SELECT ${SqfExpense.id} AS id FROM ${SqfExpense.tableName} ORDER BY ${SqfExpense.id}',
      );
      return rows.map((e) => e['id'] as int).toList();
    }

    test('未確定行と支払日未到来の確定行が消え、到来済みの確定行は残る', () async {
      await insertFixedCostRow(
          id: 10, name: 'サブスク', price: 1000);
      await seedExpenseRows();

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      expect(await remainingExpenseIds(), [1, 2, 5, 6]);
    });

    test('マスタは論理削除され、残った確定行のfixed_cost_idは保持される', () async {
      await insertFixedCostRow(
          id: 10, name: 'サブスク', price: 1000);
      await seedExpenseRows();

      await repository.deleteWithUnpaidExpenses(id: 10, today: today);

      final master = (await repository.fetchAll()).single;
      expect(master.deleteFlag, 1);
      final rows = await DatabaseHelper.instance.query(
        'SELECT ${SqfExpense.fixedCostId} AS fixedCostId FROM ${SqfExpense.tableName} WHERE ${SqfExpense.id} = 1',
      );
      expect(rows.single['fixedCostId'], 10);
    });
  });

  group('recalculateEstimatedPriceWithSync', () {
    test('確定行の平均でマスタと未確定行が同時に更新される', () async {
      await insertFixedCostRow(
        id: 10,
        name: '電気代',
        variable: 1,
        estimatedPrice: 5000,
      );
      // 確定行 6000・8000（平均7000）と、同期対象の未確定行
      await insertExpenseRow(
          id: 1, date: '20250601', price: 6000, fixedCostId: 10);
      await insertExpenseRow(
          id: 2, date: '20250701', price: 8000, fixedCostId: 10);
      await insertExpenseRow(
        id: 3,
        date: '20250710',
        price: null,
        fixedCostId: 10,
        isConfirmed: 0,
        estimatedPrice: 5000,
      );

      await repository.recalculateEstimatedPriceWithSync(fixedCostId: 10);

      expect((await repository.fetch(fixedCostId: 10)).estimatedPrice, 7000);
      final rows = await DatabaseHelper.instance.query(
        'SELECT ${SqfExpense.estimatedPrice} AS estimatedPrice, ${SqfExpense.price} AS price FROM ${SqfExpense.tableName} WHERE ${SqfExpense.id} = 3',
      );
      expect(rows.single['estimatedPrice'], 7000);
      // 実額には書き込まない（仕様 §6.5）
      expect(rows.single['price'], isNull);
    });

    test('確定行が0件なら推定額を更新しない（最後の値を保持する）', () async {
      await insertFixedCostRow(
        id: 10,
        name: '電気代',
        variable: 1,
        estimatedPrice: 5000,
      );
      await insertExpenseRow(
        id: 1,
        date: '20250710',
        price: null,
        fixedCostId: 10,
        isConfirmed: 0,
        estimatedPrice: 5000,
      );

      await repository.recalculateEstimatedPriceWithSync(fixedCostId: 10);

      expect((await repository.fetch(fixedCostId: 10)).estimatedPrice, 5000);
    });

    test('予想額が手動設定なら確定行があっても再計算しない（仕様 §6.9）', () async {
      await insertFixedCostRow(
        id: 10,
        name: '電気代',
        variable: 1,
        estimatedPrice: 5000,
        estimatedPriceIsManual: 1,
      );
      // 確定行 6000・8000（自動なら平均7000になる組み合わせ）
      await insertExpenseRow(
          id: 1, date: '20250601', price: 6000, fixedCostId: 10);
      await insertExpenseRow(
          id: 2, date: '20250701', price: 8000, fixedCostId: 10);
      await insertExpenseRow(
        id: 3,
        date: '20250710',
        price: null,
        fixedCostId: 10,
        isConfirmed: 0,
        estimatedPrice: 5000,
      );

      await repository.recalculateEstimatedPriceWithSync(fixedCostId: 10);

      // マスタも未確定行も手動値のまま
      expect((await repository.fetch(fixedCostId: 10)).estimatedPrice, 5000);
      final rows = await DatabaseHelper.instance.query(
        'SELECT ${SqfExpense.estimatedPrice} AS estimatedPrice FROM ${SqfExpense.tableName} WHERE ${SqfExpense.id} = 3',
      );
      expect(rows.single['estimatedPrice'], 5000);
    });
  });

  group('updateWithUnconfirmedRowsSync', () {
    test('マスタ更新と未確定行の予想額同期が同時に行われる', () async {
      await insertFixedCostRow(
        id: 10,
        name: '電気代',
        variable: 1,
        estimatedPrice: 5000,
      );
      await insertExpenseRow(
        id: 1,
        date: '20250710',
        price: null,
        fixedCostId: 10,
        isConfirmed: 0,
        estimatedPrice: 5000,
      );

      final master = await repository.fetch(fixedCostId: 10);
      await repository.updateWithUnconfirmedRowsSync(
        master.copyWith(estimatedPrice: 9000),
      );

      expect((await repository.fetch(fixedCostId: 10)).estimatedPrice, 9000);
      final rows = await DatabaseHelper.instance.query(
        'SELECT ${SqfExpense.estimatedPrice} AS estimatedPrice FROM ${SqfExpense.tableName} WHERE ${SqfExpense.id} = 1',
      );
      expect(rows.single['estimatedPrice'], 9000);
    });

    test('手動設定フラグも保存され、以後の再計算がスキップされる（仕様 §6.9）', () async {
      await insertFixedCostRow(
        id: 10,
        name: '電気代',
        variable: 1,
        estimatedPrice: 5000,
      );
      await insertExpenseRow(
          id: 1, date: '20250601', price: 6000, fixedCostId: 10);

      final master = await repository.fetch(fixedCostId: 10);
      await repository.updateWithUnconfirmedRowsSync(
        master.copyWith(estimatedPrice: 9000, estimatedPriceIsManual: 1),
      );
      await repository.recalculateEstimatedPriceWithSync(fixedCostId: 10);

      final updated = await repository.fetch(fixedCostId: 10);
      expect(updated.estimatedPriceIsManual, 1);
      // 確定行（6000）の平均で上書きされない
      expect(updated.estimatedPrice, 9000);
    });
  });

  group('updateWithAutoEstimatedPriceSync', () {
    test('自動に戻すとフラグが0になり確定行の平均で再計算・同期される', () async {
      await insertFixedCostRow(
        id: 10,
        name: '電気代',
        variable: 1,
        estimatedPrice: 9000,
        estimatedPriceIsManual: 1,
      );
      // 確定行 6000・8000（平均7000）
      await insertExpenseRow(
          id: 1, date: '20250601', price: 6000, fixedCostId: 10);
      await insertExpenseRow(
          id: 2, date: '20250701', price: 8000, fixedCostId: 10);
      await insertExpenseRow(
        id: 3,
        date: '20250710',
        price: null,
        fixedCostId: 10,
        isConfirmed: 0,
        estimatedPrice: 9000,
      );

      final master = await repository.fetch(fixedCostId: 10);
      await repository.updateWithAutoEstimatedPriceSync(
        master.copyWith(estimatedPriceIsManual: 0),
      );

      final updated = await repository.fetch(fixedCostId: 10);
      expect(updated.estimatedPriceIsManual, 0);
      expect(updated.estimatedPrice, 7000);
      final rows = await DatabaseHelper.instance.query(
        'SELECT ${SqfExpense.estimatedPrice} AS estimatedPrice FROM ${SqfExpense.tableName} WHERE ${SqfExpense.id} = 3',
      );
      expect(rows.single['estimatedPrice'], 7000);
    });

    test('確定行が0件なら現在値を保持したまま未確定行へ同期する', () async {
      await insertFixedCostRow(
        id: 10,
        name: '電気代',
        variable: 1,
        estimatedPrice: 9000,
        estimatedPriceIsManual: 1,
      );
      await insertExpenseRow(
        id: 1,
        date: '20250710',
        price: null,
        fixedCostId: 10,
        isConfirmed: 0,
        estimatedPrice: 3000,
      );

      final master = await repository.fetch(fixedCostId: 10);
      await repository.updateWithAutoEstimatedPriceSync(
        master.copyWith(estimatedPriceIsManual: 0),
      );

      final updated = await repository.fetch(fixedCostId: 10);
      expect(updated.estimatedPriceIsManual, 0);
      // 平均を求められないので現在値（9000）を保持する
      expect(updated.estimatedPrice, 9000);
      final rows = await DatabaseHelper.instance.query(
        'SELECT ${SqfExpense.estimatedPrice} AS estimatedPrice FROM ${SqfExpense.tableName} WHERE ${SqfExpense.id} = 1',
      );
      expect(rows.single['estimatedPrice'], 9000);
    });
  });
}
