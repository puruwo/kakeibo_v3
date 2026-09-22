// 一括削除の一覧を組み立てる純粋関数（bulk_delete_list_service.dart）のテスト（KP-031）
//
// 全履歴を対象にするためカテゴリーは Map で引く。論理削除済みのカテゴリーや
// 参照先が無い行を落とさないこと、日付降順・同じ日の中は ID 降順の並びを確かめる。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_list_service.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/ui_value/daily_transaction_group/daily_transaction_group.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';

void main() {
  // 支出カテゴリー: 食費(1) › 外食(10)、論理削除済みの 旧カテゴリー(2) › 旧小(20)
  const bigFood = ExpenseBigCategoryEntity(
    id: 1,
    colorCode: 'FFAA00',
    bigCategoryName: '食費',
    resourcePath: 'assets/images/icon_meal.svg',
    displayOrder: 1,
    isDisplayed: 1,
  );
  const bigDeleted = ExpenseBigCategoryEntity(
    id: 2,
    colorCode: '123456',
    bigCategoryName: '旧カテゴリー',
    resourcePath: 'assets/images/icon_old.svg',
    displayOrder: 2,
    isDisplayed: 1,
    deleteFlag: 1,
  );
  const smallLunch = ExpenseSmallCategoryEntity(
    id: 10,
    smallCategoryOrderKey: 1,
    bigCategoryKey: 1,
    displayedOrderInBig: 1,
    smallCategoryName: '外食',
    defaultDisplayed: 1,
  );
  const smallDeleted = ExpenseSmallCategoryEntity(
    id: 20,
    smallCategoryOrderKey: 2,
    bigCategoryKey: 2,
    displayedOrderInBig: 1,
    smallCategoryName: '旧小',
    defaultDisplayed: 1,
    deleteFlag: 1,
  );

  group('parseRecordDate', () {
    test('yyyyMMdd を日付だけの DateTime にする', () {
      expect(parseRecordDate('20250706'), DateTime(2025, 7, 6));
      // 年またぎ
      expect(parseRecordDate('20251231'), DateTime(2025, 12, 31));
      expect(parseRecordDate('20260101'), DateTime(2026, 1, 1));
    });

    test('形式が崩れた文字列は 1970/1/1 に寄せる（行を落とさない）', () {
      expect(parseRecordDate(''), DateTime(1970, 1, 1));
      expect(parseRecordDate('2025-07-06'), DateTime(1970, 1, 1));
      expect(parseRecordDate('2025AB06'), DateTime(1970, 1, 1));
    });
  });

  group('buildBulkDeleteExpenseTiles', () {
    test('カテゴリーを Map で引いて名前・色・アイコンを埋める', () {
      final tiles = buildBulkDeleteExpenseTiles(
        expenses: const [
          ExpenseEntity(
            id: 1,
            date: '20250706',
            price: 1200,
            paymentCategoryId: 10,
            memo: 'ランチ',
          ),
        ],
        smallCategories: const [smallLunch],
        bigCategories: const [bigFood],
      );

      expect(tiles, [
        ExpenseHistoryTileValue(
          id: 1,
          date: DateTime(2025, 7, 6),
          price: 1200,
          paymentCategoryId: 10,
          memo: 'ランチ',
          smallCategoryName: '外食',
          bigCategoryId: 1,
          bigCategoryName: '食費',
          colorCode: 'FFAA00',
          iconPath: 'assets/images/icon_meal.svg',
          incomeSourceBigCategory: 1,
          fixedCostId: null,
          isConfirmed: 1,
        ),
      ]);
    });

    test('論理削除済みのカテゴリーでも名前が出る', () {
      final tiles = buildBulkDeleteExpenseTiles(
        expenses: const [
          ExpenseEntity(
            id: 2,
            date: '20240101',
            price: 500,
            paymentCategoryId: 20,
          ),
        ],
        smallCategories: const [smallLunch, smallDeleted],
        bigCategories: const [bigFood, bigDeleted],
      );

      expect(tiles.single.smallCategoryName, '旧小');
      expect(tiles.single.bigCategoryName, '旧カテゴリー');
      expect(tiles.single.colorCode, '123456');
    });

    test('参照先のカテゴリーが無い行は名前が空でも落とさない', () {
      final tiles = buildBulkDeleteExpenseTiles(
        expenses: const [
          // 小カテゴリー 999 はマスタに無い
          ExpenseEntity(
            id: 3,
            date: '20250706',
            price: 300,
            paymentCategoryId: 999,
          ),
        ],
        smallCategories: const [smallLunch],
        bigCategories: const [bigFood],
      );

      expect(tiles, hasLength(1));
      expect(tiles.single.id, 3);
      expect(tiles.single.smallCategoryName, '');
      expect(tiles.single.bigCategoryName, '');
      expect(tiles.single.bigCategoryId, 0);
      expect(tiles.single.iconPath, '');
    });

    test('未確定の固定費行は予想額を金額にし固定費の情報を引き継ぐ', () {
      final tiles = buildBulkDeleteExpenseTiles(
        expenses: const [
          ExpenseEntity(
            id: 4,
            date: '20250710',
            price: null,
            paymentCategoryId: 10,
            fixedCostId: 30,
            isConfirmed: 0,
            estimatedPrice: 6000,
          ),
        ],
        smallCategories: const [smallLunch],
        bigCategories: const [bigFood],
      );

      expect(tiles.single.price, 6000);
      expect(tiles.single.fixedCostId, 30);
      expect(tiles.single.isConfirmed, 0);
    });
  });

  group('groupBulkDeleteExpenseTiles', () {
    ExpenseHistoryTileValue tile(int id, DateTime date) =>
        ExpenseHistoryTileValue(
          id: id,
          date: date,
          price: 100,
          paymentCategoryId: 10,
          smallCategoryName: '外食',
          bigCategoryId: 1,
          bigCategoryName: '食費',
          colorCode: 'FFAA00',
          iconPath: 'assets/images/icon_meal.svg',
          incomeSourceBigCategory: 1,
        );

    test('日付降順に並び、同じ日の中は ID 降順になる', () {
      final groups = groupBulkDeleteExpenseTiles([
        tile(1, DateTime(2025, 7, 1)),
        tile(3, DateTime(2025, 7, 6)),
        tile(2, DateTime(2025, 7, 6)),
        // 年またぎの古い行が末尾になる
        tile(9, DateTime(2024, 12, 31)),
      ]);

      expect(groups.map((g) => g.date).toList(), [
        DateTime(2025, 7, 6),
        DateTime(2025, 7, 1),
        DateTime(2024, 12, 31),
      ]);
      expect(groups[0].expenses.map((e) => e.id).toList(), [3, 2]);
      expect(groups[1].expenses.map((e) => e.id).toList(), [1]);
      expect(groups[2].expenses.map((e) => e.id).toList(), [9]);
      // 支出モードでは incomes は空
      expect(groups.every((g) => g.incomes.isEmpty), isTrue);
    });

    test('時刻が違っても同じ日にまとまる', () {
      final groups = groupBulkDeleteExpenseTiles([
        tile(1, DateTime(2025, 7, 6, 9)),
        tile(2, DateTime(2025, 7, 6, 23, 59)),
      ]);

      expect(groups, hasLength(1));
      expect(groups.single.date, DateTime(2025, 7, 6));
      expect(groups.single.expenses.map((e) => e.id).toList(), [2, 1]);
    });

    test('0件なら空のリスト', () {
      expect(groupBulkDeleteExpenseTiles(const []), isEmpty);
    });
  });

  group('収入（buildBulkDeleteIncomeTiles / groupBulkDeleteIncomeTiles）', () {
    // 収入カテゴリー: 月次収入(1) › 給与(1)
    const incomeBig = IncomeBigCategoryEntity(
      id: 1,
      name: '月次収入',
      colorCode: '00AAFF',
      iconPath: 'assets/images/icon_salary.svg',
    );
    const incomeSmall = IncomeSmallCategoryEntity(
      id: 1,
      smallCategoryOrderKey: 1,
      bigCategoryKey: 1,
      displayedOrderInBig: 1,
      smallCategoryName: '給与',
      defaultDisplayed: 1,
    );

    test('カテゴリーを引いてタイル値を組み、日付降順・ID 降順にまとめる', () {
      final tiles = buildBulkDeleteIncomeTiles(
        incomes: const [
          IncomeEntity(id: 1, categoryId: 1, date: '20250625', price: 250000),
          IncomeEntity(id: 2, categoryId: 1, date: '20250725', price: 260000),
          IncomeEntity(
            id: 3,
            categoryId: 1,
            date: '20250725',
            price: 1000,
            memo: '臨時',
          ),
          // 参照先が無い行も落とさない
          IncomeEntity(id: 4, categoryId: 999, date: '20250101', price: 5),
        ],
        smallCategories: const [incomeSmall],
        bigCategories: const [incomeBig],
      );

      expect(
        tiles[0],
        IncomeHistoryTileValue(
          id: 1,
          date: DateTime(2025, 6, 25),
          price: 250000,
          paymentCategoryId: 1,
          memo: '',
          smallCategoryName: '給与',
          bigCategoryId: 1,
          bigCategoryName: '月次収入',
          colorCode: '00AAFF',
          iconPath: 'assets/images/icon_salary.svg',
        ),
      );
      expect(tiles[3].bigCategoryName, '');
      expect(tiles[3].iconPath, '');

      final groups = groupBulkDeleteIncomeTiles(tiles);
      expect(groups.map((g) => g.date).toList(), [
        DateTime(2025, 7, 25),
        DateTime(2025, 6, 25),
        DateTime(2025, 1, 1),
      ]);
      expect(groups[0].incomes.map((i) => i.id).toList(), [3, 2]);
      // 収入モードでは expenses は空
      expect(groups.every((g) => g.expenses.isEmpty), isTrue);
    });
  });

  group('collectBulkDeleteRecordIds', () {
    test('支出・収入どちらのグループからも ID を集める', () {
      final ids = collectBulkDeleteRecordIds([
        DailyTransactionGroup(
          date: DateTime(2025, 7, 6),
          expenses: [
            ExpenseHistoryTileValue(
              id: 11,
              date: DateTime(2025, 7, 6),
              price: 1,
              paymentCategoryId: 10,
              smallCategoryName: '',
              bigCategoryId: 1,
              bigCategoryName: '',
              colorCode: '',
              iconPath: '',
              incomeSourceBigCategory: 1,
            ),
          ],
        ),
        DailyTransactionGroup(
          date: DateTime(2025, 7, 5),
          incomes: [
            IncomeHistoryTileValue(
              id: 22,
              date: DateTime(2025, 7, 5),
              price: 1,
              paymentCategoryId: 1,
              smallCategoryName: '',
              bigCategoryId: 1,
              bigCategoryName: '',
              colorCode: '',
              iconPath: '',
            ),
          ],
        ),
      ]);

      expect(ids, {11, 22});
    });

    test('空なら空集合', () {
      expect(collectBulkDeleteRecordIds(const []), isEmpty);
    });
  });
}
