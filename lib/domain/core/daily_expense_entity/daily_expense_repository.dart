import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_expense_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final dailyExpenseRepositoryProvider = Provider<DailyExpenseRepository>(
  (_) => throw UnimplementedError("DailyExpenseRepositoryの実装がされていません。"),
);

/// 1日の支出データに関するリポジトリ
abstract interface class DailyExpenseRepository {

  /// 日付指定して全データを取得する
  /// カテゴリー指定あり
  Future<DailyExpenseEntity> fetchWithCategory({required int incomeSourceBigId, required DateTime dateTime});
}
