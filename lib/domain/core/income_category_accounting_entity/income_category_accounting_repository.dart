import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'income_category_accounting_entity.dart';

/// 月次の各収入カテゴリー情報のリポジトリプロバイダー
/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final incomeCategoryAccountingRepositoryProvider = Provider<IncomeCategoryAccountingRepository>(
  (_) => throw UnimplementedError("incomeCategoryAccountingRepositoryの実装がされていません。"),
);

abstract interface class IncomeCategoryAccountingRepository {

  Future<List<IncomeCategoryAccountingEntity>> fetchAll({required DateTime fromDate,required DateTime toDate});

  Future<IncomeCategoryAccountingEntity> fetchSelectedCategory({required DateTime fromDate,required DateTime toDate, required int incomeSmallCategoryId});
}
