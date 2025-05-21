import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final budgetRepositoryProvider = Provider<BudgetRepository>(
  (_) => throw UnimplementedError("BudgetRepositoryの実装がされていません。"),
);

/// 支出情報に関するリポジトリ
abstract interface class BudgetRepository {

  /// 期間指定して各カテゴリーの月間予算を取得する
  /// カテゴリーの指定はしない
  Future<BudgetEntity> fetchMonthlyByBigCategory({required MonthValue month,required int expenseBigCategoryId});

  /// 期間指定してを月間予算の全カテゴリー合計を取得する
  Future<int> fetchMonthlyAll({required MonthValue month});

  /// 期間指定してをあるカテゴリーの月間予算を取得する
  Future<int> fetchMonthly({required int id ,required MonthValue month});

  void insert(BudgetEntity expenseEntity);

  void update(BudgetEntity expenseEntity);
  
  void delete(int id);

  // そのレコードがあるかどうか確認する
  Future<bool> hasData(BudgetEntity expenseEntity);
}
