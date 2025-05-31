import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'category_accounting_entity.dart';

/// 月次の各カテゴリー情報のリポジトリプロバイダー
/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final categoryAccountingRepositoryProvider = Provider<CategoryAccountingRepository>(
  (_) => throw UnimplementedError("categoryRepositoryの実装がされていません。"),
);

abstract interface class CategoryAccountingRepository {

  Future<List<CategoryAccountingEntity>> fetchAll({required int incomeSourceBigCategoryId, required DateTime fromDate,required DateTime toDate});
}
