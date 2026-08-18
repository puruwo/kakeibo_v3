import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_predictor.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';

void main() {
  final predictor = PredictionGraphPredictor();

  group('PredictionGraphPredictor.resolveGraphType', () {
    final fromDate = DateTime(2025, 6, 25);
    final toDate = DateTime(2025, 7, 24);

    test('期間終了日が今日より前ならlastMonth（過去月）', () {
      expect(
        predictor.resolveGraphType(
          fromDate: fromDate,
          toDate: toDate,
          today: DateTime(2025, 7, 25),
        ),
        PredictionGraphLineType.lastMonth,
      );
    });

    test('期間開始日が今日より後ならfutureMonth（未来月）', () {
      expect(
        predictor.resolveGraphType(
          fromDate: fromDate,
          toDate: toDate,
          today: DateTime(2025, 6, 24),
        ),
        PredictionGraphLineType.futureMonth,
      );
    });

    test('期間内に今日が含まれるならthisMonth（当月）', () {
      expect(
        predictor.resolveGraphType(
          fromDate: fromDate,
          toDate: toDate,
          today: DateTime(2025, 7, 6),
        ),
        PredictionGraphLineType.thisMonth,
      );
    });

    test('境界: 今日が期間終了日ちょうどならthisMonth', () {
      expect(
        predictor.resolveGraphType(
          fromDate: fromDate,
          toDate: toDate,
          today: toDate,
        ),
        PredictionGraphLineType.thisMonth,
      );
    });

    test('境界: 今日が期間開始日ちょうどならthisMonth', () {
      expect(
        predictor.resolveGraphType(
          fromDate: fromDate,
          toDate: toDate,
          today: fromDate,
        ),
        PredictionGraphLineType.thisMonth,
      );
    });
  });

  group('PredictionGraphPredictor.calculatePrediction', () {
    // 集計期間: 6/25〜7/24（30日間）
    final fromDate = DateTime(2025, 6, 25);
    final toDate = DateTime(2025, 7, 24);

    List<Map<String, dynamic>> cumulativeData(List<(DateTime, int)> points) =>
        points
            .map(
              (p) => <String, dynamic>{'date': p.$1, 'sum_price_daily': p.$2},
            )
            .toList();

    test('当月・経過日数がしきい値超なら日割り線形予測を返す', () {
      // 最終データ7/4 → 経過10日、総日数30日、累積30,000円
      final result = predictor.calculatePrediction(
        graphType: PredictionGraphLineType.thisMonth,
        cumulativePriceData: cumulativeData([
          (DateTime(2025, 6, 26), 10000),
          (DateTime(2025, 7, 4), 30000),
        ]),
        fromDate: fromDate,
        toDate: toDate,
        today: DateTime(2025, 7, 6),
      );

      expect(result.shouldShowPredictionLine, isTrue);
      // (30000 / 10日) × 30日 = 90000
      expect(result.predictionPrice, 90000);
      expect(result.predictionLabel, '¥ 90,000');
      expect(result.lastPrice, 30000);
      expect(result.lastDate, DateTime(2025, 7, 4));
      // 予測線は最新実績点と期間末の予測点を結ぶ
      expect(result.predictionPoints, hasLength(2));
      expect(result.predictionPoints![0].date, DateTime(2025, 7, 4));
      expect(result.predictionPoints![0].price, 30000);
      expect(result.predictionPoints![1].date, toDate);
      expect(result.predictionPoints![1].price, 90000);
      // 実績の折れ線ポイントは入力データと同数
      expect(result.expensePoints, hasLength(2));
    });

    test('経過日数がしきい値（5日）以下なら予測線を出さない', () {
      // 最終データ6/29 → 経過5日
      final result = predictor.calculatePrediction(
        graphType: PredictionGraphLineType.thisMonth,
        cumulativePriceData: cumulativeData([(DateTime(2025, 6, 29), 10000)]),
        fromDate: fromDate,
        toDate: toDate,
        today: DateTime(2025, 6, 29),
      );

      expect(result.shouldShowPredictionLine, isFalse);
      expect(result.predictionPrice, isNull);
      expect(result.predictionPoints, isNull);
      expect(result.predictionLabel, isNull);
    });

    test('経過日数6日なら予測線を出す（しきい値の直上）', () {
      final result = predictor.calculatePrediction(
        graphType: PredictionGraphLineType.thisMonth,
        cumulativePriceData: cumulativeData([(DateTime(2025, 6, 30), 12000)]),
        fromDate: fromDate,
        toDate: toDate,
        today: DateTime(2025, 6, 30),
      );

      expect(result.shouldShowPredictionLine, isTrue);
      // (12000 / 6日) × 30日 = 60000
      expect(result.predictionPrice, 60000);
    });

    test('過去月は実績があっても予測線を出さない', () {
      final result = predictor.calculatePrediction(
        graphType: PredictionGraphLineType.lastMonth,
        cumulativePriceData: cumulativeData([(DateTime(2025, 7, 20), 50000)]),
        fromDate: fromDate,
        toDate: toDate,
        today: DateTime(2025, 8, 1),
      );

      expect(result.shouldShowPredictionLine, isFalse);
      expect(result.expensePoints, hasLength(1));
      expect(result.lastPrice, 50000);
    });

    test('データなし（当月）は予測線なし・最新日は今日になる', () {
      final today = DateTime(2025, 7, 6);
      final result = predictor.calculatePrediction(
        graphType: PredictionGraphLineType.thisMonth,
        cumulativePriceData: const [],
        fromDate: fromDate,
        toDate: toDate,
        today: today,
      );

      expect(result.shouldShowPredictionLine, isFalse);
      expect(result.expensePoints, isEmpty);
      expect(result.lastPrice, 0);
      expect(result.lastDate, today);
    });

    test('データなし（過去月）の最新日は期間末になる', () {
      final result = predictor.calculatePrediction(
        graphType: PredictionGraphLineType.lastMonth,
        cumulativePriceData: const [],
        fromDate: fromDate,
        toDate: toDate,
        today: DateTime(2025, 8, 1),
      );

      expect(result.lastDate, toDate);
    });
  });
}
