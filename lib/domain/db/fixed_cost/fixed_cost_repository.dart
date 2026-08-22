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

  /// 変動固定費の推定額を再計算し、未確定行の予想額まで同期する（仕様 §6.5）
  ///
  /// 「確定行の平均を求める → マスタの estimated_price を更新する →
  /// 当該マスタの未確定行の estimated_price を一括更新する」を
  /// 1トランザクションで実行する。同期だけ失敗して行側が古い値で
  /// 固定される状態を作らないため。
  /// 確定行が0件のときは何も更新しない（最後の値を保持する）。
  Future<void> recalculateEstimatedPriceWithSync({required int fixedCostId});

  /// マスタの更新と、未確定行の予想額の同期を1トランザクションで行う（仕様 §6.5）
  ///
  /// マスタの金額・推定額をユーザーが手動編集したときに使う。
  Future<void> updateWithUnconfirmedRowsSync(FixedCostEntity entity);
}
