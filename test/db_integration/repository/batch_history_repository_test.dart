// ImplementsBatchHistoryRepository のDB結合テスト
//
// batch_history は onCreate で初期レコードが1件入るテーブルなので、
// 「初期レコードがある状態」と「空にした状態」の両方を確かめる。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_entity.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/repository/batch_history_repository.dart';

import '../../helper/db_test_helper.dart';

/// onCreateが入れる初期レコードを消し、日付を自分で決められる状態にする
Future<void> _clearBatchHistory() async {
  final db = await openTestDatabase();
  await db.delete(SqfBatchHistory.tableName);
}

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsBatchHistoryRepository();

  group('fetchAll', () {
    test('onCreate直後は初期レコード1件だけを返す', () async {
      final results = await repository.fetchAll();

      expect(results.length, 1);
      // 初期レコードは「実行済み」ステータス
      expect(results.single.status, 1);
      expect(results.single.startDate, results.single.endDate);
    });

    test('追加したレコードを初期レコードと合わせてid昇順で返す', () async {
      await insertBatchHistoryRow(
        id: 10,
        startDate: '20250625',
        endDate: '20250724',
      );
      await insertBatchHistoryRow(
        id: 20,
        startDate: '20250725',
        endDate: '20250824',
      );

      final results = await repository.fetchAll();

      expect(results.length, 3);
      expect(results.map((e) => e.id).toList(), [1, 10, 20]);
    });

    test('レコードが1件も無いなら空リストを返す', () async {
      await _clearBatchHistory();

      final results = await repository.fetchAll();

      expect(results, isEmpty);
    });
  });

  group('fetch', () {
    test('開始日・終了日の両方が一致するレコードを返す', () async {
      await _clearBatchHistory();
      await insertBatchHistoryRow(
        id: 10,
        startDate: '20250625',
        endDate: '20250724',
        status: 1,
      );

      final result = await repository.fetch(
        startDate: '20250625',
        endDate: '20250724',
      );

      expect(
        result,
        const BatchHistoryEntity(
          id: 10,
          startDate: '20250625',
          endDate: '20250724',
          status: 1,
        ),
      );
    });

    test('開始日だけ一致して終了日が違うならデフォルト値を返す', () async {
      await _clearBatchHistory();
      await insertBatchHistoryRow(
        id: 10,
        startDate: '20250625',
        endDate: '20250724',
      );

      final result = await repository.fetch(
        startDate: '20250625',
        endDate: '20250725',
      );

      // 0件のとき jsonList[0] が例外になり、catch側のデフォルト値が返る
      expect(
        result,
        const BatchHistoryEntity(id: 0, startDate: '', endDate: '', status: 0),
      );
    });

    test('一致するレコードが1件も無いならデフォルト値を返す', () async {
      await _clearBatchHistory();

      final result = await repository.fetch(
        startDate: '20250625',
        endDate: '20250724',
      );

      expect(result.id, 0);
      expect(result.startDate, '');
      expect(result.endDate, '');
      expect(result.status, 0);
    });

    test('同じ開始日・終了日のレコードが複数あるならid昇順の先頭を返す', () async {
      await _clearBatchHistory();
      await insertBatchHistoryRow(
        id: 10,
        startDate: '20250625',
        endDate: '20250724',
        status: 1,
      );
      await insertBatchHistoryRow(
        id: 20,
        startDate: '20250625',
        endDate: '20250724',
        status: 0,
      );

      final result = await repository.fetch(
        startDate: '20250625',
        endDate: '20250724',
      );

      expect(result.id, 10);
      expect(result.status, 1);
    });
  });

  group('fetchLatestDate', () {
    test('end_dateが最大のレコードの終了日を返す', () async {
      await _clearBatchHistory();
      await insertBatchHistoryRow(
        id: 10,
        startDate: '20250625',
        endDate: '20250724',
      );
      await insertBatchHistoryRow(
        id: 20,
        startDate: '20250825',
        endDate: '20250924',
      );
      // id順とend_date順が食い違うデータを入れて、並び替えキーがend_dateであることを示す
      await insertBatchHistoryRow(
        id: 30,
        startDate: '20250725',
        endDate: '20250824',
      );

      final latest = await repository.fetchLatestDate();

      expect(latest, '20250924');
    });

    test('年跨ぎでもyyyyMMdd文字列比較で最新を選ぶ', () async {
      await _clearBatchHistory();
      await insertBatchHistoryRow(
        id: 10,
        startDate: '20251225',
        endDate: '20251231',
      );
      await insertBatchHistoryRow(
        id: 20,
        startDate: '20260101',
        endDate: '20260124',
      );

      final latest = await repository.fetchLatestDate();

      expect(latest, '20260124');
    });

    test('レコードが1件も無いなら空文字を返す', () async {
      await _clearBatchHistory();

      final latest = await repository.fetchLatestDate();

      expect(latest, '');
    });
  });

  group('insert', () {
    test('1件追加され、採番されたidが返る', () async {
      await _clearBatchHistory();

      final id = await repository.insert(
        const BatchHistoryEntity(
          startDate: '20250625',
          endDate: '20250724',
          status: 1,
        ),
      );

      // onCreateの初期レコードが_id=1を使っているため、次は2
      expect(id, 2);
      expect(
        await DatabaseHelper.instance.queryRowCount(SqfBatchHistory.tableName),
        1,
      );
    });

    test('追加した内容がfetchAll・fetchで読み出せる', () async {
      await _clearBatchHistory();

      await repository.insert(
        const BatchHistoryEntity(
          startDate: '20250625',
          endDate: '20250724',
          status: 1,
        ),
      );

      final all = await repository.fetchAll();
      expect(all.single.startDate, '20250625');
      expect(all.single.endDate, '20250724');
      expect(all.single.status, 1);

      final fetched = await repository.fetch(
        startDate: '20250625',
        endDate: '20250724',
      );
      expect(fetched.startDate, '20250625');
    });
  });
}
