import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'category_entity.dart';

/// 投稿リポジトリプロバイダー
/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final categoryRepositoryProvider = Provider<CategoryRepository>(
  // 初期値を PostRepositoryImpl にしてしまうと、
  // ドメイン層がインフラ層に依存してしまうことになるので、
  // どの層にも依存させないために未実装エラーを返却するようにしておく
  (_) => throw UnimplementedError("CategoryRepositoryの実装がされていません。"),
);

/// Post テーブルに関するリポジトリ
abstract interface class CategoryRepository {

  Future<CategoryEntity> fetch({required String postId});

  /// 全投稿情報取得
  Future<List<CategoryEntity>> fetchAll(DateTime fromDate, DateTime toDate);
}
