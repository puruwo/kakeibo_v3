// ImplementsExpenseSmallCategoryRepository のDB結合テスト
//
// 支出小カテゴリーは onCreate で20件シードされる（v10で固定費由来の5件が末尾に加わった）。
// fetchAll は _id 昇順、fetchByBigCategory は displayed_order_in_big 昇順と
// 並び順のキーが違うこと、getMaxSmallCategoryOrderKey が引数の大カテゴリーを
// 無視して全体の最大値を返すことを固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/repository/expense_small_category_repository.dart';

import '../../helper/db_test_helper.dart';

/// onCreate がシードする支出小カテゴリー名（_id 昇順）
const _seedNames = [
  '食費',
  'コンビニ',
  '外食',
  '社食',
  '消耗品',
  '雑貨',
  '遊び',
  '飲み',
  'ライブ',
  'ご褒美',
  '交通費',
  '帰省',
  'カット',
  '医療費',
  'その他',
  // 固定費由来（v10で追加。大カテゴリー8〜12と同名）
  '住居費',
  'サブスク',
  '通信費',
  '光熱費',
  '固定費その他',
];

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsExpenseSmallCategoryRepository();

  group('fetchAll', () {
    test('シードされた20件をid昇順で返す', () async {
      final results = await repository.fetchAll();

      expect(results.length, 20);
      expect(
        results.map((e) => e.id).toList(),
        List.generate(20, (i) => i + 1),
      );
      expect(results.map((e) => e.smallCategoryName).toList(), _seedNames);
    });

    test('全カラムがエンティティへ正しくマッピングされる', () async {
      final results = await repository.fetchAll();

      // id=5「消耗品」は大カテゴリー2の先頭（通し順4・カテゴリー内順0）
      expect(
        results[4],
        const ExpenseSmallCategoryEntity(
          id: 5,
          smallCategoryOrderKey: 4,
          bigCategoryKey: 2,
          displayedOrderInBig: 0,
          smallCategoryName: '消耗品',
          defaultDisplayed: 1,
        ),
      );
    });
  });

  group('fetchBySmallCategory', () {
    test('id指定でその小カテゴリーを返す', () async {
      final result = await repository.fetchBySmallCategory(smallCategoryId: 11);

      expect(result.smallCategoryName, '交通費');
      expect(result.bigCategoryKey, 4);
      expect(result.displayedOrderInBig, 0);
    });

    test('存在しないidなら空の既定エンティティを返す', () async {
      final result = await repository.fetchBySmallCategory(
        smallCategoryId: 999,
      );

      // 0件時は jsonList[0] で例外→catch節の既定値が返る
      expect(
        result,
        const ExpenseSmallCategoryEntity(
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
    test('指定した大カテゴリーの小カテゴリーをカテゴリー内表示順で返す', () async {
      final results = await repository.fetchByBigCategory(bigCategoryId: 1);

      expect(results.map((e) => e.smallCategoryName).toList(), [
        '食費',
        'コンビニ',
        '外食',
        '社食',
      ]);
    });

    test('別の大カテゴリーの小カテゴリーは含まない', () async {
      final results = await repository.fetchByBigCategory(bigCategoryId: 5);

      // 大カテゴリー5（衣服美容）は「カット」1件だけ
      expect(results.map((e) => e.id).toList(), [13]);
    });

    test('idではなくdisplayed_order_in_bigの昇順で並ぶ', () async {
      // id=1（食費）をカテゴリー内の最後尾へ動かす
      await repository.update(
        entity: const ExpenseSmallCategoryEntity(
          id: 1,
          smallCategoryOrderKey: 0,
          bigCategoryKey: 1,
          displayedOrderInBig: 9,
          smallCategoryName: '食費',
          defaultDisplayed: 1,
        ),
      );
      await settleDbWrites();

      final results = await repository.fetchByBigCategory(bigCategoryId: 1);

      expect(results.map((e) => e.id).toList(), [2, 3, 4, 1]);
    });

    test('該当する小カテゴリーが無いなら空リストを返す', () async {
      final results = await repository.fetchByBigCategory(bigCategoryId: 999);

      expect(results, isEmpty);
    });
  });

  group('update', () {
    test('指定idの行だけが書き換わる（所属する大カテゴリーの変更も反映される）', () async {
      await repository.update(
        entity: const ExpenseSmallCategoryEntity(
          id: 2,
          smallCategoryOrderKey: 1,
          bigCategoryKey: 7,
          displayedOrderInBig: 1,
          smallCategoryName: 'コンビニ弁当',
          defaultDisplayed: 0,
        ),
      );
      await settleDbWrites();

      final moved = await repository.fetchBySmallCategory(smallCategoryId: 2);
      expect(moved.smallCategoryName, 'コンビニ弁当');
      expect(moved.bigCategoryKey, 7);
      expect(moved.defaultDisplayed, 0);

      // 元の大カテゴリー1からは外れ、移動先の大カテゴリー7に現れる
      final big1 = await repository.fetchByBigCategory(bigCategoryId: 1);
      expect(big1.map((e) => e.id), isNot(contains(2)));
      final big7 = await repository.fetchByBigCategory(bigCategoryId: 7);
      expect(big7.map((e) => e.id), contains(2));

      // 他の行は変化しない
      final all = await repository.fetchAll();
      expect(all.length, 20);
      expect(all.firstWhere((e) => e.id == 3).smallCategoryName, '外食');
    });

    test('存在しないidを指定しても何も変わらない', () async {
      await repository.update(
        entity: const ExpenseSmallCategoryEntity(
          id: 999,
          smallCategoryOrderKey: 99,
          bigCategoryKey: 1,
          displayedOrderInBig: 99,
          smallCategoryName: '存在しない',
          defaultDisplayed: 1,
        ),
      );
      await settleDbWrites();

      final results = await repository.fetchAll();
      expect(results.length, 20);
      expect(results.map((e) => e.smallCategoryName).toList(), _seedNames);
    });
  });

  group('add', () {
    test('シードの次のidが採番され、指定した値がそのまま保存される', () async {
      final id = await repository.add(
        entity: const ExpenseSmallCategoryEntity(
          id: 0,
          smallCategoryOrderKey: 20,
          bigCategoryKey: 1,
          displayedOrderInBig: 4,
          smallCategoryName: 'カフェ',
          defaultDisplayed: 1,
        ),
      );

      // シード20件の次
      expect(id, 21);
      final added = await repository.fetchBySmallCategory(smallCategoryId: id);
      expect(added.smallCategoryName, 'カフェ');
      expect(added.smallCategoryOrderKey, 20);
      expect(added.bigCategoryKey, 1);
      expect(added.displayedOrderInBig, 4);
    });

    test('追加した小カテゴリーは大カテゴリーの一覧にも表示順どおりに現れる', () async {
      await repository.add(
        entity: const ExpenseSmallCategoryEntity(
          id: 0,
          smallCategoryOrderKey: 15,
          bigCategoryKey: 1,
          // 既存の先頭（食費のdisplayed_order_in_big=0）より前へ置く
          displayedOrderInBig: -1,
          smallCategoryName: 'カフェ',
          defaultDisplayed: 1,
        ),
      );

      final results = await repository.fetchByBigCategory(bigCategoryId: 1);

      expect(results.first.smallCategoryName, 'カフェ');
      expect(results.length, 5);
    });
  });

  group('getMaxSmallCategoryOrderKey', () {
    test('シード直後は全カテゴリー通しの最大値19を返す', () async {
      final maxOrderKey = await repository.getMaxSmallCategoryOrderKey(
        bigCategoryId: 1,
      );

      expect(maxOrderKey, 19);
    });

    test('引数の大カテゴリーで絞り込まない（どの大カテゴリーでも同じ値）', () async {
      final forBig1 = await repository.getMaxSmallCategoryOrderKey(
        bigCategoryId: 1,
      );
      final forBig6 = await repository.getMaxSmallCategoryOrderKey(
        bigCategoryId: 6,
      );
      final forUnknown = await repository.getMaxSmallCategoryOrderKey(
        bigCategoryId: 999,
      );

      expect(forBig1, 19);
      expect(forBig6, 19);
      expect(forUnknown, 19);
    });

    test('より大きい通し順を追加するとその値を返す', () async {
      await repository.add(
        entity: const ExpenseSmallCategoryEntity(
          id: 0,
          smallCategoryOrderKey: 30,
          bigCategoryKey: 6,
          displayedOrderInBig: 1,
          smallCategoryName: '薬',
          defaultDisplayed: 1,
        ),
      );

      final maxOrderKey = await repository.getMaxSmallCategoryOrderKey(
        bigCategoryId: 1,
      );

      expect(maxOrderKey, 30);
    });
  });

  group('fetchSmallCategoryIdListByBigCategoryId', () {
    test('指定した大カテゴリーに属する小カテゴリーIDを返す', () async {
      final ids = await repository.fetchSmallCategoryIdListByBigCategoryId(
        bigCategoryId: 3,
      );

      // 大カテゴリー3（遊び娯楽）は 遊び・飲み・ライブ・ご褒美
      expect(ids, [7, 8, 9, 10]);
    });

    test('該当する小カテゴリーが無いなら空リストを返す', () async {
      final ids = await repository.fetchSmallCategoryIdListByBigCategoryId(
        bigCategoryId: 999,
      );

      expect(ids, isEmpty);
    });
  });
}
