// 記録画面のカテゴリーグリッドに直接出すカテゴリーの規則（KP-032）のUT
//
// default_displayed = 1 のものを表示順の先頭から最大29件に打ち切る純粋関数と、
// セル数からページ数を求める計算を見る。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/category/register_grid_category_rule.dart';
import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';

void main() {
  ExpenseCategoryEntity category({
    required int id,
    required int defaultDisplayed,
  }) {
    return ExpenseCategoryEntity(
      id: id,
      smallCategoryOrderKey: id,
      bigCategoryKey: 1,
      displaydOrderInBig: id,
      categoryName: 'カテゴリー$id',
      defaultDisplayed: defaultDisplayed,
      bigCategoryName: '生活費',
      colorCode: 'FFAA00',
      resourcePath: 'assets/images/icon_meal.svg',
      displayOrder: 1,
      isDisplayed: 1,
      sortKey: id,
    );
  }

  group('RegisterGridCategoryRule.displayed', () {
    test('default_displayed が 1 のものだけを、渡された順のまま返す', () {
      final all = [
        category(id: 1, defaultDisplayed: 1),
        category(id: 2, defaultDisplayed: 0),
        category(id: 3, defaultDisplayed: 1),
      ];

      final displayed = RegisterGridCategoryRule.displayed(all);

      expect(displayed.map((e) => e.id), [1, 3]);
    });

    test('30件以上に旗が立っていても先頭29件で打ち切る', () {
      final all = List.generate(
        31,
        (i) => category(id: i + 1, defaultDisplayed: 1),
      );

      final displayed = RegisterGridCategoryRule.displayed(all);

      expect(displayed, hasLength(RegisterGridCategoryRule.maxDisplayedCount));
      expect(displayed.length, 29);
      expect(displayed.first.id, 1);
      expect(displayed.last.id, 29);
    });

    test('旗が立っていないものは上限の数に入れない（30件目以降でも表示中になれる）', () {
      final all = [
        for (var i = 1; i <= 5; i++) category(id: i, defaultDisplayed: 0),
        for (var i = 6; i <= 36; i++) category(id: i, defaultDisplayed: 1),
      ];

      final displayed = RegisterGridCategoryRule.displayed(all);

      expect(displayed.first.id, 6);
      expect(displayed.last.id, 34);
      expect(displayed, hasLength(29));
    });

    test('1件も無ければ空', () {
      expect(
        RegisterGridCategoryRule.displayed(<ExpenseCategoryEntity>[]),
        isEmpty,
      );
    });
  });

  group('RegisterGridCategoryRule.isFull / pageCountFor', () {
    test('29件で上限、28件なら追加できる', () {
      expect(RegisterGridCategoryRule.isFull(29), isTrue);
      expect(RegisterGridCategoryRule.isFull(30), isTrue);
      expect(RegisterGridCategoryRule.isFull(28), isFalse);
    });

    test('セル数からページ数を求める（15セル／ページ・最低1ページ）', () {
      expect(RegisterGridCategoryRule.pageCountFor(0), 1);
      expect(RegisterGridCategoryRule.pageCountFor(1), 1);
      expect(RegisterGridCategoryRule.pageCountFor(15), 1);
      expect(RegisterGridCategoryRule.pageCountFor(16), 2);
      // 29件＋「すべて」＝30セルで2ページに収まる
      expect(RegisterGridCategoryRule.pageCountFor(30), 2);
    });
  });
}
