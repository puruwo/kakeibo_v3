// ImplementsExpenseBigCategoryRepository のDB結合テスト
//
// 支出大カテゴリーは onCreate で12件シードされる（v10で固定費由来の5件が末尾に加わった）。
// 並び順は _id ではなく display_order である点、
// 存在しないIDを引いたときに例外ではなく空の既定エンティティが返る点を固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/repository/expense_big_category_repository.dart';
import 'package:kakeibo/theme/category_palette.dart';

import '../../helper/db_test_helper.dart';

/// onCreate がシードする支出大カテゴリー名（表示順）
///
/// 末尾5件は v10（固定費カテゴリー統合）で追加された固定費由来のカテゴリー。
const _seedNames = [
  '食費',
  '日用品',
  '遊び娯楽',
  '交通費',
  '衣服美容',
  '医療費',
  '雑費',
  '住居費',
  'サブスク',
  '通信費',
  '光熱費',
  '固定費その他',
];

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsExpenseBigCategoryRepository();

  group('fetchAll', () {
    test('シードされた12件をdisplay_order昇順で返す', () async {
      final results = await repository.fetchAll();

      expect(results.length, 12);
      expect(results.map((e) => e.bigCategoryName).toList(), _seedNames);
      expect(results.map((e) => e.displayOrder).toList(), [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
      ]);
    });

    test('色コード・アイコンパス・表示フラグがエンティティへマッピングされる', () async {
      final results = await repository.fetchAll();

      expect(
        results.first,
        const ExpenseBigCategoryEntity(
          id: 1,
          colorCode: CategoryPalette.expense1Hex,
          bigCategoryName: '食費',
          resourcePath: 'assets/images/icon_meal.svg',
          displayOrder: 0,
          isDisplayed: 1,
        ),
      );
    });

    test('idではなくdisplay_orderで並ぶ（表示順を入れ替えると順番が変わる）', () async {
      // id=1（食費）の表示順を最後尾より後ろへ動かす
      await repository.update(
        entity: const ExpenseBigCategoryEntity(
          id: 1,
          colorCode: CategoryPalette.expense1Hex,
          bigCategoryName: '食費',
          resourcePath: 'assets/images/icon_meal.svg',
          displayOrder: 99,
          isDisplayed: 1,
        ),
      );
      await settleDbWrites();

      final results = await repository.fetchAll();

      expect(results.map((e) => e.id).toList(), [
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        1,
      ]);
    });

    test('is_displayed = 0 のカテゴリーも除外されない', () async {
      await repository.update(
        entity: const ExpenseBigCategoryEntity(
          id: 2,
          colorCode: CategoryPalette.expense2Hex,
          bigCategoryName: '日用品',
          resourcePath: 'assets/images/icon_commodity.svg',
          displayOrder: 1,
          isDisplayed: 0,
        ),
      );
      await settleDbWrites();

      final results = await repository.fetchAll();

      // 絞り込み条件が無いSQLなので非表示カテゴリーも返る
      expect(results.length, 12);
      expect(results.firstWhere((e) => e.id == 2).isDisplayed, 0);
    });
  });

  group('fetchByBigCategory', () {
    test('id指定でその大カテゴリーを返す', () async {
      final result = await repository.fetchByBigCategory(bigCategoryId: 3);

      expect(result.bigCategoryName, '遊び娯楽');
      expect(result.colorCode, CategoryPalette.expense3Hex);
      expect(result.displayOrder, 2);
    });

    test('存在しないidなら空の既定エンティティを返す', () async {
      final result = await repository.fetchByBigCategory(bigCategoryId: 999);

      // 0件時は jsonList[0] で例外→catch節の既定値が返る
      expect(
        result,
        const ExpenseBigCategoryEntity(
          id: 0,
          colorCode: '',
          bigCategoryName: '',
          resourcePath: '',
          displayOrder: 0,
          isDisplayed: 0,
        ),
      );
    });
  });

  group('update', () {
    test('指定idの行だけが書き換わる', () async {
      await repository.update(
        entity: const ExpenseBigCategoryEntity(
          id: 4,
          colorCode: '000000',
          bigCategoryName: '交通',
          resourcePath: 'assets/images/icon_others.svg',
          displayOrder: 3,
          isDisplayed: 0,
        ),
      );
      await settleDbWrites();

      final results = await repository.fetchAll();
      final updated = results.firstWhere((e) => e.id == 4);
      expect(updated.bigCategoryName, '交通');
      expect(updated.colorCode, '000000');
      expect(updated.resourcePath, 'assets/images/icon_others.svg');
      expect(updated.isDisplayed, 0);

      // 他の行は変化しない
      expect(results.length, 12);
      expect(results.firstWhere((e) => e.id == 5).bigCategoryName, '衣服美容');
    });

    test('存在しないidを指定しても何も変わらない', () async {
      await repository.update(
        entity: const ExpenseBigCategoryEntity(
          id: 999,
          colorCode: '000000',
          bigCategoryName: '存在しない',
          resourcePath: '',
          displayOrder: 0,
          isDisplayed: 1,
        ),
      );
      await settleDbWrites();

      final results = await repository.fetchAll();
      expect(results.length, 12);
      expect(results.map((e) => e.bigCategoryName).toList(), _seedNames);
    });
  });

  group('add', () {
    test('シードの次のidが採番され、指定した値がそのまま保存される', () async {
      final id = await repository.add(
        entity: const ExpenseBigCategoryEntity(
          id: 0,
          colorCode: CategoryPalette.expense8Hex,
          bigCategoryName: '教育費',
          resourcePath: 'assets/images/icon_others.svg',
          displayOrder: 12,
          isDisplayed: 1,
        ),
      );

      // シード12件の次
      expect(id, 13);
      final added = await repository.fetchByBigCategory(bigCategoryId: id);
      expect(added.bigCategoryName, '教育費');
      expect(added.colorCode, CategoryPalette.expense8Hex);
      expect(added.displayOrder, 12);
    });

    test('追加したカテゴリーは表示順の位置に並ぶ', () async {
      await repository.add(
        entity: const ExpenseBigCategoryEntity(
          id: 0,
          colorCode: CategoryPalette.expense8Hex,
          bigCategoryName: '教育費',
          resourcePath: 'assets/images/icon_others.svg',
          // 先頭（食費のdisplay_order=0）より前に置く
          displayOrder: -1,
          isDisplayed: 1,
        ),
      );

      final results = await repository.fetchAll();

      expect(results.length, 13);
      expect(results.first.bigCategoryName, '教育費');
    });
  });
}
