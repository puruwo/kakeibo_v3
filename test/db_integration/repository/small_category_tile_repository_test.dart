// ImplementsSmallCategoryTileRepository のDB結合テスト
//
// カテゴリーカードを開いたときの小カテゴリータイル一覧。
// 「既定非表示(default_displayed = 0)のタイルは実績があるときだけ現れる」条件と、
// 期間・拠出元の絞り込みを仕様として固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/repository/small_category_tile_repository.dart';

import '../../helper/db_test_helper.dart';

/// 基準シナリオの集計期間（開始日25日設定で 2025/7/6 を選んだときの期間）
final _fromDate = DateTime(2025, 6, 25);
final _toDate = DateTime(2025, 7, 24);

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsSmallCategoryTileRepository();

  group('fetchAll', () {
    test('小カテゴリーごとの合計額と件数をカテゴリー内表示順で返す', () async {
      // 大カテゴリー1（食費）の小カテゴリーは 1=食費 / 2=コンビニ / 3=外食 / 4=社食
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 100,
        smallCategoryId: 1,
      );
      await insertExpenseRow(
        id: 2,
        date: '20250702',
        price: 200,
        smallCategoryId: 1,
      );
      await insertExpenseRow(
        id: 3,
        date: '20250703',
        price: 50,
        smallCategoryId: 3,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        bigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results.map((e) => e.id).toList(), [1, 2, 3, 4]);
      expect(results.map((e) => e.smallCategoryName).toList(), [
        '食費',
        'コンビニ',
        '外食',
        '社食',
      ]);
      expect(results.map((e) => e.totalExpenseBySmallCategory).toList(), [
        300,
        0,
        50,
        0,
      ]);
      expect(results.map((e) => e.recordCount).toList(), [2, 0, 1, 0]);
    });

    test('実績が無い小カテゴリーもcoalesceで0円・0件として返る', () async {
      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        bigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results.length, 4);
      expect(
        results.every(
          (e) => e.totalExpenseBySmallCategory == 0 && e.recordCount == 0,
        ),
        isTrue,
      );
    });

    test('既定非表示(default_displayed = 0)かつ実績が無いタイルは返さない', () async {
      await updateExpenseSmallCategoryDefaultDisplayed(
        id: 4,
        defaultDisplayed: 0,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        bigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results.map((e) => e.id).toList(), [1, 2, 3]);
    });

    test('既定非表示でも期間内に実績があればタイルを返す', () async {
      await updateExpenseSmallCategoryDefaultDisplayed(
        id: 4,
        defaultDisplayed: 0,
      );
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 480,
        smallCategoryId: 4,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        bigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results.map((e) => e.id).toList(), [1, 2, 3, 4]);
      expect(results.last.totalExpenseBySmallCategory, 480);
    });

    test('別の大カテゴリーの小カテゴリーは含まない', () async {
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 100,
        smallCategoryId: 1,
      );
      await insertExpenseRow(
        id: 2,
        date: '20250701',
        price: 300,
        smallCategoryId: 5,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        bigCategoryId: 2,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      // 大カテゴリー2（日用品）は 5=消耗品 / 6=雑貨
      expect(results.map((e) => e.id).toList(), [5, 6]);
      expect(results.first.totalExpenseBySmallCategory, 300);
    });

    test('指定した拠出元の支出だけを合計する', () async {
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 100,
        smallCategoryId: 1,
        incomeSourceBigCategory: 1,
      );
      await insertExpenseRow(
        id: 2,
        date: '20250701',
        price: 999,
        smallCategoryId: 1,
        incomeSourceBigCategory: 2,
      );

      final salary = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        bigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );
      final bonus = await repository.fetchAll(
        incomeSourceBigCategoryId: 2,
        bigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(salary.first.totalExpenseBySmallCategory, 100);
      expect(salary.first.recordCount, 1);
      expect(bonus.first.totalExpenseBySmallCategory, 999);
    });

    test('期間開始日・終了日ちょうどを含み、前日・翌日は含まない', () async {
      await insertExpenseRow(
        id: 1,
        date: '20250624',
        price: 1,
        smallCategoryId: 1,
      );
      await insertExpenseRow(
        id: 2,
        date: '20250625',
        price: 100,
        smallCategoryId: 1,
      );
      await insertExpenseRow(
        id: 3,
        date: '20250724',
        price: 400,
        smallCategoryId: 1,
      );
      await insertExpenseRow(
        id: 4,
        date: '20250725',
        price: 2,
        smallCategoryId: 1,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        bigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results.first.totalExpenseBySmallCategory, 500);
      expect(results.first.recordCount, 2);
    });

    test('存在しない大カテゴリーを指定すると空リストを返す', () async {
      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        bigCategoryId: 999,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results, isEmpty);
    });

    test('displeyOrderはSQLの別名と綴りが違うため常に0になる（実装準拠）', () async {
      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        bigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      // SQLは displayed_order_in_big を `displayedOrder` として返すが、
      // エンティティ側のフィールドは `displeyOrder`。キーが一致しないので既定値0のまま
      expect(results.map((e) => e.displeyOrder).toList(), [0, 0, 0, 0]);
    });
  });
}
