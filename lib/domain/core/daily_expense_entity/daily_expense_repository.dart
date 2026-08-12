import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_expense_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final dailyExpenseRepositoryProvider = Provider<DailyExpenseRepository>(
  (_) => throw UnimplementedError("DailyExpenseRepositoryの実装がされていません。"),
);

/// 1日の支出データに関するリポジトリ
abstract interface class DailyExpenseRepository {

  /// 日付を指定してその日の支出・収入合計を取得する
  /// 支出は家計全体（全拠出元＋固定費）を合算する
  Future<DailyExpenseEntity> fetchWithCategory({required DateTime dateTime});
}
