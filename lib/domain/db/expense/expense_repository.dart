import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

import 'expense_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (_) => throw UnimplementedError("ExpenseRepositoryの実装がされていません。"),
);

/// 支出情報に関するリポジトリ
abstract interface class ExpenseRepository {
  /// 全ての支出情報を取得する
  Future<List<ExpenseEntity>> fetchAll();

  /// 期間指定してデータを取得する
  /// 拠出元の指定あり
  Future<List<ExpenseEntity>> fetchWithSourceCategory(
      {required int incomeSourceBigId, required PeriodValue period});

  /// 期間を指定して支出の合計を取得する
  Future<int> fetchTotalExpenseByPeriod(
      {required DateTime fromDate, required DateTime toDate});

  /// 期間指定してデータを取得する
  /// 小カテゴリーと拠出元の指定あり
  Future<List<ExpenseEntity>> fetchWithSmallCategory(
      {required int incomeSourceBigId,
      required PeriodValue period,
      required int smallCategoryId});

  /// 期間と拠出元カテゴリーを指定して支出の合計を取得する
  Future<int> fetchTotalExpenseByPeriodWithBigCategory(
      {required int incomeSourceBigCategory,
      required DateTime fromDate,
      required DateTime toDate});

  /// 期間と小カテゴリーと拠出元カテゴリーを指定して支出の合計を取得する
  Future<int> fetchTotalExpenseByPeriodWithSmallCategoryAndSource(
      {required int incomeSourceBigCategory,
      required int smallCategoryId,
      required DateTime fromDate,
      required DateTime toDate});

  // 期間を指定して日毎の支出データを取得する
  Future<int> fetchDailyExpenseByPeriod({required DateTime date});

  /// 日付を指定して支出リストを取得する（生活支出のみ）
  Future<List<ExpenseEntity>> fetchDailyExpenseListByDate(
      {required DateTime date});

  void insert(ExpenseEntity expenseEntity);

  Future<void> update(ExpenseEntity expenseEntity);

  void delete(int id);

  // ---------------------------------------------------------------------
  // 固定費系のクエリ（v10で fixed_cost_expense から移管）
  // 固定費行の判定は fixed_cost_id IS NOT NULL の1条件に集約する（仕様 §3）
  // ---------------------------------------------------------------------

  /// idを指定して支出を1件取得する（該当なしはnull）
  Future<ExpenseEntity?> fetchById({required int id});

  /// 固定費実績の行を1件挿入し、採番されたidを返す
  ///
  /// 通常の [insert] と違い完了を待てるFutureを返す。
  /// バッチが挿入の失敗を検知できないと、生成されていない月を
  /// 「処理済み」と記録してしまうため。
  Future<int> insertFixedCostExpense(ExpenseEntity expenseEntity);

  /// 固定費IDと支払い日が一致する行が既にあるか（多重生成の防止）
  ///
  /// [date] は `yyyyMMdd` 形式。
  Future<bool> existsByFixedCostIdAndDate({
    required int fixedCostId,
    required String date,
  });

  /// 期間内の固定費行（確定・未確定を問わない）を取得する
  ///
  /// 月次固定費ビュー・見込み算出・予測グラフの共通のデータ源。
  Future<List<ExpenseEntity>> fetchFixedCostExpenseByPeriod({
    required PeriodValue period,
  });

  /// 期間内の未確定の固定費行を取得する
  Future<List<ExpenseEntity>> fetchUnconfirmedFixedCostExpenseByPeriod({
    required PeriodValue period,
  });

  /// 未確定の固定費行を確定させる（実額priceを設定し is_confirmed=1 にする）
  ///
  /// 予想額 estimated_price は残す（予実の乖離を行単位で保持する。仕様 §3）。
  Future<void> confirmFixedCostExpense({required int id, required int price});

  /// 固定費マスタ別に、確定済み固定費行の実額priceの平均を返す
  ///
  /// 対象が0件のときはnull（推定額を更新しないための判定に使う。仕様 §6.5）。
  Future<double?> fetchConfirmedFixedCostPriceAverage({
    required int fixedCostId,
  });

  /// 指定マスタの未確定行の予想額 estimated_price を一括更新する
  ///
  /// 実額列priceには書き込まない（実績の誤上書きを構造上排除する。仕様 §6.5）。
  Future<void> updateEstimatedPriceOfUnconfirmedRows({
    required int fixedCostId,
    required int estimatedPrice,
  });

  /// 指定マスタの未払い固定費行を一括削除する
  ///
  /// 未払い = 未確定（`is_confirmed = 0`）または支払日が [today] より後のもの。
  /// 支払日が到来済みの確定行は履歴として残す（→ ADR-007）。
  Future<void> deleteUnpaidFixedCostExpenses({
    required int fixedCostId,
    required String today,
  });

  /// 指定マスタの固定費行の支出小カテゴリーを一括変更する
  Future<void> updateSmallCategoryByFixedCostId({
    required int fixedCostId,
    required int expenseSmallCategoryId,
  });

  /// 指定マスタの固定費行を支払日の新しい順に取得する
  ///
  /// 固定費の設定画面の「支払い履歴」で使う（仕様 §6.7）。
  /// [limit] で取得件数を絞る。
  Future<List<ExpenseEntity>> fetchByFixedCostId({
    required int fixedCostId,
    required int limit,
  });
}
