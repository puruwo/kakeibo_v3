import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'all_category_entity.dart';

/// 投稿リポジトリプロバイダー
/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final allCategoryRepositoryProvider = Provider<AllCategoryRepository>(
  // 初期値を PostRepositoryImpl にしてしまうと、
  // ドメイン層がインフラ層に依存してしまうことになるので、
  // どの層にも依存させないために未実装エラーを返却するようにしておく
  (_) => throw UnimplementedError("allCategoryProviderの実装がされていません。"),
);

/// Post テーブルに関するリポジトリ
abstract interface class AllCategoryRepository {

  Future<AllCategoryEntity> fetch({required  DateTime fromDate,required DateTime toDate});

}
