import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/view/component/card_container.dart';

class PredictionGraph extends ConsumerWidget {
  const PredictionGraph({super.key, required this.dateScope});

  final DateScopeEntity dateScope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidthSize = MediaQuery.of(context).size.width;
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    final predictionGraphData =
        ref.watch(predictionGraphDataProvider(dateScope));

    return CardContainer(
      height: 213,
      width: 343 * screenHorizontalMagnification,
      child: predictionGraphData.when(
        data: (data) {
          if (data.predictionGraphLineType ==
              PredictionGraphLineType.futureMonth) {
            return const Center(
              child: Text(
                '選択月の支出の入力がありません',
                style: TextStyle(color: MyColors.secondaryLabel, fontSize: 16),
              ),
            );
          }
          return _PredictionGraphWidget(data: data);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text(
            'エラーが発生しました',
            style: TextStyle(color: MyColors.secondaryLabel, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _PredictionGraphWidget extends StatelessWidget {
  const _PredictionGraphWidget({required this.data});

  final PredictionGraphValue data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomPaint(
        painter: _PredictionGraphPainter(data: data),
        child: Container(),
      ),
    );
  }
}

class _PredictionGraphPainter extends CustomPainter {
  _PredictionGraphPainter({required this.data});

  final PredictionGraphValue data;

  @override
  void paint(Canvas canvas, Size size) {
    // グラフエリアのマージン
    const double topMargin = 30;
    const double bottomMargin = 30;
    const double leftMargin = 8;
    const double rightMargin = 8;

    final graphWidth = size.width - leftMargin - rightMargin;
    final graphHeight = size.height - topMargin - bottomMargin;

    // 最大値を計算（1.2倍の余裕を持たせる）
    // maxValueが0またはnullの場合は最低値として100を設定
    final maxValue = (data.maxValue ?? 0) > 0 ? data.maxValue! * 1.2 : 100.0;

    // X軸を描画
    _drawXAxis(canvas, size, leftMargin, topMargin, graphWidth, graphHeight);

    // 棒グラフを描画（折れ線グラフの後ろに描画）
    if (data.dailyBarDataList != null && data.dailyBarDataList!.isNotEmpty) {
      _drawDailyBars(canvas, leftMargin, topMargin, graphWidth, graphHeight);
    }

    // 収入ラインを描画
    if ((data.income ?? 0) > 0) {
      _drawIncomeLine(canvas, leftMargin, topMargin, graphWidth, graphHeight,
          maxValue, data.income!, data.budget ?? 0);
    }

    // 予算ラインを描画
    if ((data.budget ?? 0) > 0) {
      _drawBudgetLine(canvas, leftMargin, topMargin, graphWidth, graphHeight,
          maxValue, data.budget!, data.income ?? 0);
    }

    // 予測ラインを描画（点線）
    if (data.shouldShowPredictionLine &&
        data.predictionPoints != null &&
        data.predictionPoints!.isNotEmpty) {
      _drawPredictionLine(canvas, leftMargin, topMargin, graphWidth,
          graphHeight, maxValue, data.predictionPoints!, data.predictionPrice!);
    }

    // 支出ラインを描画
    if (data.expensePoints != null && data.expensePoints!.isNotEmpty) {
      _drawExpenseLine(canvas, leftMargin, topMargin, graphWidth, graphHeight,
          maxValue, data.expensePoints!);
    }
  }

  /// 日別棒グラフを描画
  void _drawDailyBars(Canvas canvas, double leftMargin, double topMargin,
      double graphWidth, double graphHeight) {
    final dailyBarDataList = data.dailyBarDataList!;
    final barMaxValue = data.barMaxValue ?? 20000;
    final totalDays = data.toDate.difference(data.fromDate).inDays + 1;

    // 棒グラフの最大高さ（グラフ高さの1/3）
    final maxBarHeight = graphHeight / 3;

    // 棒の幅を計算（日数に応じて調整）
    const barWidthRatio = 0.6;
    final barWidth = (graphWidth / totalDays) * barWidthRatio;

    for (final barData in dailyBarDataList) {
      final daysDiff = barData.date.difference(data.fromDate).inDays;
      final x = leftMargin +
          (daysDiff / totalDays) * graphWidth +
          (graphWidth / totalDays) * (1 - barWidthRatio) / 2;

      // その日の総支出を計算
      int dailyTotal = 0;
      for (final expense in barData.categoryExpenses) {
        dailyTotal += expense.price.toInt();
      }

      // 総支出から棒の高さを計算
      final totalBarHeight = (dailyTotal / barMaxValue) * maxBarHeight;

      // 積み上げ棒グラフを描画
      double currentY = topMargin + graphHeight; // グラフの底

      for (final expense in barData.categoryExpenses) {
        // カテゴリーの棒の高さを計算
        final barHeight = (expense.price / dailyTotal) * totalBarHeight;

        // 色をパース
        final colorCode = expense.colorCode.replaceAll('#', '');
        int colorValue;
        try {
          colorValue = int.parse(colorCode, radix: 16);
        } catch (e) {
          colorValue = 0xFF888888;
        }
        // アルファ値が含まれていない場合は追加
        if (colorCode.length == 6) {
          colorValue = 0xFF000000 | colorValue;
        }

        var barColor = Color(colorValue);

        // 未来日付の場合は透明度を下げる
        if (barData.isFutureDate) {
          barColor = barColor.withOpacity(0.4);
        }

        final paint = Paint()
          ..color = barColor
          ..style = PaintingStyle.fill;

        // 棒を描画（下から積み上げ）
        canvas.drawRect(
          Rect.fromLTWH(
            x,
            currentY - barHeight,
            barWidth,
            barHeight,
          ),
          paint,
        );

        currentY -= barHeight;
      }
    }
  }

  /// X軸を描画
  void _drawXAxis(Canvas canvas, Size size, double leftMargin, double topMargin,
      double graphWidth, double graphHeight) {
    // X軸メモリラベルの位置調節
    const xAxisLabelVerticalOffset = 5;

    final paint = Paint()
      ..color = MyColors.systemGray
      ..strokeWidth = 1.0;

    final y = topMargin + graphHeight;
    canvas.drawLine(
      Offset(leftMargin, y),
      Offset(leftMargin + graphWidth, y),
      paint,
    );

    // usecaseで生成されたラベルを使用
    if (data.xAxisLabels == null) return;
    final totalDays = data.toDate.difference(data.fromDate).inDays + 1;

    for (final xLabel in data.xAxisLabels!) {
      final daysDiff = xLabel.date.difference(data.fromDate).inDays;
      final x = leftMargin + (daysDiff / totalDays) * graphWidth;

      final textSpan = TextSpan(
        text: xLabel.label,
        style: const TextStyle(
          fontSize: 14,
          color: MyColors.secondaryLabel,
          fontFamily: 'sf_ui',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y + xAxisLabelVerticalOffset),
      );
    }
  }

  /// 収入ラインを描画
  void _drawIncomeLine(
      Canvas canvas,
      double leftMargin,
      double topMargin,
      double graphWidth,
      double graphHeight,
      double maxValue,
      int income,
      int budget) {
    // usecaseで判定された表示フラグを使用
    if (!data.shouldShowIncomeLine || data.incomeLabelPosition == null) {
      return;
    }

    final y = topMargin + graphHeight - (income / maxValue) * graphHeight;

    // usecaseで計算されたラベル位置を使用
    final labelPosition = data.incomeLabelPosition!;
    final textSpan = TextSpan(
      text: labelPosition.label,
      style: const TextStyle(
        fontSize: 14,
        color: MyColors.secondaryLabel,
        fontFamily: 'sf_ui',
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // ラベルを線の垂直中央に配置
    final labelY = y - textPainter.height / 2;
    textPainter.paint(canvas, Offset(leftMargin, labelY));

    // ラインをラベルの右端から描画
    final lineStartX = leftMargin + textPainter.width + 8;
    final paint = Paint()
      ..color = MyColors.separater
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(lineStartX, y),
      Offset(leftMargin + graphWidth, y),
      paint,
    );
  }

  /// 予算ラインを描画
  void _drawBudgetLine(
      Canvas canvas,
      double leftMargin,
      double topMargin,
      double graphWidth,
      double graphHeight,
      double maxValue,
      int budget,
      int income) {
    // usecaseで判定された表示フラグを使用
    if (!data.shouldShowBudgetLine || data.budgetLabelPosition == null) {
      return;
    }

    final y = topMargin + graphHeight - (budget / maxValue) * graphHeight;

    // usecaseで計算されたラベル位置を使用
    final labelPosition = data.budgetLabelPosition!;
    final textSpan = TextSpan(
      text: labelPosition.label,
      style: const TextStyle(
        fontSize: 14,
        color: MyColors.secondaryLabel,
        fontFamily: 'sf_ui',
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // ラベルを線の垂直中央に配置
    final labelY = y - textPainter.height / 2;
    textPainter.paint(canvas, Offset(leftMargin, labelY));

    // ラインをラベルの右端から描画
    final lineStartX = leftMargin + textPainter.width + 8;
    final paint = Paint()
      ..color = MyColors.separater
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(lineStartX, y),
      Offset(leftMargin + graphWidth, y),
      paint,
    );
  }

  /// 予測ラインを描画（点線）
  void _drawPredictionLine(
      Canvas canvas,
      double leftMargin,
      double topMargin,
      double graphWidth,
      double graphHeight,
      double maxValue,
      List<dynamic> predictionPoints,
      int predictionPrice) {
    final paint = Paint()
      ..color = MyColors.separater
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final totalDays = data.toDate.difference(data.fromDate).inDays + 1;

    final path = Path();
    for (int i = 0; i < predictionPoints.length; i++) {
      final point = predictionPoints[i];
      final daysDiff = point.date.difference(data.fromDate).inDays;
      final x = leftMargin + (daysDiff / totalDays) * graphWidth;
      final y =
          topMargin + graphHeight - (point.price / maxValue) * graphHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // 点線を描画
    _drawDashedPath(canvas, path, paint);

    // usecaseで生成されたラベルを使用
    if (predictionPoints.length >= 2) {
      final lastPoint = predictionPoints.last;
      final daysDiff = lastPoint.date.difference(data.fromDate).inDays;
      final x = leftMargin + (daysDiff / totalDays) * graphWidth;
      final y =
          topMargin + graphHeight - (lastPoint.price / maxValue) * graphHeight;

      final textSpan = TextSpan(
        text: data.predictionLabel,
        style: const TextStyle(
          fontSize: 14,
          color: MyColors.secondaryLabel,
          fontFamily: 'sf_ui',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 130, y - 18));
    }
  }

  /// 支出ラインを描画
  void _drawExpenseLine(
      Canvas canvas,
      double leftMargin,
      double topMargin,
      double graphWidth,
      double graphHeight,
      double maxValue,
      List<dynamic> expensePoints) {
    final paint = Paint()
      ..color = MyColors.pink
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final totalDays = data.toDate.difference(data.fromDate).inDays + 1;

    final path = Path();
    for (int i = 0; i < expensePoints.length; i++) {
      final point = expensePoints[i];
      final daysDiff = point.date.difference(data.fromDate).inDays;
      final x = leftMargin + (daysDiff / totalDays) * graphWidth;
      final y =
          topMargin + graphHeight - (point.price / maxValue) * graphHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  /// 点線を描画
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 3.0;
    const dashSpace = 2.0;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;

      while (distance < metric.length) {
        final length = draw ? dashWidth : dashSpace;
        if (draw) {
          final extractPath = metric.extractPath(distance, distance + length);
          canvas.drawPath(extractPath, paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
