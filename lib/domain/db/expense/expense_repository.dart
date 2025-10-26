import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

import 'expense_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (_) => throw UnimplementedError("ExpenseRepositoryの実装がされていません。"),
);

/// 支出情報に関するリポジトリ
abstract interface class ExpenseRepository {
  // / 全ての支出情報を取得する
  Future<List<ExpenseEntity>> fetchAll();

  /// 期間指定してデータを取得する
  /// 拠出元の指定あり
  Future<List<ExpenseEntity>> fetchWithSourceCategory(
      {required int incomeSourceBigId, required PeriodValue period});

  /// 期間指定してデータを取得する
  /// カテゴリーと拠出元の指定あり
  Future<List<ExpenseEntity>> fetchWithCategory(
      {required int incomeSourceBigId,
      required PeriodValue period,
      required int smallCategoryId});

  // 期間を指定して支出の合計を取得する
  Future<int> fetchTotalExpenseByPeriod(
      {required DateTime fromDate, required DateTime toDate});

  // 期間とカテゴリーを指定して支出の合計を取得する
  Future<int> fetchTotalExpenseByPeriodWithBigCategory(
      {required int incomeSourceBigCategory,
      required DateTime fromDate,
      required DateTime toDate});

  // 期間を指定して日毎の支出データを取得する
  Future<int> fetchDailyExpenseByPeriod(
      {required DateTime date});

  void insert(ExpenseEntity expenseEntity);

  void update(ExpenseEntity expenseEntity);

  void delete(int id);
}
