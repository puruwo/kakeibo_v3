// ImplementsCategoryAccountingRepository のDB結合テスト
//
// カテゴリーカードのデータ源となる重いJOIN。以下を仕様として固定する。
// - 支出は expense のみを集計対象にする（固定費は合算しない）
// - 実績が無い大カテゴリーは COALESCE で0埋めして必ず1行返す
// - is_displayed = 0 のカテゴリーは「実績が1件も無いとき」だけ隠れる
// - 並びは _id ではなく display_order
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/repository/category_repository.dart';

import '../../helper/db_test_helper.dart';

/// 基準シナリオの集計期間（開始日25日設定で 2025/7/6 を選んだときの期間）
final _fromDate = DateTime(2025, 6, 25);
final _toDate = DateTime(2025, 7, 24);

/// onCreate がシードする支出大カテゴリー名（display_order 昇順）
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

  final repository = ImplementsCategoryAccountingRepository();

  group('fetchAll', () {
    test('大カテゴリーごとに期間内の支出を合計する', () async {
      // 小カテゴリー1,2,3（食費）と 5（日用品）に支出を入れる
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
        smallCategoryId: 2,
      );
      await insertExpenseRow(
        id: 3,
        date: '20250703',
        price: 300,
        smallCategoryId: 5,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      // 食費 = 100 + 200、日用品 = 300
      expect(
        results.firstWhere((e) => e.id == 1).totalExpenseByBigCategory,
        300,
      );
      expect(
        results.firstWhere((e) => e.id == 2).totalExpenseByBigCategory,
        300,
      );
    });

    test('実績が無い大カテゴリーもCOALESCEで0埋めして返す', () async {
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 100,
        smallCategoryId: 1,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      // シードの12カテゴリーが全て返る
      expect(results.length, 12);
      expect(results.map((e) => e.bigCategoryName).toList(), _seedNames);
      // 実績の無いカテゴリーは0
      expect(results.firstWhere((e) => e.id == 6).totalExpenseByBigCategory, 0);
    });

    test('支出が1件も無くてもシードの12カテゴリーを0円で返す', () async {
      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results.length, 12);
      expect(results.every((e) => e.totalExpenseByBigCategory == 0), isTrue);
    });

    test('display_order昇順で並ぶ（色・名前・アイコンパスも一緒に返る）', () async {
      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results.map((e) => e.id).toList(), [
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
        12,
      ]);
      expect(results.first.bigCategoryName, '食費');
      expect(results.first.categoryColor, 'FF7171');
      expect(results.first.categoryIconPath, 'assets/images/icon_meal.svg');
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
        fromDate: _fromDate,
        toDate: _toDate,
      );
      final bonus = await repository.fetchAll(
        incomeSourceBigCategoryId: 2,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(
        salary.firstWhere((e) => e.id == 1).totalExpenseByBigCategory,
        100,
      );
      expect(bonus.firstWhere((e) => e.id == 1).totalExpenseByBigCategory, 999);
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
        fromDate: _fromDate,
        toDate: _toDate,
      );

      // 100 + 400（期間外の1と2は除外）
      expect(
        results.firstWhere((e) => e.id == 1).totalExpenseByBigCategory,
        500,
      );
    });

    test('固定費支出は合計に含めない（expenseテーブルのみを集計する）', () async {
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 100,
        smallCategoryId: 1,
      );
      await insertFixedCostRow(id: 10, name: '家賃', fixedCostCategoryId: 1);
      await insertFixedCostExpenseRow(
        id: 1,
        fixedCostId: 10,
        fixedCostCategoryId: 1,
        date: '20250701',
        price: 80000,
        name: '家賃',
        isConfirmed: 1,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      // 固定費の80000は乗らない
      expect(
        results.firstWhere((e) => e.id == 1).totalExpenseByBigCategory,
        100,
      );
      expect(
        results.fold<int>(0, (sum, e) => sum + e.totalExpenseByBigCategory),
        100,
      );
    });

    test('非表示(is_displayed = 0)かつ実績が無い大カテゴリーは返さない', () async {
      // id=6（医療費）を非表示にする
      await updateExpenseBigCategoryIsDisplayed(id: 6, isDisplayed: 0);

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results.length, 11);
      expect(results.map((e) => e.id), isNot(contains(6)));
    });

    test('非表示でも期間内に実績があれば返す', () async {
      await updateExpenseBigCategoryIsDisplayed(id: 6, isDisplayed: 0);
      // 小カテゴリー14（医療費）は大カテゴリー6に属する
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 500,
        smallCategoryId: 14,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results.length, 12);
      expect(
        results.firstWhere((e) => e.id == 6).totalExpenseByBigCategory,
        500,
      );
    });

    test('マスタに無い小カテゴリーの支出はINNER JOINで落ちて合計されない', () async {
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 100,
        smallCategoryId: 1,
      );
      await insertExpenseRow(
        id: 2,
        date: '20250701',
        price: 999,
        smallCategoryId: 999,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(
        results.fold<int>(0, (sum, e) => sum + e.totalExpenseByBigCategory),
        100,
      );
    });

    test('同じカテゴリーに予算行が複数あってもカテゴリーの行は重複しない', () async {
      // 予算は上書きではなく行追加で積まれるため、JOIN先が複数行になり得る
      await insertBudgetRow(
        id: 1,
        expenseBigCategoryId: 1,
        month: '202505',
        price: 30000,
      );
      await insertBudgetRow(
        id: 2,
        expenseBigCategoryId: 1,
        month: '202506',
        price: 35000,
      );
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 100,
        smallCategoryId: 1,
      );

      final results = await repository.fetchAll(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      expect(results.length, 12);
      expect(results.where((e) => e.id == 1).length, 1);
      expect(
        results.firstWhere((e) => e.id == 1).totalExpenseByBigCategory,
        100,
      );
    });
  });

  group('fetchSelectedCategory', () {
    test('指定した大カテゴリー1件だけを返す', () async {
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

      final result = await repository.fetchSelectedCategory(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
        expenseBigCategoryId: 2,
      );

      expect(result.id, 2);
      expect(result.bigCategoryName, '日用品');
      expect(result.totalExpenseByBigCategory, 300);
    });

    test('実績が無いカテゴリーはCOALESCEで0を返す', () async {
      final result = await repository.fetchSelectedCategory(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
        expenseBigCategoryId: 3,
      );

      expect(result.id, 3);
      expect(result.totalExpenseByBigCategory, 0);
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

      final result = await repository.fetchSelectedCategory(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
        expenseBigCategoryId: 1,
      );

      expect(result.totalExpenseByBigCategory, 500);
    });

    test('指定した拠出元以外の支出は合計しない', () async {
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

      final result = await repository.fetchSelectedCategory(
        incomeSourceBigCategoryId: 1,
        fromDate: _fromDate,
        toDate: _toDate,
        expenseBigCategoryId: 1,
      );

      expect(result.totalExpenseByBigCategory, 100);
    });

    test('存在しない大カテゴリーIDなら例外を投げる', () async {
      await expectLater(
        () => repository.fetchSelectedCategory(
          incomeSourceBigCategoryId: 1,
          fromDate: _fromDate,
          toDate: _toDate,
          expenseBigCategoryId: 999,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('非表示かつ実績が無いカテゴリーを指定すると例外を投げる', () async {
      await updateExpenseBigCategoryIsDisplayed(id: 6, isDisplayed: 0);

      await expectLater(
        () => repository.fetchSelectedCategory(
          incomeSourceBigCategoryId: 1,
          fromDate: _fromDate,
          toDate: _toDate,
          expenseBigCategoryId: 6,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
