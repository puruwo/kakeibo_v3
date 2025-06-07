import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'expense_small_category_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final expenseSmallCategoryRepositoryProvider = Provider<ExpenseSmallCategoryRepository>(
  (_) => throw UnimplementedError("SmallCategoryRepositoryの実装がされていません。"),
);

/// tbl201(小カテゴリー)に関するリポジトリ
abstract interface class ExpenseSmallCategoryRepository {

  // 全ての小カテゴリーの情報を取得する
  Future<List<ExpenseSmallCategoryEntity>> fetchAll();

  /// 小カテゴリー指定で小カテゴリーの情報を取得する
  Future<ExpenseSmallCategoryEntity> fetchBySmallCategory({required int smallCategoryId});
  
  /// 大カテゴリー指定で小カテゴリーのリストを取得する
  Future<List<ExpenseSmallCategoryEntity>> fetchByBigCategory({required int bigCategoryId});

  /// 小カテゴリーを編集する
  Future<void> update({required ExpenseSmallCategoryEntity entity});
}
