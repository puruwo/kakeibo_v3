/// 予測グラフのレイアウト・しきい値・表示用IDなどの定数を集約
///
/// マジックナンバーを散在させないため、`PredictionGraphUsecase` 配下で参照される
/// しきい値・閾値・特殊IDをすべてここにまとめる。
class PredictionGraphConstants {
  PredictionGraphConstants._();

  /// 横軸ラベルの表示間隔（日数）
  /// 例: 7 の場合、月初から7日刻みで日付ラベルを描画する
  static const int xAxisLabelInterval = 7;

  /// 予測支出額（折れ線の予想線）を表示するための最小経過日数
  /// これ以下の経過日数では精度が低いため予測線を非表示にする
  static const int minElapsedDaysForPrediction = 5;

  /// 収入ラベルと予算ラベルの重なり判定しきい値（グラフ高さに対する比率）
  /// 両ラベルの位置差がこれ未満なら重なるとみなして片方のみ表示する
  static const double labelOverlapPositionThreshold = 0.1;

  /// 棒グラフの最大値スケールしきい値（円）
  /// 日別合計がこれを超えた場合は実値を最大値に採用、超えなければこの値を最大値に固定する
  static const int barChartScaleThreshold = 20000;

  /// 固定費棒の大カテゴリーID
  /// 一般カテゴリーのIDと衝突しないよう、負値を使用する
  static const int fixedCostBarCategoryId = -1;
}
