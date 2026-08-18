import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_layout_calculator.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';

void main() {
  final calculator = PredictionGraphLayoutCalculator();

  group('PredictionGraphLayoutCalculator.calculateMaxValue', () {
    test('すべて0なら最低値100を返す', () {
      expect(
        calculator.calculateMaxValue(
          latestPrice: 0,
          predictionPrice: null,
          income: 0,
          budget: 0,
        ),
        100.0,
      );
    });

    test('累積支出が最大ならその値', () {
      expect(
        calculator.calculateMaxValue(
          latestPrice: 90000,
          predictionPrice: 80000,
          income: 50000,
          budget: 30000,
        ),
        90000.0,
      );
    });

    test('予測支出が最大ならその値', () {
      expect(
        calculator.calculateMaxValue(
          latestPrice: 30000,
          predictionPrice: 120000,
          income: 50000,
          budget: 30000,
        ),
        120000.0,
      );
    });

    test('収入が最大ならその値', () {
      expect(
        calculator.calculateMaxValue(
          latestPrice: 30000,
          predictionPrice: null,
          income: 300000,
          budget: 100000,
        ),
        300000.0,
      );
    });

    test('予算が最大ならその値', () {
      expect(
        calculator.calculateMaxValue(
          latestPrice: 30000,
          predictionPrice: null,
          income: 100000,
          budget: 150000,
        ),
        150000.0,
      );
    });
  });

  group('PredictionGraphLayoutCalculator.generateXAxisLabels', () {
    test('30日間の期間は7日刻みで5個のラベルを生成する', () {
      final labels = calculator.generateXAxisLabels(
        fromDate: DateTime(2025, 6, 25),
        toDate: DateTime(2025, 7, 24),
      );

      expect(labels, hasLength(5));
      expect(labels[0].date, DateTime(2025, 6, 25));
      expect(labels[1].date, DateTime(2025, 7, 2));
      expect(labels[2].date, DateTime(2025, 7, 9));
      expect(labels[3].date, DateTime(2025, 7, 16));
      expect(labels[4].date, DateTime(2025, 7, 23));
    });

    test('ラベルはM/d形式の文字列になる', () {
      final labels = calculator.generateXAxisLabels(
        fromDate: DateTime(2025, 6, 25),
        toDate: DateTime(2025, 7, 24),
      );

      expect(labels[0].label, '6/25');
      expect(labels[1].label, '7/2');
    });
  });

  group('PredictionGraphLayoutCalculator.decideLabelDisplay', () {
    test('収入・予算とも0なら両方の線を出さない', () {
      final decision = calculator.decideLabelDisplay(
        income: 0,
        budget: 0,
        maxValue: 100.0,
        predictionGraphLineType: PredictionGraphLineType.thisMonth,
      );

      expect(decision.shouldShowIncomeLine, isFalse);
      expect(decision.shouldShowBudgetLine, isFalse);
      expect(decision.shouldShowExpenseLabel, isTrue);
    });

    test('収入0なら予算線のみ表示', () {
      final decision = calculator.decideLabelDisplay(
        income: 0,
        budget: 50000,
        maxValue: 50000.0,
        predictionGraphLineType: PredictionGraphLineType.thisMonth,
      );

      expect(decision.shouldShowIncomeLine, isFalse);
      expect(decision.shouldShowBudgetLine, isTrue);
    });

    test('予算0なら収入線のみ表示', () {
      final decision = calculator.decideLabelDisplay(
        income: 300000,
        budget: 0,
        maxValue: 300000.0,
        predictionGraphLineType: PredictionGraphLineType.thisMonth,
      );

      expect(decision.shouldShowIncomeLine, isTrue);
      expect(decision.shouldShowBudgetLine, isFalse);
    });

    test('位置の差が10%未満で収入≥予算なら収入線のみ表示', () {
      // 位置差 = |0.5 - 0.45| = 0.05 < 0.1
      final decision = calculator.decideLabelDisplay(
        income: 50000,
        budget: 45000,
        maxValue: 100000.0,
        predictionGraphLineType: PredictionGraphLineType.thisMonth,
      );

      expect(decision.shouldShowIncomeLine, isTrue);
      expect(decision.shouldShowBudgetLine, isFalse);
    });

    test('位置の差が10%未満で予算>収入なら予算線のみ表示', () {
      final decision = calculator.decideLabelDisplay(
        income: 45000,
        budget: 50000,
        maxValue: 100000.0,
        predictionGraphLineType: PredictionGraphLineType.thisMonth,
      );

      expect(decision.shouldShowIncomeLine, isFalse);
      expect(decision.shouldShowBudgetLine, isTrue);
    });

    test('位置の差が10%以上なら両方表示', () {
      // 位置差 = |0.8 - 0.4| = 0.4
      final decision = calculator.decideLabelDisplay(
        income: 80000,
        budget: 40000,
        maxValue: 100000.0,
        predictionGraphLineType: PredictionGraphLineType.thisMonth,
      );

      expect(decision.shouldShowIncomeLine, isTrue);
      expect(decision.shouldShowBudgetLine, isTrue);
    });
  });

  group('PredictionGraphLayoutCalculator.ラベル位置計算', () {
    test('収入ラベル: 予算線がなければ標準位置（-7）', () {
      final position = calculator.calculateIncomeLabel(
        income: 300000,
        budget: 0,
        shouldShowBudgetLine: false,
      );

      expect(position.label, '¥ 300,000');
      expect(position.yOffset, -7.0);
    });

    test('収入ラベル: 収入≤予算なら標準位置（-7）', () {
      final position = calculator.calculateIncomeLabel(
        income: 100000,
        budget: 200000,
        shouldShowBudgetLine: true,
      );

      expect(position.yOffset, -7.0);
    });

    test('収入ラベル: 収入>予算ならさらに上（-25）', () {
      final position = calculator.calculateIncomeLabel(
        income: 300000,
        budget: 200000,
        shouldShowBudgetLine: true,
      );

      expect(position.yOffset, -25.0);
    });

    test('予算ラベル: 収入線がなければ標準位置（-7）', () {
      final position = calculator.calculateBudgetLabel(
        income: 0,
        budget: 150000,
        shouldShowIncomeLine: false,
      );

      expect(position.label, '¥ 150,000');
      expect(position.yOffset, -7.0);
    });

    test('予算ラベル: 収入≤予算なら上寄せ（-23）', () {
      final position = calculator.calculateBudgetLabel(
        income: 100000,
        budget: 200000,
        shouldShowIncomeLine: true,
      );

      expect(position.yOffset, -23.0);
    });

    test('予算ラベル: 収入>予算なら線上（0）', () {
      final position = calculator.calculateBudgetLabel(
        income: 300000,
        budget: 200000,
        shouldShowIncomeLine: true,
      );

      expect(position.yOffset, 0.0);
    });

    test('支出ラベルは固定オフセット（-7）', () {
      final position = calculator.calculateExpenseLabel(123456);

      expect(position.label, '¥ 123,456');
      expect(position.yOffset, -7.0);
    });
  });
}
