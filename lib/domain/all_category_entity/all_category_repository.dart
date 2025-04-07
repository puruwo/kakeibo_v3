import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'all_category_entity.dart';

/// 月次の全カテゴリーの支出のリポジトリプロバイダー
/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final allCategoryRepositoryProvider = Provider<AllCategoryRepository>(
  (_) => throw UnimplementedError("allCategoryProviderの実装がされていません。"),
);

/// Post テーブルに関するリポジトリ
abstract interface class AllCategoryRepository {

  Future<AllCategoryEntity> fetch({required  DateTime fromDate,required DateTime toDate});

}
