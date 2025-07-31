import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';

/// アプリ起動時 or テスト時に本プロバイダーを override して使用してください
final fixedCostRepositoryProvider = Provider<FixedCostRepository>(
  (_) => throw UnimplementedError("FixedCostRepositoryの実装がされていません。"),
);

/// サブスク・固定費に関するリポジトリ
abstract interface class FixedCostRepository {
  // / 全ての登録情報を取得する
  Future<List<FixedCostEntity>> fetchAll();

  Future<FixedCostEntity> fetch({required int fixedCostId});

  /// 期間指定してデータを取得する
  Future<List<FixedCostEntity>> fetchNextPeriodPayment(
      {required PeriodValue period});

  // 期間指定して変動あり固定費の推定支出合計を取得する
  Future<int> fetchEstimatedPriceByPeriod(
      {required PeriodValue period});

  Future<int> insert(FixedCostEntity entity);

  Future<void> update(FixedCostEntity entity);

  Future<void> delete(int id);
}
