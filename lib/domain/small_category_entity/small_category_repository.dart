import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'small_category_entity.dart';

/// 投稿リポジトリプロバイダー
/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final smallCategoryRepositoryProvider = Provider<SmallCategoryRepository>(
  // 初期値を PostRepositoryImpl にしてしまうと、
  // ドメイン層がインフラ層に依存してしまうことになるので、
  // どの層にも依存させないために未実装エラーを返却するようにしておく
  (_) => throw UnimplementedError("SmallCategoryRepositoryの実装がされていません。"),
);

/// Post テーブルに関するリポジトリ
abstract interface class SmallCategoryRepository {

  Future<SmallCategoryEntity> fetch({required String postId});

  /// 全投稿情報取得
  Future<List<SmallCategoryEntity>> fetchAll(int bigCategoryId, DateTime fromDate, DateTime toDate);
}
