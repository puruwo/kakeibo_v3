import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'small_category_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final smallCategoryRepositoryProvider = Provider<SmallCategoryRepository>(
  (_) => throw UnimplementedError("SmallCategoryRepositoryの実装がされていません。"),
);

/// tbl201(小カテゴリー)に関するリポジトリ
abstract interface class SmallCategoryRepository {

  /// カテゴリーidを指定してレコードを取得する
  Future<SmallCategoryEntity> fetch({required int id});
}
