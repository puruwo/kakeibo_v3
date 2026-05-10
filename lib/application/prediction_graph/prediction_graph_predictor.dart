import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_constants.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/util/util.dart';

/// 累積データから組み立てた折れ線・予測線関連の計算結果
class PredictionResult {
  /// 累積支出を折れ線として描画するためのポイント列
  final List<PredictionGraphPoint> expensePoints;

  /// 累積支出の最新値（折れ線の右端の高さ）
  final int lastPrice;

  /// 累積支出の最新日付（折れ線の右端のX座標）
  final DateTime lastDate;

  /// 予測支出額（予測線を出さない場合は null）
  final int? predictionPrice;

  /// 予測線を描画するか
  final bool shouldShowPredictionLine;

  /// 予測線の2点（描画しない場合は null）
  final List<PredictionGraphPoint>? predictionPoints;

  /// 予測支出ラベル文字列（描画しない場合は null）
  final String? predictionLabel;

  PredictionResult({
    required this.expensePoints,
    required this.lastPrice,
    required this.lastDate,
    required this.predictionPrice,
    required this.shouldShowPredictionLine,
    required this.predictionPoints,
    required this.predictionLabel,
  });
}

final predictionGraphPredictorProvider = Provider<PredictionGraphPredictor>(
  (_) => PredictionGraphPredictor(),
);

/// 予測グラフのグラフ種別判定と予測線計算
///
/// DBアクセスは行わず、累積支出データと期間情報から
/// グラフ種別 (`PredictionGraphLineType`) と予測線関連の計算結果を返す。
class PredictionGraphPredictor {
  /// 期間と今日の日付からグラフ種別を判定する
  PredictionGraphLineType resolveGraphType({
    required DateTime fromDate,
    required DateTime toDate,
    required DateTime today,
  }) {
    if (toDate.isBefore(today)) {
      return PredictionGraphLineType.lastMonth;
    }
    if (fromDate.isAfter(today)) {
      return PredictionGraphLineType.futureMonth;
    }
    return PredictionGraphLineType.thisMonth;
  }

  /// 累積支出データから予測線を計算する
  ///
  /// `cumulativePriceData` は `PredictionGraphDataSource.fetchCumulativeByDate` の戻り値。
  /// グラフ種別が `lastMonth` / `futureMonth`、経過日数が最小しきい値以下、
  /// データなしのいずれかの場合は予測線を出さない（`shouldShowPredictionLine = false`）。
  PredictionResult calculatePrediction({
    required PredictionGraphLineType graphType,
    required List<Map<String, dynamic>> cumulativePriceData,
    required DateTime fromDate,
    required DateTime toDate,
    required DateTime today,
  }) {
    // 累積支出データをチャート用ポイント列に変換
    final expensePoints = <PredictionGraphPoint>[];
    int lastPrice = 0;
    DateTime lastDate =
        graphType == PredictionGraphLineType.thisMonth ? today : toDate;
    if (cumulativePriceData.isNotEmpty) {
      for (final data in cumulativePriceData) {
        final dateTime = data['date'] as DateTime;
        final price = data['sum_price_daily'] as int;
        expensePoints.add(PredictionGraphPoint(date: dateTime, price: price));
      }
      // 最後のデータから経過情報を取得
      final lastData = cumulativePriceData.last;
      lastDate = lastData['date'] as DateTime;
      lastPrice = lastData['sum_price_daily'] as int;
    }

    // 経過日数と総日数を計算
    final elapsedDays = lastDate.difference(fromDate).inDays + 1;
    final totalDays = toDate.difference(fromDate).inDays + 1;

    // 予測支出額を表示しない条件（過去月、未来月、経過日数が最小しきい値以下、データなし）
    if (elapsedDays <= PredictionGraphConstants.minElapsedDaysForPrediction ||
        graphType == PredictionGraphLineType.lastMonth ||
        graphType == PredictionGraphLineType.futureMonth ||
        cumulativePriceData.isEmpty) {
      return PredictionResult(
        expensePoints: expensePoints,
        lastPrice: lastPrice,
        lastDate: lastDate,
        predictionPrice: null,
        shouldShowPredictionLine: false,
        predictionPoints: null,
        predictionLabel: null,
      );
    }

    // 支出データがあり、かつ経過日数がしきい値超〜総日数未満の場合に予測ポイントを作成
    final predictionPrice = ((lastPrice / elapsedDays) * totalDays).toInt();
    final predictionPoints = <PredictionGraphPoint>[
      PredictionGraphPoint(date: lastDate, price: lastPrice),
      PredictionGraphPoint(date: toDate, price: predictionPrice),
    ];
    final predictionLabel = yenFormattedPriceGetter(predictionPrice);

    return PredictionResult(
      expensePoints: expensePoints,
      lastPrice: lastPrice,
      lastDate: lastDate,
      predictionPrice: predictionPrice,
      shouldShowPredictionLine: true,
      predictionPoints: predictionPoints,
      predictionLabel: predictionLabel,
    );
  }
}
