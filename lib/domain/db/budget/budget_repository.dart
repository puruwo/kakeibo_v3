import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/db/budget/budget_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final budgetRepositoryProvider = Provider<BudgetRepository>(
  (_) => throw UnimplementedError("BudgetRepositoryの実装がされていません。"),
);

/// 支出情報に関するリポジトリ
abstract interface class BudgetRepository {

  /// 期間とカテゴリーを指定して各カテゴリーの月間予算を取得する
  Future<BudgetEntity> fetchMonthlyByBigCategory({required MonthValue month,required int expenseBigCategoryId});

  /// 期間指定してを月間予算の全カテゴリー合計を取得する
  Future<int> fetchMonthlyAll({required MonthValue month});

  /// 期間指定してをあるカテゴリーの月間予算を取得する
  Future<int> fetchMonthly({required int id ,required MonthValue month});

  /// 書き込みの完了を待てるようにFutureを返す。失敗は例外として呼び出し側へ返す
  Future<void> insert(BudgetEntity expenseEntity);

  /// 書き込みの完了を待てるようにFutureを返す。失敗は例外として呼び出し側へ返す
  Future<void> update(BudgetEntity expenseEntity);
  
  void delete(int id);

  // そのレコードがあるかどうか確認する
  Future<bool> hasData(BudgetEntity expenseEntity);
}
