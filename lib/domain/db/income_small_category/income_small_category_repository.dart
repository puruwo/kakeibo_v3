import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'income_small_category_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final incomeSmallCategoryRepositoryProvider = Provider<IncomeSmallCategoryRepository>(
  (_) => throw UnimplementedError("SmallCategoryRepositoryの実装がされていません。"),
);

/// income_big_category:収入小カテゴリーに関するリポジトリ
abstract interface class IncomeSmallCategoryRepository {

  // 全ての小カテゴリーの情報を取得する
  Future<List<IncomeSmallCategoryEntity>> fetchAll();

  /// 小カテゴリー指定で小カテゴリーの情報を取得する
  Future<IncomeSmallCategoryEntity> fetchBySmallCategory({required int smallCategoryId});
  
  /// 大カテゴリー指定で小カテゴリーのリストを取得する
  Future<List<IncomeSmallCategoryEntity>> fetchByBigCategory({required int bigCategoryId});
}
