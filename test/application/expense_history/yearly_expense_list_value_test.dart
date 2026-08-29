// 支出一覧の表示値（YearlyExpenseListValue）と会計種別フィルターの単体テスト
//
// 絞り込み（全体/生活収支/特別枠）で総支出・カテゴリー内訳・構成比の分母が
// 選択中の枠に揃うことを固定する（ユーザー指定 2026-08-29）。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/expense_history/yearly_expense_list_usecase.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';

void main() {
  // 大カテゴリー名→ID（1:食費 / 2:交通費 / 3:旅行）
  const bigCategoryIds = {'食費': 1, '交通費': 2, '旅行': 3};

  ExpenseHistoryTileValue row({
    required int id,
    required String bigCategoryName,
    required int price,
    int incomeSourceBigCategory = AccountTypeConstants.living,
    int? bigCategoryId,
  }) => ExpenseHistoryTileValue(
    id: id,
    date: DateTime(2025, 7, id),
    price: price,
    paymentCategoryId: 1,
    memo: '',
    smallCategoryName: '小$bigCategoryName',
    bigCategoryId: bigCategoryId ?? bigCategoryIds[bigCategoryName]!,
    bigCategoryName: bigCategoryName,
    colorCode: 'FF7171',
    iconPath: 'assets/images/icon_meal.svg',
    incomeSourceBigCategory: incomeSourceBigCategory,
  );

  // 食費: 生活60,000＋特別20,000 / 交通費: 生活40,000 / 旅行: 特別30,000
  final rows = [
    row(id: 1, bigCategoryName: '食費', price: 60000),
    row(
      id: 2,
      bigCategoryName: '食費',
      price: 20000,
      incomeSourceBigCategory: AccountTypeConstants.special,
    ),
    row(id: 3, bigCategoryName: '交通費', price: 40000),
    row(
      id: 4,
      bigCategoryName: '旅行',
      price: 30000,
      incomeSourceBigCategory: AccountTypeConstants.special,
    ),
  ];

  group('ExpenseAccountFilter.includes', () {
    test('全体はどちらの枠も含む', () {
      expect(rows.where(ExpenseAccountFilter.all.includes), hasLength(4));
    });

    test('生活収支・特別枠はそれぞれの会計種別だけを含む', () {
      expect(
        rows.where(ExpenseAccountFilter.living.includes).map((r) => r.id),
        [1, 3],
      );
      expect(
        rows.where(ExpenseAccountFilter.special.includes).map((r) => r.id),
        [2, 4],
      );
    });
  });

  group('YearlyExpenseListValue.filteredBy', () {
    final value = YearlyExpenseListValue.fromRows(rows);

    test('全体: 総支出150,000・金額降順で 食費80,000 → 交通費40,000 → 旅行30,000', () {
      expect(value.totalExpense, 150000);
      expect(value.categories.map((c) => c.bigCategoryName), [
        '食費',
        '交通費',
        '旅行',
      ]);
      expect(value.categories.map((c) => c.sum), [80000, 40000, 30000]);
    });

    test('全体で絞ると同じインスタンスが返る', () {
      expect(identical(value.filteredBy(ExpenseAccountFilter.all), value), true);
    });

    test('生活収支: 特別枠の明細が除かれ、総支出と構成比の分母が生活の合計になる', () {
      final living = value.filteredBy(ExpenseAccountFilter.living);

      expect(living.totalExpense, 100000);
      expect(living.categories.map((c) => c.bigCategoryName), ['食費', '交通費']);
      expect(living.categories.map((c) => c.sum), [60000, 40000]);
      // 食費の明細から特別枠の1件が消えている
      expect(living.categories.first.rows.map((r) => r.id), [1]);
      expect(living.categories.first.ratioOf(living.totalExpense), 0.6);
    });

    test('特別枠: 生活収支だけのカテゴリー（交通費）は一覧から消える', () {
      final special = value.filteredBy(ExpenseAccountFilter.special);

      expect(special.totalExpense, 50000);
      expect(special.categories.map((c) => c.bigCategoryName), ['旅行', '食費']);
      expect(special.categories.map((c) => c.sum), [30000, 20000]);
    });

    test('同名でもIDが違う大カテゴリーは別行に集計される（名前で合算しない）', () {
      final sameName = YearlyExpenseListValue.fromRows([
        row(id: 1, bigCategoryName: 'その他', price: 5000, bigCategoryId: 10),
        row(id: 2, bigCategoryName: 'その他', price: 3000, bigCategoryId: 11),
      ]);

      expect(sameName.categories.map((c) => c.bigCategoryId), [10, 11]);
      expect(sameName.categories.map((c) => c.sum), [5000, 3000]);
    });

    test('該当が無い枠で絞ると空になる', () {
      final livingOnly = YearlyExpenseListValue.fromRows([
        row(id: 1, bigCategoryName: '食費', price: 1000),
      ]);
      final special = livingOnly.filteredBy(ExpenseAccountFilter.special);

      expect(special.totalExpense, 0);
      expect(special.categories, isEmpty);
      expect(special.allRows, isEmpty);
    });
  });
}
