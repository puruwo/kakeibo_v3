import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

import 'income_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final incomeRepositoryProvider = Provider<IncomeRepository>(
  (_) => throw UnimplementedError("IncomeRepositoryの実装がされていません。"),
);

/// 支出情報に関するリポジトリ
abstract interface class IncomeRepository {
  // / 全ての支出情報を取得する
  Future<List<IncomeEntity>> fetchAll();

  /// 期間とカテゴリーを指定してレコードを取得する
  Future<List<IncomeEntity>> fetchWithCategoryAndPeriod({
    required PeriodValue period,
    required int categoryId,
  });

  /// 期間とカテゴリーを指定して収入の合計値を取得する
  Future<int> calcurateSumWithBigCategoryAndPeriod({
    required PeriodValue period,
    required int bigCategoryId,
  });

  /// 期間を指定して収入の合計値を取得する
  Future<int> calcurateSumWithPeriod({
    required PeriodValue period,
  });

  /// 期間指定してデータを取得する
  /// カテゴリーの指定はしない
  Future<List<IncomeEntity>> fetchWithoutCategory(
      {required PeriodValue period});

  void insert(IncomeEntity expenseEntity);

  void update(IncomeEntity expenseEntity);

  void delete(int id);
}
