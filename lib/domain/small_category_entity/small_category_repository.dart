import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'small_category_entity.dart';

/// 月次の各小カテゴリー情報のリポジトリプロバイダー
/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final smallCategoryRepositoryProvider = Provider<SmallCategoryRepository>(
  (_) => throw UnimplementedError("SmallCategoryRepositoryの実装がされていません。"),
);

abstract interface class SmallCategoryRepository {

  Future<List<SmallCategoryEntity>> fetchAll({required int bigCategoryId,required DateTime fromDate,required DateTime toDate});
}
