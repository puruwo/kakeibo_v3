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

  Future<int> insert(FixedCostEntity entity);

  void update(FixedCostEntity entity);

  void delete(int id);
}
