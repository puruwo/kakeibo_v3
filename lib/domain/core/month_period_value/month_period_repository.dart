import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'month_period_value.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final monthPeriodRepositoryProvider = Provider<MonthPeriodRepository>(
  (_) => throw UnimplementedError("DailyExpenseRepositoryの実装がされていません。"),
);

/// 集計期間に関するリポジトリ
abstract interface class MonthPeriodRepository {

  /// 日付を入力してその日付が含まれる期間を取得する
  Future<MonthPeriodValue> fetch({required DateTime dateTime});
}
