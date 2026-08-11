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

  // / 削除されていない固定費のみを取得する
  Future<List<FixedCostEntity>> fetchAllActive();

  Future<FixedCostEntity> fetch({required int fixedCostId});

  /// 期間指定してデータを取得する
  Future<List<FixedCostEntity>> fetchNextPeriodPayment(
      {required PeriodValue period});

  // id指定して変動あり固定費の推定支出を取得する
  Future<int> fetchEstimatedPriceById(
      {required int id});

  Future<int> insert(FixedCostEntity entity);

  Future<void> update(FixedCostEntity entity);

  /// マスタの論理削除と、未払い実績の削除を1トランザクションで行う
  ///
  /// 未払い実績 = 未確定（`is_confirmed = 0`）または支払日が [today] より後のもの。
  /// 支払日が到来済みの記録は履歴として残す（→ ADR-007）。
  /// [today] は運用日付（`yyyyMMdd`）。
  Future<void> deleteWithUnpaidExpenses(
      {required int id, required String today});
}
