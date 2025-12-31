// import 'dart:math' show pow, sqrt; // Removed
import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/view/monthly_page/prediction_graph_area/prediction_graph_text_styles.dart';

class PredictionGraphPainter extends CustomPainter {
  PredictionGraphPainter({required this.data});

  final PredictionGraphValue data;

  @override
  void paint(Canvas canvas, Size size) {
    // グラフエリアのマージン
    const double topMargin = 8;
    const double bottomMargin = 40;
    const double leftMargin = 6;
    const double rightMargin = 12;

    // 予想支出ラベル用の専用領域（他のラインはこの下から描画）
    const double predictionLabelAreaHeight = 14.0;

    // ラベルの左端位置（すべてのラベルで統一）
    const double labelLeftPadding = 8.0;

    // ラベル幅を考慮したグラフ描画エリアの左端オフセット
    // 「日別」ラベルが入る幅を確保（約40px）
    const double graphLeftOffset = 40.0;

    final totalWidth = size.width - leftMargin - rightMargin;
    final graphHeight = size.height - topMargin - bottomMargin;

    // グラフ描画エリアの幅（ラベルエリアを除いた部分）
    final graphWidth = totalWidth - graphLeftOffset;

    // 棒グラフの最大高さ（グラフ高さの1/5）とマージン
    final barAreaHeight = graphHeight / 4;
    const double barLineGap = 8.0; // 棒グラフと折れ線グラフの間隔

    // 折れ線グラフ用のエリア（棒グラフの上、予想支出ラベル領域の下）
    final lineGraphHeight =
        graphHeight - barAreaHeight - barLineGap - predictionLabelAreaHeight;

    // 折れ線グラフの開始位置（予想支出ラベル領域の下）
    const lineTopMargin = topMargin + predictionLabelAreaHeight;

    // 折れ線グラフのy=0地点
    final lineZeroY = lineTopMargin + lineGraphHeight;

    // 収入と予算の大きい方を取得
    final maxBudgetOrIncome = [data.income ?? 0, data.budget ?? 0]
        .reduce((curr, next) => curr > next ? curr : next);

    // 累積支出の最大値を取得
    int maxExpense = 0;
    if (data.expensePoints != null && data.expensePoints!.isNotEmpty) {
      for (final point in data.expensePoints!) {
        if (point.price > maxExpense) {
          maxExpense = point.price.toInt();
        }
      }
    }

    final predictionPrice = data.predictionPrice ?? 0;

    // 条件: 収入・予算が存在し、どちらか大きい方の金額が予想支出の半分以下
    final bool shouldHideLineAndMoveLabel = (data.income ?? 0) > 0 &&
        (data.budget ?? 0) > 0 &&
        predictionPrice > 0 &&
        maxBudgetOrIncome <= predictionPrice / 2;

    // 最大値を計算（1.2倍の余裕を持たせる）
    // maxValueが0またはnullの場合は最低値として100を設定
    double maxValue;
    if (shouldHideLineAndMoveLabel) {
      // 予算・収入・累積支出の一番高い額を基準にする
      final maxVal = [maxBudgetOrIncome, maxExpense]
          .reduce((curr, next) => curr > next ? curr : next);
      maxValue = maxVal > 0 ? maxVal * 1.2 : 100.0;
    } else {
      maxValue = (data.maxValue ?? 0) > 0 ? data.maxValue! * 1.2 : 100.0;
    }

    // X軸を描画（グラフ開始位置から）
    _drawXAxis(canvas, size, leftMargin + graphLeftOffset, topMargin,
        graphWidth, graphHeight);

    // 折れ線グラフの0円軸とラベルを描画
    _drawZeroLine(canvas, leftMargin, lineZeroY, totalWidth, labelLeftPadding,
        graphLeftOffset);

    // 棒グラフの「日別」ラベルを描画
    _drawDailyLabel(
        canvas, leftMargin, topMargin + graphHeight, labelLeftPadding);

    // 棒グラフを描画（グラフ開始位置から）
    if (data.dailyBarDataList != null && data.dailyBarDataList!.isNotEmpty) {
      _drawDailyBars(canvas, leftMargin + graphLeftOffset, topMargin,
          graphWidth, graphHeight, barAreaHeight);
    }

    // ラベルの重なり検出用の高さ（テキストの高さ + マージン）
    const labelHeight = 10.0; // おおよそのラベル高さ
    const labelMargin = 0.0; // ラベル間のマージン

    // 各ラインのY座標を計算
    final incomeY = (data.income ?? 0) > 0 && data.shouldShowIncomeLine
        ? lineTopMargin +
            lineGraphHeight -
            ((data.income ?? 0) / maxValue) * lineGraphHeight
        : null;
    final budgetY = (data.budget ?? 0) > 0 && data.shouldShowBudgetLine
        ? lineTopMargin +
            lineGraphHeight -
            ((data.budget ?? 0) / maxValue) * lineGraphHeight
        : null;
    // X軸（折れ線グラフの0円軸）のY座標
    final xAxisY = lineZeroY;

    // 優先順位: X軸 > 予算 > 収入
    // X軸と予算ラインの重なりチェック
    bool shouldShowBudgetLine = budgetY != null;
    if (budgetY != null) {
      final budgetLabelTop = budgetY - labelHeight / 2;
      final budgetLabelBottom = budgetY + labelHeight / 2;
      // X軸ラベルとの重なりをチェック
      final xAxisLabelTop = xAxisY - labelHeight / 2;
      final xAxisLabelBottom = xAxisY + labelHeight / 2;
      if (budgetLabelBottom + labelMargin >= xAxisLabelTop &&
          budgetLabelTop - labelMargin <= xAxisLabelBottom) {
        shouldShowBudgetLine = false; // X軸と重なる場合は予算を非表示
      }
    }

    // X軸と収入ラインの重なりチェック、および予算ラインとの重なりチェック
    bool shouldShowIncomeLine = incomeY != null;
    if (incomeY != null) {
      final incomeLabelTop = incomeY - labelHeight / 2;
      final incomeLabelBottom = incomeY + labelHeight / 2;
      // X軸ラベルとの重なりをチェック
      final xAxisLabelTop = xAxisY - labelHeight / 2;
      final xAxisLabelBottom = xAxisY + labelHeight / 2;
      if (incomeLabelBottom + labelMargin >= xAxisLabelTop &&
          incomeLabelTop - labelMargin <= xAxisLabelBottom) {
        shouldShowIncomeLine = false; // X軸と重なる場合は収入を非表示
      }
      // 予算ラベルとの重なりをチェック（予算が表示される場合のみ）
      if (shouldShowIncomeLine && shouldShowBudgetLine && budgetY != null) {
        final budgetLabelTop = budgetY - labelHeight / 2;
        final budgetLabelBottom = budgetY + labelHeight / 2;
        if (incomeLabelBottom + labelMargin >= budgetLabelTop &&
            incomeLabelTop - labelMargin <= budgetLabelBottom) {
          shouldShowIncomeLine = false; // 予算と重なる場合は収入を非表示
        }
      }
    }

    // 収入ラインを描画（グラフ開始位置から）
    if ((data.income ?? 0) > 0 && shouldShowIncomeLine) {
      _drawIncomeLine(
          canvas,
          leftMargin + graphLeftOffset,
          lineTopMargin,
          graphWidth,
          lineGraphHeight,
          maxValue,
          data.income!,
          data.budget ?? 0,
          labelLeftPadding - graphLeftOffset); // ラベルは左端に配置
    }

    // 予算ラインを描画（グラフ開始位置から）
    if ((data.budget ?? 0) > 0 && shouldShowBudgetLine) {
      _drawBudgetLine(
          canvas,
          leftMargin + graphLeftOffset,
          lineTopMargin,
          graphWidth,
          lineGraphHeight,
          maxValue,
          data.budget!,
          data.income ?? 0,
          labelLeftPadding - graphLeftOffset); // ラベルは左端に配置
    }

    // 予測ラインを描画（点線）
    if (data.shouldShowPredictionLine &&
        data.predictionPoints != null &&
        data.predictionPoints!.isNotEmpty) {
      _drawPredictionLine(
          canvas,
          leftMargin + graphLeftOffset,
          lineTopMargin,
          graphWidth,
          lineGraphHeight,
          maxValue,
          data.predictionPoints!,
          data.predictionPrice!,
          shouldHideLineAndMoveLabel,
          topMargin); // 予想支出ラベル用のtopMarginを渡す
    }

    // 支出ラインを描画（グラフ開始位置から）
    if (data.expensePoints != null && data.expensePoints!.isNotEmpty) {
      _drawExpenseLine(canvas, leftMargin + graphLeftOffset, lineTopMargin,
          graphWidth, lineGraphHeight, maxValue, data.expensePoints!,
          shouldShowExpenseLabel: data.shouldShowExpenseLabel,
          expenseLabelPosition: data.expenseLabelPosition,
          labelLeftPadding: labelLeftPadding - graphLeftOffset);
    }
  }

  /// 折れ線グラフの0円軸とラベルを描画
  void _drawZeroLine(Canvas canvas, double leftMargin, double y,
      double totalWidth, double labelLeftPadding, double graphLeftOffset) {
    const textSpan = TextSpan(
      text: '￥0',
      style: PredictionGraphTextStyles.graphLabel,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // ラベルを線の垂直中央に配置
    final labelY = y - textPainter.height / 2;
    textPainter.paint(canvas, Offset(leftMargin + labelLeftPadding, labelY));

    // ラインをグラフ開始位置から描画
    final lineStartX = leftMargin + graphLeftOffset;
    final paint = Paint()
      ..color = MyColors.separater
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(lineStartX, y),
      Offset(leftMargin + totalWidth, y),
      paint,
    );
  }

  /// 棒グラフの「日別」ラベルを描画
  void _drawDailyLabel(
      Canvas canvas, double leftMargin, double y, double labelLeftPadding) {
    const textSpan = TextSpan(
      text: '日別',
      style: PredictionGraphTextStyles.graphLabel,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // ラベルの中の中心がと同じ高さになるように
    final labelY = y - textPainter.height / 2;
    textPainter.paint(canvas, Offset(leftMargin + labelLeftPadding, labelY));
  }

  /// 日別棒グラフを描画
  void _drawDailyBars(Canvas canvas, double leftMargin, double topMargin,
      double graphWidth, double graphHeight, double barAreaHeight) {
    final dailyBarDataList = data.dailyBarDataList!;
    final totalDays = data.toDate.difference(data.fromDate).inDays + 1;

    // 棒グラフの最大高さ（グラフ高さの1/3）
    final maxBarHeight = barAreaHeight;

    // 最小棒高さ（支出がある日は最低でもこの高さを確保）
    const minBarHeight = 4.0;

    // 棒の幅を計算（日数に応じて調整）
    const barWidthRatio = 0.7;
    final barWidth = (graphWidth / totalDays) * barWidthRatio;

    for (final barData in dailyBarDataList) {
      final daysDiff = barData.date.difference(data.fromDate).inDays;
      final x = leftMargin +
          (daysDiff / totalDays) * graphWidth +
          (graphWidth / totalDays) * (1 - barWidthRatio) / 2;

      // UseCaseで計算された正規化高さを使用 (0.0 ~ 1.0)
      double totalBarHeight = barData.normalizedTotalHeight * maxBarHeight;

      // 最小高さを確保
      if (totalBarHeight < minBarHeight) {
        totalBarHeight = minBarHeight;
      }

      // 積み上げ棒グラフを描画
      double currentY = topMargin + graphHeight; // グラフの底
      final categoryCount = barData.categoryExpenses.length;
      int categoryIndex = 0;

      for (final expense in barData.categoryExpenses) {
        // UseCaseで計算された比率と色を使用
        // カテゴリーの棒の高さを計算
        final barHeight = expense.normalizedHeight * totalBarHeight;

        // UseCaseで計算された色を使用
        var barColor = MyColors().getColorFromHex(expense.colorCode);

        // 未来日付の場合は透明度を下げる
        if (barData.isFutureDate) {
          barColor = barColor.withOpacity(0.4);
        }

        final paint = Paint()
          ..color = barColor
          ..style = PaintingStyle.fill;

        // 棒を描画（下から積み上げ、最上部のみ角丸）
        final isTopBar = categoryIndex == categoryCount - 1;
        if (isTopBar && barHeight > 2) {
          // 最上部の棒は上辺のみ角丸
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              Rect.fromLTWH(
                x,
                currentY - barHeight,
                barWidth,
                barHeight,
              ),
              topLeft: const Radius.circular(3),
              topRight: const Radius.circular(3),
            ),
            paint,
          );
        } else {
          canvas.drawRect(
            Rect.fromLTWH(
              x,
              currentY - barHeight,
              barWidth,
              barHeight,
            ),
            paint,
          );
        }

        currentY -= barHeight;
        categoryIndex++;
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

    for (int i = 0; i < data.xAxisLabels!.length; i++) {
      final xLabel = data.xAxisLabels![i];
      final daysDiff = xLabel.date.difference(data.fromDate).inDays;
      final x = leftMargin + (daysDiff / totalDays) * graphWidth;

      final textSpan = TextSpan(
        text: xLabel.label,
        style: PredictionGraphTextStyles.graphPriceLabel,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // 最初のラベルは左端揃え、それ以外は中央揃え
      double labelX;
      if (i == 0) {
        labelX = x; // 左端揃え
      } else {
        labelX = x - textPainter.width / 2; // 中央揃え
      }

      textPainter.paint(
        canvas,
        Offset(labelX, y + xAxisLabelVerticalOffset),
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
      int budget,
      double labelLeftPadding) {
    // usecaseで判定された表示フラグを使用
    if (!data.shouldShowIncomeLine || data.incomeLabelPosition == null) {
      return;
    }

    final y = topMargin + graphHeight - (income / maxValue) * graphHeight;

    // usecaseで計算されたラベル位置を使用（金額のみ）
    final labelPosition = data.incomeLabelPosition!;

    final textSpan = TextSpan(
      children: [
        const TextSpan(
          text: '収入 ',
          style: PredictionGraphTextStyles.graphLabel,
        ),
        TextSpan(
          text: labelPosition.label,
          style: PredictionGraphTextStyles.graphPriceLabel,
        ),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // 項目名のみのTextPainterを作成（重なった場合の描画用）
    const titleSpan = TextSpan(
      text: '収入 ',
      style: PredictionGraphTextStyles.graphLabel,
    );
    final titlePainter = TextPainter(
      text: titleSpan,
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();

    // ラベルを線の垂直中央に配置
    final labelY = y - textPainter.height / 2;
    final labelBottom = labelY + textPainter.height;

    // 予測ラインまたは支出ラインがラベル領域を通過するかチェック
    final labelOverlapsWithPredictionLine = _doesPredictionLineOverlapWithLabel(
      labelY: labelY,
      labelBottom: labelBottom,
      labelRightX: leftMargin + labelLeftPadding + textPainter.width + 8,
      leftMargin: leftMargin,
      topMargin: topMargin,
      graphWidth: graphWidth,
      graphHeight: graphHeight,
      maxValue: maxValue,
    );
    final labelOverlapsWithExpenseLine = _doesExpenseLineOverlapWithLabel(
      labelY: labelY,
      labelBottom: labelBottom,
      labelRightX: leftMargin + labelLeftPadding + textPainter.width + 8,
      leftMargin: leftMargin,
      topMargin: topMargin,
      graphWidth: graphWidth,
      graphHeight: graphHeight,
      maxValue: maxValue,
    );
    final labelOverlapsWithLine =
        labelOverlapsWithPredictionLine || labelOverlapsWithExpenseLine;

    // 描画処理
    if (labelOverlapsWithLine) {
      // 重なる場合：項目名のみ表示
      titlePainter.paint(canvas, Offset(leftMargin + labelLeftPadding, labelY));
    } else {
      // 重ならない場合：全表示
      textPainter.paint(canvas, Offset(leftMargin + labelLeftPadding, labelY));
    }

    // ラインをラベルの右端から描画
    final lineStartX = labelOverlapsWithLine
        ? leftMargin
        : leftMargin + labelLeftPadding + textPainter.width + 8;

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
      int income,
      double labelLeftPadding) {
    // usecaseで判定された表示フラグを使用
    if (!data.shouldShowBudgetLine || data.budgetLabelPosition == null) {
      return;
    }

    final y = topMargin + graphHeight - (budget / maxValue) * graphHeight;

    // usecaseで計算されたラベル位置を使用（金額のみ）
    final labelPosition = data.budgetLabelPosition!;

    final textSpan = TextSpan(
      children: [
        const TextSpan(
          text: '予算 ',
          style: PredictionGraphTextStyles.graphLabel,
        ),
        TextSpan(
          text: labelPosition.label,
          style: PredictionGraphTextStyles.graphPriceLabel,
        ),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // 項目名のみのTextPainterを作成（重なった場合の描画用）
    const titleSpan = TextSpan(
      text: '予算 ',
      style: PredictionGraphTextStyles.graphLabel,
    );
    final titlePainter = TextPainter(
      text: titleSpan,
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();

    // ラベルを線の垂直中央に配置
    final labelY = y - textPainter.height / 2;
    final labelBottom = labelY + textPainter.height;

    // 予測ラインまたは支出ラインがラベル領域を通過するかチェック
    final labelOverlapsWithPredictionLine = _doesPredictionLineOverlapWithLabel(
      labelY: labelY,
      labelBottom: labelBottom,
      labelRightX: leftMargin + labelLeftPadding + textPainter.width + 8,
      leftMargin: leftMargin,
      topMargin: topMargin,
      graphWidth: graphWidth,
      graphHeight: graphHeight,
      maxValue: maxValue,
    );
    final labelOverlapsWithExpenseLine = _doesExpenseLineOverlapWithLabel(
      labelY: labelY,
      labelBottom: labelBottom,
      labelRightX: leftMargin + labelLeftPadding + textPainter.width + 8,
      leftMargin: leftMargin,
      topMargin: topMargin,
      graphWidth: graphWidth,
      graphHeight: graphHeight,
      maxValue: maxValue,
    );
    final labelOverlapsWithLine =
        labelOverlapsWithPredictionLine || labelOverlapsWithExpenseLine;

    // 描画処理
    if (labelOverlapsWithLine) {
      // 重なる場合：項目名のみ表示
      titlePainter.paint(canvas, Offset(leftMargin + labelLeftPadding, labelY));
    } else {
      // 重ならない場合：全表示
      textPainter.paint(canvas, Offset(leftMargin + labelLeftPadding, labelY));
    }

    // ラインをラベルの右端から描画
    final lineStartX = labelOverlapsWithLine
        ? leftMargin
        : leftMargin + labelLeftPadding + textPainter.width + 8;
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
      int predictionPrice,
      bool shouldHideLineAndMoveLabel,
      double labelTopMargin) {
    final paint = Paint()
      ..color = MyColors.separater
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final totalDays = data.toDate.difference(data.fromDate).inDays + 1;

    final path = Path();
    for (int i = 0; i < predictionPoints.length; i++) {
      final point = predictionPoints[i];
      final daysDiff = point.date.difference(data.fromDate).inDays;
      // 最終日がX軸の右端に揃うように(totalDays-1)で除算
      final x = leftMargin +
          (totalDays > 1 ? (daysDiff / (totalDays - 1)) : 0.5) * graphWidth;
      final y =
          topMargin + graphHeight - (point.price / maxValue) * graphHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // ラベルを表示
    final textSpan = TextSpan(
      children: [
        const TextSpan(
          text: '予想支出 ',
          style: PredictionGraphTextStyles.graphLabel,
        ),
        TextSpan(
          text: data.predictionLabel,
          style: PredictionGraphTextStyles.graphPriceLabel,
        ),
      ],
    );

    // 点線を表示（条件によっては非表示）
    if (!shouldHideLineAndMoveLabel) {
      _drawDashedPath(canvas, path, paint);
    }

    // ラベルを予想支出専用領域（グラフ右上）に配置
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // 右上に配置（予想支出ラベル専用領域内）
    final labelX = leftMargin + graphWidth - 12 - textPainter.width;
    final labelY = labelTopMargin + 4;

    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  /// 支出ラインを描画
  void _drawExpenseLine(
    Canvas canvas,
    double leftMargin,
    double topMargin,
    double graphWidth,
    double graphHeight,
    double maxValue,
    List<dynamic> expensePoints, {
    required bool shouldShowExpenseLabel,
    required LabelPosition? expenseLabelPosition,
    required double labelLeftPadding,
  }) {
    final paint = Paint()
      ..color = MyColors.pink
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final totalDays = data.toDate.difference(data.fromDate).inDays + 1;

    final path = Path();
    for (int i = 0; i < expensePoints.length; i++) {
      final point = expensePoints[i];
      final daysDiff = point.date.difference(data.fromDate).inDays;
      // 最終日がX軸の右端に揃うように(totalDays-1)で除算
      final x = leftMargin +
          (totalDays > 1 ? (daysDiff / (totalDays - 1)) : 0.5) * graphWidth;
      final y =
          topMargin + graphHeight - (point.price / maxValue) * graphHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // ラベル表示処理（水平線→折れ線→ラベルの順で描画）
    if (shouldShowExpenseLabel && expenseLabelPosition != null) {
      // 最終点のY座標を計算
      final lastPoint = expensePoints.last;
      final lastY =
          topMargin + graphHeight - (lastPoint.price / maxValue) * graphHeight;

      final labelY = lastY + expenseLabelPosition.yOffset;

      // テキストスパンの作成
      final textSpan = TextSpan(
        children: [
          const TextSpan(
            text: '支出 ',
            style: PredictionGraphTextStyles.graphLabel,
          ),
          TextSpan(
            text: expenseLabelPosition.label,
            style: PredictionGraphTextStyles.graphPriceLabel,
          ),
        ],
      );

      final titleSpan = const TextSpan(
        text: '支出 ',
        style: PredictionGraphTextStyles.graphLabel,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final titlePainter = TextPainter(
        text: titleSpan,
        textDirection: TextDirection.ltr,
      );
      titlePainter.layout();

      final labelBottom = labelY + textPainter.height;
      final labelRightX = leftMargin + labelLeftPadding + textPainter.width + 8;

      // 収入・予算ラベルとの重なりをチェック
      bool overlapsWithIncome = false;
      bool overlapsWithBudget = false;
      const labelHeight = 16.0; // おおよそのラベル高さ

      // 収入ラベルとの重なりチェック
      if (data.shouldShowIncomeLine && data.incomeLabelPosition != null) {
        final incomeY = topMargin +
            graphHeight -
            ((data.income ?? 0) / maxValue) * graphHeight;
        final incomeLabelTop = incomeY - labelHeight / 2;
        final incomeLabelBottom = incomeY + labelHeight / 2;
        // 支出ラベルの範囲が収入ラベルの範囲と重なるかチェック
        if (labelY < incomeLabelBottom && labelBottom > incomeLabelTop) {
          overlapsWithIncome = true;
        }
      }

      // 予算ラベルとの重なりチェック
      if (data.shouldShowBudgetLine && data.budgetLabelPosition != null) {
        final budgetY = topMargin +
            graphHeight -
            ((data.budget ?? 0) / maxValue) * graphHeight;
        final budgetLabelTop = budgetY - labelHeight / 2;
        final budgetLabelBottom = budgetY + labelHeight / 2;
        // 支出ラベルの範囲が予算ラベルの範囲と重なるかチェック
        if (labelY < budgetLabelBottom && labelBottom > budgetLabelTop) {
          overlapsWithBudget = true;
        }
      }

      // 収入・予算ラベルと重なる場合は支出ラベル/ラインを非表示
      if (overlapsWithIncome || overlapsWithBudget) {
        // 折れ線グラフのみ描画
        canvas.drawPath(path, paint);
        return;
      }

      // 折れ線グラフとの重なりチェック
      final overlapsWithExpenseLine = _doesExpenseLineOverlapWithLabel(
        labelY: labelY,
        labelBottom: labelBottom,
        labelRightX: labelRightX,
        leftMargin: leftMargin,
        topMargin: topMargin,
        graphWidth: graphWidth,
        graphHeight: graphHeight,
        maxValue: maxValue,
      );

      // 折れ線と重なる場合も非表示
      if (overlapsWithExpenseLine) {
        canvas.drawPath(path, paint);
        return;
      }

      // 1. 水平線を先に描画（最背面）
      final lineY = lastY;
      final lineStartX = leftMargin + labelLeftPadding + textPainter.width + 8;

      final linePaint = Paint()
        ..color = MyColors.separater
        ..strokeWidth = 1.0;

      canvas.drawLine(
        Offset(lineStartX, lineY),
        Offset(leftMargin + graphWidth, lineY),
        linePaint,
      );

      // 2. 折れ線グラフを描画（水平線より手前）
      canvas.drawPath(path, paint);

      // 3. ラベルを描画（最前面）
      textPainter.paint(canvas, Offset(leftMargin + labelLeftPadding, labelY));
    } else {
      // ラベル非表示の場合は折れ線グラフのみ描画
      canvas.drawPath(path, paint);
    }
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

  /// 予測ラインがラベル領域と重なるかどうかをチェック
  bool _doesPredictionLineOverlapWithLabel({
    required double labelY,
    required double labelBottom,
    required double labelRightX,
    required double leftMargin,
    required double topMargin,
    required double graphWidth,
    required double graphHeight,
    required double maxValue,
  }) {
    // 予測ラインのデータがない場合は重なりなし
    if (data.predictionPoints == null || data.predictionPoints!.length < 2) {
      return false;
    }

    final totalDays = data.toDate.difference(data.fromDate).inDays + 1;

    // 予測ラインの各セグメントについて、ラベル領域との交差をチェック
    for (int i = 0; i < data.predictionPoints!.length - 1; i++) {
      final point1 = data.predictionPoints![i];
      final point2 = data.predictionPoints![i + 1];

      final daysDiff1 = point1.date.difference(data.fromDate).inDays;
      final daysDiff2 = point2.date.difference(data.fromDate).inDays;

      final x1 = leftMargin +
          (totalDays > 1 ? (daysDiff1 / (totalDays - 1)) : 0.5) * graphWidth;
      final y1 =
          topMargin + graphHeight - (point1.price / maxValue) * graphHeight;
      final x2 = leftMargin +
          (totalDays > 1 ? (daysDiff2 / (totalDays - 1)) : 0.5) * graphWidth;
      final y2 =
          topMargin + graphHeight - (point2.price / maxValue) * graphHeight;

      // ラベル領域（左端からlabelRightXまで）と交差するかチェック
      // ラベルの左端（leftMargin）からlabelRightXの範囲で
      // 予測ラインがラベルY範囲（labelY〜labelBottom）を通過するか
      if (x2 < leftMargin || x1 > labelRightX) {
        // このセグメントはラベルのX範囲外
        continue;
      }

      // ラベル範囲内でのYの最小・最大を計算
      // セグメントがラベル領域と重なる部分のX範囲を特定
      final clampedX1 = x1 < leftMargin ? leftMargin : x1;
      final clampedX2 = x2 > labelRightX ? labelRightX : x2;

      // ラベル領域内でのY値を線形補間で計算
      double yAtClampedX1, yAtClampedX2;
      if ((x2 - x1).abs() < 0.001) {
        // セグメントがほぼ垂直の場合
        yAtClampedX1 = y1;
        yAtClampedX2 = y2;
      } else {
        yAtClampedX1 = y1 + (y2 - y1) * ((clampedX1 - x1) / (x2 - x1));
        yAtClampedX2 = y1 + (y2 - y1) * ((clampedX2 - x1) / (x2 - x1));
      }

      final segmentMinY =
          yAtClampedX1 < yAtClampedX2 ? yAtClampedX1 : yAtClampedX2;
      final segmentMaxY =
          yAtClampedX1 > yAtClampedX2 ? yAtClampedX1 : yAtClampedX2;

      // Y範囲が重なるかチェック（マージンを追加）
      const margin = 4.0; // ラベルとラインの間のマージン
      if (segmentMaxY + margin >= labelY &&
          segmentMinY - margin <= labelBottom) {
        return true;
      }
    }

    return false;
  }

  /// 支出ラインがラベル領域と重なるかどうかをチェック
  bool _doesExpenseLineOverlapWithLabel({
    required double labelY,
    required double labelBottom,
    required double labelRightX,
    required double leftMargin,
    required double topMargin,
    required double graphWidth,
    required double graphHeight,
    required double maxValue,
  }) {
    // 支出ラインのデータがない場合は重なりなし
    if (data.expensePoints == null || data.expensePoints!.length < 2) {
      return false;
    }

    final totalDays = data.toDate.difference(data.fromDate).inDays + 1;

    // 支出ラインの各セグメントについて、ラベル領域との交差をチェック
    for (int i = 0; i < data.expensePoints!.length - 1; i++) {
      final point1 = data.expensePoints![i];
      final point2 = data.expensePoints![i + 1];

      final daysDiff1 = point1.date.difference(data.fromDate).inDays;
      final daysDiff2 = point2.date.difference(data.fromDate).inDays;

      final x1 = leftMargin +
          (totalDays > 1 ? (daysDiff1 / (totalDays - 1)) : 0.5) * graphWidth;
      final y1 =
          topMargin + graphHeight - (point1.price / maxValue) * graphHeight;
      final x2 = leftMargin +
          (totalDays > 1 ? (daysDiff2 / (totalDays - 1)) : 0.5) * graphWidth;
      final y2 =
          topMargin + graphHeight - (point2.price / maxValue) * graphHeight;

      // ラベル領域（左端からlabelRightXまで）と交差するかチェック
      if (x2 < leftMargin || x1 > labelRightX) {
        // このセグメントはラベルのX範囲外
        continue;
      }

      // ラベル範囲内でのYの最小・最大を計算
      // セグメントがラベル領域と重なる部分のX範囲を特定
      final clampedX1 = x1 < leftMargin ? leftMargin : x1;
      final clampedX2 = x2 > labelRightX ? labelRightX : x2;

      // ラベル領域内でのY値を線形補間で計算
      double yAtClampedX1, yAtClampedX2;
      if ((x2 - x1).abs() < 0.001) {
        // セグメントがほぼ垂直の場合
        yAtClampedX1 = y1;
        yAtClampedX2 = y2;
      } else {
        yAtClampedX1 = y1 + (y2 - y1) * ((clampedX1 - x1) / (x2 - x1));
        yAtClampedX2 = y1 + (y2 - y1) * ((clampedX2 - x1) / (x2 - x1));
      }

      final segmentMinY =
          yAtClampedX1 < yAtClampedX2 ? yAtClampedX1 : yAtClampedX2;
      final segmentMaxY =
          yAtClampedX1 > yAtClampedX2 ? yAtClampedX1 : yAtClampedX2;

      // Y範囲が重なるかチェック（マージンを追加）
      const margin = 4.0; // ラベルとラインの間のマージン
      if (segmentMaxY + margin >= labelY &&
          segmentMinY - margin <= labelBottom) {
        return true;
      }
    }

    return false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
