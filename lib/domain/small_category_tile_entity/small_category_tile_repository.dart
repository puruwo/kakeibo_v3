import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'small_category_tile_entity.dart';

/// 月次の各小カテゴリー情報のリポジトリプロバイダー
/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final smallCategoryTileRepositoryProvider = Provider<SmallCategoryTileRepository>(
  (_) => throw UnimplementedError("SmallCategoryRepositoryの実装がされていません。"),
);

abstract interface class SmallCategoryTileRepository {

  Future<List<SmallCategoryTileEntity>> fetchAll({required int bigCategoryId,required DateTime fromDate,required DateTime toDate});
}
