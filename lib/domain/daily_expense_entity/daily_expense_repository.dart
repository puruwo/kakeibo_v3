import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_expense_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final dailyExpenseRepositoryProvider = Provider<DailyExpenseRepository>(
  (_) => throw UnimplementedError("DailyExpenseRepositoryの実装がされていません。"),
);

/// 支出に関するリポジトリ
abstract interface class DailyExpenseRepository {

  /// 日付指定して全データを取得する
  Future<DailyExpenseEntity> fetch({required DateTime dateTime});
}
