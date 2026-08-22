// ImplementsDailyExpenseRepository のDB結合テスト
//
// カレンダーの日別サマリー。expense / income を UNION ALL して
// 期間内を GROUP BY date で日毎に畳む（B-03のレンジクエリ化で1日1クエリ→期間1クエリ）。
// 固定費実績もexpenseに入るため（v10）、金額は実効金額の共通式
// COALESCE(price, estimated_price) で確定・未確定を1本の集計に畳む。
// SQLにORDER BYは無いため、複数日の検証は日付ソートしてから比較する。
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_entity.dart';
import 'package:kakeibo/repository/daily_expense_repository.dart';

import '../../helper/db_test_helper.dart';

void main() {
  setUpDbTestEnvironment();

  final repository = ImplementsDailyExpenseRepository();

  /// 順序非保証のため日付昇順に揃えて返す
  List<DailyExpenseEntity> sorted(List<DailyExpenseEntity> list) =>
      List.of(list)..sort((a, b) => a.date.compareTo(b.date));

  group('fetchDailyTotalsByPeriod', () {
    test('その日の支出・固定費・収入をまとめて集計する', () async {
      await insertFixedCostRow(
        id: 10,
        name: '家賃',
        fixedCostCategoryId: 1,
        price: 80000,
        estimatedPrice: 80000,
      );
      await insertExpenseRow(id: 1, date: '20250701', price: 100);
      await insertExpenseRow(id: 2, date: '20250701', price: 200);
      // 固定費の実績行もexpenseに入る（v10）
      await insertExpenseRow(
        id: 3,
        date: '20250701',
        price: 80000,
        memo: '家賃',
        fixedCostId: 10,
        isConfirmed: 1,
      );
      await insertIncomeRow(id: 1, date: '20250701', price: 300000);

      final result = await repository.fetchDailyTotalsByPeriod(
        fromDate: DateTime(2025, 7, 1),
        toDate: DateTime(2025, 7, 1),
      );

      expect(result, hasLength(1));
      expect(result.single.date, DateTime(2025, 7, 1));
      expect(result.single.totalExpense, 80300);
      expect(result.single.totalIncome, 300000);
    });

    test('期間内の複数日は日ごとの行に分かれて返る（データの無い日は含まれない）', () async {
      await insertExpenseRow(id: 1, date: '20250701', price: 100);
      await insertExpenseRow(id: 2, date: '20250703', price: 300);
      await insertIncomeRow(id: 1, date: '20250703', price: 1000);

      final result = sorted(
        await repository.fetchDailyTotalsByPeriod(
          fromDate: DateTime(2025, 7, 1),
          toDate: DateTime(2025, 7, 31),
        ),
      );

      // 7/2 はデータが無いので行ごと存在しない
      expect(result, hasLength(2));
      expect(result[0].date, DateTime(2025, 7, 1));
      expect(result[0].totalExpense, 100);
      expect(result[0].totalIncome, 0);
      expect(result[1].date, DateTime(2025, 7, 3));
      expect(result[1].totalExpense, 300);
      expect(result[1].totalIncome, 1000);
    });

    test('開始日・終了日ちょうどのデータは含み、期間外の前日・翌日は含まない', () async {
      await insertExpenseRow(id: 1, date: '20250630', price: 100); // 前日
      await insertExpenseRow(id: 2, date: '20250701', price: 200); // 開始日
      await insertExpenseRow(id: 3, date: '20250715', price: 400); // 期間中
      await insertExpenseRow(id: 4, date: '20250731', price: 800); // 終了日
      await insertExpenseRow(id: 5, date: '20250801', price: 1600); // 翌日

      final result = sorted(
        await repository.fetchDailyTotalsByPeriod(
          fromDate: DateTime(2025, 7, 1),
          toDate: DateTime(2025, 7, 31),
        ),
      );

      expect(result.map((e) => e.date), [
        DateTime(2025, 7, 1),
        DateTime(2025, 7, 15),
        DateTime(2025, 7, 31),
      ]);
    });

    test('月・年を跨ぐ期間でも日付順の大小比較が正しく効く', () async {
      // yyyyMMdd固定長の辞書順＝日付順であることの回帰（12月→翌年1月）
      await insertExpenseRow(id: 1, date: '20251230', price: 100);
      await insertExpenseRow(id: 2, date: '20260102', price: 200);
      await insertExpenseRow(id: 3, date: '20251129', price: 400); // 期間外（前）
      await insertExpenseRow(id: 4, date: '20260203', price: 800); // 期間外（後）

      final result = sorted(
        await repository.fetchDailyTotalsByPeriod(
          fromDate: DateTime(2025, 12, 1),
          toDate: DateTime(2026, 1, 31),
        ),
      );

      expect(result.map((e) => e.date), [
        DateTime(2025, 12, 30),
        DateTime(2026, 1, 2),
      ]);
    });

    test('未確定の固定費は実額priceではなく行のestimated_priceで集計する', () async {
      await insertFixedCostRow(
        id: 30,
        name: '電気代',
        fixedCostCategoryId: 4,
        variable: 1,
        estimatedPrice: 7800,
      );
      // 未確定行は実額priceを持たない（NULL）。予想額は行のestimated_priceにある
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: null,
        memo: '電気代',
        fixedCostId: 30,
        isConfirmed: 0,
        estimatedPrice: 7800,
      );

      final result = await repository.fetchDailyTotalsByPeriod(
        fromDate: DateTime(2025, 7, 1),
        toDate: DateTime(2025, 7, 1),
      );

      expect(result.single.totalExpense, 7800);
    });

    test('確定済みの固定費は実額priceで集計する（予想額は無視される）', () async {
      await insertFixedCostRow(
        id: 30,
        name: '電気代',
        fixedCostCategoryId: 4,
        variable: 1,
        estimatedPrice: 7800,
      );
      // 確定後も予想額は残る（予実乖離の記録。仕様 §3）が、集計は実額を使う
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 9200,
        memo: '電気代',
        fixedCostId: 30,
        isConfirmed: 1,
        estimatedPrice: 7800,
      );

      final result = await repository.fetchDailyTotalsByPeriod(
        fromDate: DateTime(2025, 7, 1),
        toDate: DateTime(2025, 7, 1),
      );

      expect(result.single.totalExpense, 9200);
    });

    test('ボーナス拠出の支出も合算される（履歴タブ=家計全体スコープ）', () async {
      // Q-11の決着（2026-08-12）: 拠出元で絞らないのは仕様。
      // 分析・予測（給与のみ=一般会計）との画面間の差は意図された区分
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: 100,
        incomeSourceBigCategory: 1,
      );
      await insertExpenseRow(
        id: 2,
        date: '20250701',
        price: 300,
        incomeSourceBigCategory: 2,
      );

      final result = await repository.fetchDailyTotalsByPeriod(
        fromDate: DateTime(2025, 7, 1),
        toDate: DateTime(2025, 7, 1),
      );

      // SQLに income_source_big_category の条件が無く、全拠出元の合計が返る
      expect(result.single.totalExpense, 400);
    });

    test('実額も予想額も持たない未確定行はNULL扱いで合計されない', () async {
      // COALESCE が両方NULLならNULLを返すため、SUM対象から外れる
      await insertExpenseRow(
        id: 1,
        date: '20250701',
        price: null,
        memo: '孤立レコード',
        fixedCostId: 999,
        isConfirmed: 0,
        estimatedPrice: null,
      );

      final result = await repository.fetchDailyTotalsByPeriod(
        fromDate: DateTime(2025, 7, 1),
        toDate: DateTime(2025, 7, 1),
      );

      // SUM(NULL)の行として日付は返るが合計は0になる
      expect(result.single.totalExpense, 0);
    });

    test('期間内にデータが1件も無いなら空リストを返す', () async {
      final result = await repository.fetchDailyTotalsByPeriod(
        fromDate: DateTime(2025, 7, 1),
        toDate: DateTime(2025, 7, 31),
      );

      expect(result, isEmpty);
    });
  });
}
