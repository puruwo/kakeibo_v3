// ImplementsFixedCostCategoryRepository のDB結合テスト
//
// 固定費カテゴリーは onCreate で5件シードされる（住居費・サブスク・通信費・光熱費・その他）。
// このシードを起点に、採番・表示順・物理削除の挙動を固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/repository/fixed_cost_category_repository.dart';
import 'package:kakeibo/theme/category_palette.dart';

import '../../helper/db_test_helper.dart';

/// onCreate がシードする固定費カテゴリー名（表示順）
const _seedNames = ['住居費', 'サブスク', '通信費', '光熱費', 'その他'];

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsFixedCostCategoryRepository();

  group('fetchAll', () {
    test('シードされた5件をid昇順で返す', () async {
      final results = await repository.fetchAll();

      expect(results.map((e) => e.id).toList(), [1, 2, 3, 4, 5]);
      expect(results.map((e) => e.categoryName).toList(), _seedNames);
    });

    test('displayOrderは0始まりの連番・isDisplayedは1・色は固定費色でシードされる', () async {
      final results = await repository.fetchAll();

      expect(results.map((e) => e.displayOrder).toList(), [0, 1, 2, 3, 4]);
      expect(results.every((e) => e.isDisplayed == 1), isTrue);
      expect(
        results.every((e) => e.colorCode == CategoryPalette.fixedCostHex),
        isTrue,
      );
    });

    test('SQLで取得しないsortKeyは既定値0になる', () async {
      final results = await repository.fetchAll();

      // sortKeyは表示用の補助フィールドでDBには持たない
      expect(results.every((e) => e.sortKey == 0), isTrue);
    });

    test('追加したカテゴリーはid昇順で末尾に並ぶ', () async {
      await repository.insert(
        const FixedCostCategoryEntity(
          categoryName: '保険',
          colorCode: '123456',
          resourcePath: 'assets/images/icon_others.svg',
          displayOrder: 5,
        ),
      );

      final results = await repository.fetchAll();

      expect(results.length, 6);
      expect(results.last.categoryName, '保険');
    });
  });

  group('fetch', () {
    test('id指定でそのカテゴリーを返す', () async {
      final result = await repository.fetch(id: 3);

      expect(result.categoryName, '通信費');
      expect(result.displayOrder, 2);
      expect(result.resourcePath, 'assets/images/icon_cell_tower.svg');
    });

    test('存在しないidなら例外を投げる', () async {
      await expectLater(
        () => repository.fetch(id: 999),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('999'),
          ),
        ),
      );
    });
  });

  group('insert', () {
    test('シードの次のidが採番され、指定した値がそのまま保存される', () async {
      final id = await repository.insert(
        const FixedCostCategoryEntity(
          categoryName: '保険',
          colorCode: 'ABCDEF',
          resourcePath: 'assets/images/icon_others.svg',
          displayOrder: 5,
          isDisplayed: 0,
        ),
      );

      // シード5件の次
      expect(id, 6);
      final result = await repository.fetch(id: id);
      expect(result.categoryName, '保険');
      expect(result.colorCode, 'ABCDEF');
      expect(result.resourcePath, 'assets/images/icon_others.svg');
      expect(result.displayOrder, 5);
      expect(result.isDisplayed, 0);
    });

    test('idはエンティティの値ではなくAUTOINCREMENTで採番される', () async {
      final id = await repository.insert(
        const FixedCostCategoryEntity(
          id: 100,
          categoryName: '保険',
          colorCode: 'ABCDEF',
          resourcePath: 'assets/images/icon_others.svg',
        ),
      );

      expect(id, 6);
    });
  });

  group('update', () {
    test('指定idの行だけが書き換わる', () async {
      await repository.update(
        const FixedCostCategoryEntity(
          id: 2,
          categoryName: '定期購読',
          colorCode: '000000',
          resourcePath: 'assets/images/icon_others.svg',
          displayOrder: 9,
          isDisplayed: 0,
        ),
      );

      final results = await repository.fetchAll();
      final updated = results.firstWhere((e) => e.id == 2);
      expect(updated.categoryName, '定期購読');
      expect(updated.colorCode, '000000');
      expect(updated.displayOrder, 9);
      expect(updated.isDisplayed, 0);

      // 他の行は変化しない
      expect(results.firstWhere((e) => e.id == 1).categoryName, '住居費');
      expect(results.length, 5);
    });

    test('存在しないidを指定しても何も変わらない', () async {
      await repository.update(
        const FixedCostCategoryEntity(
          id: 999,
          categoryName: '存在しない',
          colorCode: '000000',
          resourcePath: '',
        ),
      );

      final results = await repository.fetchAll();
      expect(results.length, 5);
      expect(results.map((e) => e.categoryName).toList(), _seedNames);
    });
  });

  group('delete', () {
    test('指定idの行が物理削除される', () async {
      await repository.delete(2);

      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfFixedCostCategory.tableName,
        ),
        4,
      );
      final results = await repository.fetchAll();
      expect(results.map((e) => e.id).toList(), [1, 3, 4, 5]);
    });

    test('存在しないidを指定しても何も削除されない', () async {
      await repository.delete(999);

      expect(
        await DatabaseHelper.instance.queryRowCount(
          SqfFixedCostCategory.tableName,
        ),
        5,
      );
    });
  });

  group('getMaxDisplayOrder', () {
    test('シード直後はその他の表示順である4を返す', () async {
      final maxDisplayOrder = await repository.getMaxDisplayOrder();

      expect(maxDisplayOrder, 4);
    });

    test('より大きい表示順を追加するとその値を返す', () async {
      await repository.insert(
        const FixedCostCategoryEntity(
          categoryName: '保険',
          colorCode: 'ABCDEF',
          resourcePath: '',
          displayOrder: 10,
        ),
      );

      final maxDisplayOrder = await repository.getMaxDisplayOrder();

      expect(maxDisplayOrder, 10);
    });

    test('1件も無いなら（MAXがNULLになるため）0を返す', () async {
      for (var id = 1; id <= 5; id++) {
        await repository.delete(id);
      }

      final maxDisplayOrder = await repository.getMaxDisplayOrder();

      expect(maxDisplayOrder, 0);
    });
  });
}
