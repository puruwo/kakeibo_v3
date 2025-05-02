import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'all_category_accounting_entity.dart';

/// 月次の全カテゴリーの支出のリポジトリプロバイダー
/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final allCategoryAccountingRepositoryProvider = Provider<AllCategoryAccountingRepository>(
  (_) => throw UnimplementedError("allCategoryProviderの実装がされていません。"),
);

abstract interface class AllCategoryAccountingRepository {

  Future<AllCategoryAccountingEntity> fetch({required  DateTime fromDate,required DateTime toDate});

}
