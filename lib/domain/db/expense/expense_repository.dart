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
  /// カテゴリーの指定はしない
  Future<List<ExpenseEntity>> fetchWithoutCategory({required MonthPeriodValue period});

  void insert(ExpenseEntity expenseEntity);

  void update(ExpenseEntity expenseEntity);
  
  void delete(int id);
}
