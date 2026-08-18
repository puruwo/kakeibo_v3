// ImplementsIncomeSmallCategoryRepository のDB結合テスト
//
// 収入小カテゴリーは onCreate で4件（給与・ボーナス・小遣い・臨時収入）シードされる。
// 大カテゴリー削除に連動する deleteByBigCategory が「削除したIDのリスト」を返す契約と、
// getMaxSmallCategoryOrderKey が引数の大カテゴリーを無視する挙動を固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/repository/income_small_category_repository.dart';

import '../../helper/db_test_helper.dart';

/// onCreate がシードする収入小カテゴリー名（_id 昇順）
const _seedNames = ['給与', 'ボーナス', '小遣い', '臨時収入'];

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsIncomeSmallCategoryRepository();

  group('fetchAll', () {
    test('シードされた4件をid昇順で返す', () async {
      final results = await repository.fetchAll();

      expect(results.map((e) => e.id).toList(), [1, 2, 3, 4]);
      expect(results.map((e) => e.smallCategoryName).toList(), _seedNames);
    });

    test('全カラムがエンティティへ正しくマッピングされる', () async {
      final results = await repository.fetchAll();

      // ボーナスだけが大カテゴリー2に属する
      expect(
        results[1],
        const IncomeSmallCategoryEntity(
          id: 2,
          smallCategoryOrderKey: 1,
          bigCategoryKey: 2,
          displayedOrderInBig: 1,
          smallCategoryName: 'ボーナス',
          defaultDisplayed: 1,
        ),
      );
    });
  });

  group('fetchBySmallCategory', () {
    test('id指定でその小カテゴリーを返す', () async {
      final result = await repository.fetchBySmallCategory(smallCategoryId: 3);

      expect(result.smallCategoryName, '小遣い');
      expect(result.bigCategoryKey, 1);
    });

    test('存在しないidなら空の既定エンティティを返す', () async {
      final result = await repository.fetchBySmallCategory(
        smallCategoryId: 999,
      );

      // 0件時は jsonList[0] で例外→catch節の既定値が返る
      expect(
        result,
        const IncomeSmallCategoryEntity(
          id: 0,
          smallCategoryOrderKey: 0,
          bigCategoryKey: 0,
          displayedOrderInBig: 0,
          smallCategoryName: '',
          defaultDisplayed: 0,
        ),
      );
    });
  });

  group('fetchByBigCategory', () {
    test('大カテゴリー1（月次収入）の小カテゴリーをカテゴリー内表示順で返す', () async {
      final results = await repository.fetchByBigCategory(bigCategoryId: 1);

      // displayed_order_in_big は 給与=0 / 小遣い=2 / 臨時収入=3
      expect(results.map((e) => e.smallCategoryName).toList(), [
        '給与',
        '小遣い',
        '臨時収入',
      ]);
    });

    test('大カテゴリー2（ボーナス）の小カテゴリーだけを返す', () async {
      final results = await repository.fetchByBigCategory(bigCategoryId: 2);

      expect(results.map((e) => e.id).toList(), [2]);
    });

    test('idではなくdisplayed_order_in_bigの昇順で並ぶ', () async {
      // id=1（給与）をカテゴリー内の最後尾へ動かす
      await repository.update(
        entity: const IncomeSmallCategoryEntity(
          id: 1,
          smallCategoryOrderKey: 0,
          bigCategoryKey: 1,
          displayedOrderInBig: 9,
          smallCategoryName: '給与',
          defaultDisplayed: 1,
        ),
      );

      final results = await repository.fetchByBigCategory(bigCategoryId: 1);

      expect(results.map((e) => e.id).toList(), [3, 4, 1]);
    });

    test('該当する小カテゴリーが無いなら空リストを返す', () async {
      final results = await repository.fetchByBigCategory(bigCategoryId: 999);

      expect(results, isEmpty);
    });
  });

  group('add', () {
    test('シードの次のidが採番され、指定した値がそのまま保存される', () async {
      final id = await repository.add(
        entity: const IncomeSmallCategoryEntity(
          id: 0,
          smallCategoryOrderKey: 4,
          bigCategoryKey: 1,
          displayedOrderInBig: 4,
          smallCategoryName: '副業',
          defaultDisplayed: 1,
        ),
      );

      // シード4件の次
      expect(id, 5);
      final added = await repository.fetchBySmallCategory(smallCategoryId: id);
      expect(added.smallCategoryName, '副業');
      expect(added.smallCategoryOrderKey, 4);
      expect(added.bigCategoryKey, 1);
      expect(added.displayedOrderInBig, 4);
    });
  });

  group('update', () {
    test('指定idの行だけが書き換わる（所属する大カテゴリーの変更も反映される）', () async {
      await repository.update(
        entity: const IncomeSmallCategoryEntity(
          id: 3,
          smallCategoryOrderKey: 2,
          bigCategoryKey: 2,
          displayedOrderInBig: 0,
          smallCategoryName: 'こづかい',
          defaultDisplayed: 0,
        ),
      );

      final moved = await repository.fetchBySmallCategory(smallCategoryId: 3);
      expect(moved.smallCategoryName, 'こづかい');
      expect(moved.bigCategoryKey, 2);
      expect(moved.defaultDisplayed, 0);

      // 大カテゴリー2へ移動している
      final big2 = await repository.fetchByBigCategory(bigCategoryId: 2);
      expect(big2.map((e) => e.id).toList(), [3, 2]);

      // 他の行は変化しない
      final all = await repository.fetchAll();
      expect(all.length, 4);
      expect(all.firstWhere((e) => e.id == 1).smallCategoryName, '給与');
    });

    test('存在しないidを指定しても何も変わらない', () async {
      await repository.update(
        entity: const IncomeSmallCategoryEntity(
          id: 999,
          smallCategoryOrderKey: 99,
          bigCategoryKey: 1,
          displayedOrderInBig: 99,
          smallCategoryName: '存在しない',
          defaultDisplayed: 1,
        ),
      );

      final results = await repository.fetchAll();
      expect(results.length, 4);
      expect(results.map((e) => e.smallCategoryName).toList(), _seedNames);
    });
  });

  group('delete', () {
    test('指定idの行が物理削除される', () async {
      await repository.delete(id: 3);

      final results = await repository.fetchAll();
      expect(results.map((e) => e.id).toList(), [1, 2, 4]);
    });

    test('存在しないidを指定しても何も削除されない', () async {
      await repository.delete(id: 999);

      final results = await repository.fetchAll();
      expect(results.length, 4);
    });
  });

  group('deleteByBigCategory', () {
    test('指定した大カテゴリーに紐づく小カテゴリーを全件削除し、削除したIDリストを返す', () async {
      final deletedIds = await repository.deleteByBigCategory(bigCategoryId: 1);

      // 大カテゴリー1は 給与(1)・小遣い(3)・臨時収入(4)
      expect(deletedIds, [1, 3, 4]);
      final results = await repository.fetchAll();
      expect(results.map((e) => e.id).toList(), [2]);
    });

    test('別の大カテゴリーの小カテゴリーは削除しない', () async {
      await repository.deleteByBigCategory(bigCategoryId: 2);

      final results = await repository.fetchAll();
      expect(results.map((e) => e.id).toList(), [1, 3, 4]);
    });

    test('該当が無いなら空リストを返し、1件も削除しない', () async {
      final deletedIds = await repository.deleteByBigCategory(
        bigCategoryId: 999,
      );

      expect(deletedIds, isEmpty);
      final results = await repository.fetchAll();
      expect(results.length, 4);
    });
  });

  group('getMaxSmallCategoryOrderKey', () {
    test('シード直後は全カテゴリー通しの最大値3を返す', () async {
      final maxOrderKey = await repository.getMaxSmallCategoryOrderKey(
        bigCategoryId: 1,
      );

      expect(maxOrderKey, 3);
    });

    test('引数の大カテゴリーで絞り込まない（どの大カテゴリーでも同じ値）', () async {
      final forBig1 = await repository.getMaxSmallCategoryOrderKey(
        bigCategoryId: 1,
      );
      final forBig2 = await repository.getMaxSmallCategoryOrderKey(
        bigCategoryId: 2,
      );
      final forUnknown = await repository.getMaxSmallCategoryOrderKey(
        bigCategoryId: 999,
      );

      expect(forBig1, 3);
      expect(forBig2, 3);
      expect(forUnknown, 3);
    });

    test('1件も無いなら（MAXがNULLになるため）0を返す', () async {
      await repository.deleteByBigCategory(bigCategoryId: 1);
      await repository.deleteByBigCategory(bigCategoryId: 2);

      final maxOrderKey = await repository.getMaxSmallCategoryOrderKey(
        bigCategoryId: 1,
      );

      expect(maxOrderKey, 0);
    });
  });

  group('fetchSmallCategoryIdListByBigCategoryId', () {
    test('指定した大カテゴリーに属する小カテゴリーIDを返す', () async {
      final ids = await repository.fetchSmallCategoryIdListByBigCategoryId(
        bigCategoryId: 1,
      );

      expect(ids, [1, 3, 4]);
    });

    test('該当する小カテゴリーが無いなら空リストを返す', () async {
      final ids = await repository.fetchSmallCategoryIdListByBigCategoryId(
        bigCategoryId: 999,
      );

      expect(ids, isEmpty);
    });
  });
}
