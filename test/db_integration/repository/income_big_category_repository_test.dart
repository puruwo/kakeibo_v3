// ImplementsIncomeBigCategoryRepository のDB結合テスト
//
// 収入大カテゴリーは onCreate で2件（月次収入・ボーナス）シードされる。
// この2件は拠出元の判定などで他機能からハードコード参照されるため削除できない。
// そのガードと、存在しないIDを引いたときの既定エンティティを固定する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/repository/income_big_category_repository.dart';
import 'package:kakeibo/theme/category_palette.dart';

import '../../helper/db_test_helper.dart';

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsIncomeBigCategoryRepository();

  group('fetchAll', () {
    test('シードされた2件をid昇順で返す', () async {
      final results = await repository.fetchAll();

      expect(results.map((e) => e.id).toList(), [1, 2]);
      expect(results.map((e) => e.name).toList(), ['月次収入', 'ボーナス']);
    });

    test('色コード・アイコンパスがエンティティへマッピングされる', () async {
      final results = await repository.fetchAll();

      expect(
        results.first,
        const IncomeBigCategoryEntity(
          id: 1,
          name: '月次収入',
          colorCode: CategoryPalette.income1Hex,
          iconPath: 'assets/images/icon_regular_income.svg',
        ),
      );
      expect(results[1].colorCode, CategoryPalette.income2Hex);
      expect(results[1].iconPath, 'assets/images/icon_extra_income.svg');
    });

    test('追加した大カテゴリーもid昇順で末尾に並ぶ', () async {
      await repository.add(
        entity: const IncomeBigCategoryEntity(
          id: 0,
          name: '副業',
          colorCode: CategoryPalette.income3Hex,
          iconPath: 'assets/images/icon_others.svg',
        ),
      );

      final results = await repository.fetchAll();

      expect(results.map((e) => e.id).toList(), [1, 2, 3]);
      expect(results.last.name, '副業');
    });
  });

  group('fetchByBigCategory', () {
    test('id指定でその大カテゴリーを返す', () async {
      final result = await repository.fetchByBigCategory(bigCategoryId: 2);

      expect(result.name, 'ボーナス');
      expect(result.colorCode, CategoryPalette.income2Hex);
    });

    test('存在しないidなら空の既定エンティティを返す', () async {
      final result = await repository.fetchByBigCategory(bigCategoryId: 999);

      // 0件時は jsonList[0] で例外→catch節の既定値が返る
      expect(
        result,
        const IncomeBigCategoryEntity(
          id: 0,
          name: '',
          colorCode: '',
          iconPath: '',
        ),
      );
    });
  });

  group('add', () {
    test('シードの次のidが採番され、指定した値がそのまま保存される', () async {
      final id = await repository.add(
        entity: const IncomeBigCategoryEntity(
          id: 0,
          name: '副業',
          colorCode: '123456',
          iconPath: 'assets/images/icon_others.svg',
        ),
      );

      // シード2件の次
      expect(id, 3);
      final added = await repository.fetchByBigCategory(bigCategoryId: id);
      expect(added.name, '副業');
      expect(added.colorCode, '123456');
      expect(added.iconPath, 'assets/images/icon_others.svg');
    });
  });

  group('update', () {
    test('指定idの行だけが書き換わる', () async {
      await repository.update(
        entity: const IncomeBigCategoryEntity(
          id: 2,
          name: '賞与',
          colorCode: '000000',
          iconPath: 'assets/images/icon_others.svg',
        ),
      );

      final results = await repository.fetchAll();
      expect(results.firstWhere((e) => e.id == 2).name, '賞与');
      expect(results.firstWhere((e) => e.id == 2).colorCode, '000000');

      // 他の行は変化しない
      expect(results.firstWhere((e) => e.id == 1).name, '月次収入');
      expect(results.length, 2);
    });

    test('存在しないidを指定しても何も変わらない', () async {
      await repository.update(
        entity: const IncomeBigCategoryEntity(
          id: 999,
          name: '存在しない',
          colorCode: '000000',
          iconPath: '',
        ),
      );

      final results = await repository.fetchAll();
      expect(results.length, 2);
      expect(results.map((e) => e.name).toList(), ['月次収入', 'ボーナス']);
    });
  });

  group('delete', () {
    test('追加した大カテゴリーは物理削除できる', () async {
      final id = await repository.add(
        entity: const IncomeBigCategoryEntity(
          id: 0,
          name: '副業',
          colorCode: '123456',
          iconPath: '',
        ),
      );

      await repository.delete(id: id);

      final results = await repository.fetchAll();
      expect(results.map((e) => e.id).toList(), [1, 2]);
    });

    test('id=1（月次収入）は削除できずStateErrorになる', () async {
      await expectLater(
        () => repository.delete(id: 1),
        throwsA(isA<StateError>()),
      );

      final results = await repository.fetchAll();
      expect(results.length, 2);
    });

    test('id=2（ボーナス）は削除できずStateErrorになる', () async {
      await expectLater(
        () => repository.delete(id: 2),
        throwsA(isA<StateError>()),
      );

      final results = await repository.fetchAll();
      expect(results.length, 2);
    });

    test('存在しないidを指定しても何も削除されない', () async {
      await repository.delete(id: 999);

      final results = await repository.fetchAll();
      expect(results.length, 2);
    });
  });

  group('getMaxId', () {
    test('シード直後は2を返す', () async {
      final maxId = await repository.getMaxId();

      expect(maxId, 2);
    });

    test('追加後は採番された最大idを返す', () async {
      await repository.add(
        entity: const IncomeBigCategoryEntity(
          id: 0,
          name: '副業',
          colorCode: '123456',
          iconPath: '',
        ),
      );

      final maxId = await repository.getMaxId();

      expect(maxId, 3);
    });
  });
}
