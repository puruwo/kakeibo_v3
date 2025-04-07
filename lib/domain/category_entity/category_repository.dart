import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'category_entity.dart';

/// 月次の各カテゴリー情報のリポジトリプロバイダー
/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (_) => throw UnimplementedError("categoryRepositoryの実装がされていません。"),
);

abstract interface class CategoryRepository {

  Future<List<CategoryEntity>> fetchAll({required DateTime fromDate,required DateTime toDate});
}
