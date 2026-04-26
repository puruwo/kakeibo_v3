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

  /// 小カテゴリーを追加する（戻り値は採番された_id）
  Future<int> add({required IncomeSmallCategoryEntity entity});

  /// 小カテゴリーを編集する
  Future<void> update({required IncomeSmallCategoryEntity entity});

  /// 小カテゴリーを削除する
  Future<void> delete({required int id});

  /// 大カテゴリー指定で紐づく小カテゴリーを全件削除する（戻り値は削除した小カテゴリーIDのリスト）
  Future<List<int>> deleteByBigCategory({required int bigCategoryId});

  /// 小カテゴリーの最大の表示順序を取得する
  Future<int> getMaxSmallCategoryOrderKey({required int bigCategoryId});

  /// 大カテゴリーを指定して、それにふくまれる小カテゴリーのidを取得する
  Future<List<int>> fetchSmallCategoryIdListByBigCategoryId({required int bigCategoryId});
}
