import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'small_category_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final smallCategoryRepositoryProvider = Provider<SmallCategoryRepository>(
  (_) => throw UnimplementedError("SmallCategoryRepositoryの実装がされていません。"),
);

/// tbl201(小カテゴリー)に関するリポジトリ
abstract interface class SmallCategoryRepository {

  // 全ての小カテゴリーの情報を取得する
  Future<List<SmallCategoryEntity>> fetchAll();

  /// 小カテゴリー指定で小カテゴリーの情報を取得する
  Future<SmallCategoryEntity> fetchBySmallCategory({required int smallCategoryId});
  
  /// 大カテゴリー指定で小カテゴリーのリストを取得する
  Future<List<SmallCategoryEntity>> fetchByBigCategory({required int bigCategoryId});
}
