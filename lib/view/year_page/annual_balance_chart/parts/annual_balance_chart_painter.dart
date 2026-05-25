import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/styles/graph_text_styles.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/annual_balance_chart_value.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/monthly_balance_value/monthly_balance_value.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/y_axis_scale.dart';

/// 生活収支グラフのレイアウト定数。
/// Widget 側のツールチップ位置計算にも使う。
class AnnualBalanceChartLayout {
  static const double scrollAreaWidth = 700.0;
  static const double horizontalPadding = 8.0;

  /// キャンバス全体の幅（= Painter の Size.width）
  static const double drawingAreaWidth =
      scrollAreaWidth - horizontalPadding * 2;

  /// Y軸ラベル（「N万」「収支」）に割り当てる左側の幅
  /// 「250万」など 4 文字ラベルが折り返さないサイズを確保する
  static const double reservedSize = 40.0;

  /// 実際にグラフが描画される幅（Y軸ラベル分を除く）
  static const double chartAreaWidth = drawingAreaWidth - reservedSize;

  /// 上段（折れ線）の高さ
  static const double lineAreaHeight = 150.0;

  /// 中段（棒）の高さ
  static const double barAreaHeight = 80.0;

  /// 下段（月ラベル）の高さ
  static const double monthLabelAreaHeight = 20.0;

  /// キャンバス全体の高さ
  static const double totalHeight =
      lineAreaHeight + barAreaHeight + monthLabelAreaHeight;

  /// 中段バーエリアの中央線の Y 座標
  static const double barCenterLineY = lineAreaHeight + barAreaHeight / 2;

  /// 棒の最大の高さ（金額テキスト表示分 16px を確保）
  static const double maxBarHeight = barAreaHeight / 2 - 16.0;

  /// 棒の太さ
  static const double barWidth = 25.0;

  // 端セルのマージン比率（現行踏襲）
  static const double leftCellMargin = 0.3;
  static const double rightCellMargin = 0.3;

  /// 通常セル（2〜11月）の幅
  static const double normalCellWidth =
      chartAreaWidth / (11 + leftCellMargin + rightCellMargin);

  /// 左端（1月）セルの幅
  static const double firstCellWidth = normalCellWidth * (0.5 + leftCellMargin);

  /// 右端（12月）セルの幅
  static const double endCellWidth = normalCellWidth * (0.5 + rightCellMargin);

  /// セル i の X 中心座標（キャンバス左端からの絶対座標）
  static double cellCenterX(int i) {
    if (i <= 0) {
      return reservedSize + firstCellWidth / 2;
    }
    if (i >= 11) {
      return reservedSize + firstCellWidth + normalCellWidth * 10 +
          endCellWidth / 2;
    }
    return reservedSize + firstCellWidth + normalCellWidth * (i - 0.5);
  }

  /// X 座標から月 index (0-11) を逆算する。範囲外は null。
  /// monthLabelTopY を指定すると、そのYより下（＝月ラベル領域）への
  /// タップは無反応扱いになる。
  static int? hitTestCell(Offset position, {double? monthLabelTopY}) {
    if (position.dx < reservedSize) return null;
    final bottomY = monthLabelTopY ?? (lineAreaHeight + barAreaHeight);
    if (position.dy < 0 || position.dy > bottomY) {
      // 月ラベル領域は触っても反応させない（任意。タップは折れ線 + バー領域のみ）
      return null;
    }

    double cursor = reservedSize;
    // 左端セル
    if (position.dx < cursor + firstCellWidth) return 0;
    cursor += firstCellWidth;
    // 中央セル（1..10）
    for (int i = 1; i <= 10; i++) {
      if (position.dx < cursor + normalCellWidth) return i;
      cursor += normalCellWidth;
    }
    // 右端セル
    if (position.dx < cursor + endCellWidth) return 11;
    return null;
  }
}

/// データ内容に応じて動的に変わるバー領域の縦サイズ。
/// 全月黒字なら下半分、全月赤字なら上半分を詰めて月ラベルを上に寄せる。
class AnnualBalanceChartDimensions {
  const AnnualBalanceChartDimensions({
    required this.barAreaTopHeight,
    required this.barAreaBottomHeight,
  });

  final double barAreaTopHeight;
  final double barAreaBottomHeight;

  double get barCenterLineY =>
      AnnualBalanceChartLayout.lineAreaHeight + barAreaTopHeight;
  double get monthLabelTop => barCenterLineY + barAreaBottomHeight;
  double get totalHeight =>
      monthLabelTop + AnnualBalanceChartLayout.monthLabelAreaHeight;

  /// 未来月を除いた収支から黒字/赤字の有無を判定して寸法を算出する。
  factory AnnualBalanceChartDimensions.from(
    List<MonthlyBalanceValue> values,
  ) {
    bool hasSurplus = false;
    bool hasDeficit = false;
    for (final v in values) {
      if (v.monthlyBalanceType == MonthlyBalanceType.future) continue;
      if (v.savings > 0) hasSurplus = true;
      if (v.savings < 0) hasDeficit = true;
    }
    // 全0の場合は上半分を残して最低限のバー領域を確保する
    final keepTop = hasSurplus || !hasDeficit;
    return AnnualBalanceChartDimensions(
      barAreaTopHeight:
          keepTop ? AnnualBalanceChartLayout.barAreaHeight / 2 : 0.0,
      barAreaBottomHeight:
          hasDeficit ? AnnualBalanceChartLayout.barAreaHeight / 2 : 0.0,
    );
  }
}

/// 生活収支グラフ本体（折れ線 / 棒 / 月ラベル）を 1 枚の Canvas に描く CustomPainter。
class AnnualBalanceChartPainter extends CustomPainter {
  AnnualBalanceChartPainter({
    required this.value,
    required this.selectedMonthIndex,
    required this.dimensions,
  });

  final AnnualBalanceChartValue value;
  final int? selectedMonthIndex;
  final AnnualBalanceChartDimensions dimensions;

  static final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  void paint(Canvas canvas, Size size) {
    _paintLineArea(canvas);
    _paintBarArea(canvas);
    _paintMonthLabels(canvas);
  }

  // ───────────────────────────────────────
  // 上段: 折れ線
  // ───────────────────────────────────────
  void _paintLineArea(Canvas canvas) {
    final scale = value.yAxisScale;

    // グリッド線（Y軸ラベルはオーバーレイ painter 側で描画）
    final gridPaint = Paint()
      ..color = MyColors.separater
      ..strokeWidth = 1.0;
    for (final gridValue in scale.gridValues) {
      final y = _lineY(gridValue);
      if (y < 0 || y > AnnualBalanceChartLayout.lineAreaHeight) continue;

      canvas.drawLine(
        Offset(AnnualBalanceChartLayout.reservedSize, y),
        Offset(AnnualBalanceChartLayout.drawingAreaWidth, y),
        gridPaint,
      );
    }

    // 収入ポリライン（緑）
    _drawPolyline(
      canvas,
      color: MyColors.incomeEmerald,
      getValue: (v) => v.monthlyIncome.toDouble(),
    );

    // 支出ポリライン（ピンク）
    _drawPolyline(
      canvas,
      color: MyColors.pink,
      getValue: (v) => v.monthlyExpense.toDouble(),
    );
  }

  /// 収入または支出の折れ線＋ドットを描画
  void _drawPolyline(
    Canvas canvas, {
    required Color color,
    required double Function(MonthlyBalanceValue) getValue,
  }) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path? path;
    for (int i = 0; i < value.monthlyBalanceValues.length; i++) {
      final mv = value.monthlyBalanceValues[i];
      if (mv.monthlyBalanceType == MonthlyBalanceType.future) {
        // 未来月で一旦途切れる
        // ここまでに構築した path を drawPath でフラッシュしてからリセットする。
        // フラッシュせずに null 上書きすると、ループ末尾の drawPath 判定で弾かれ
        // 折れ線が一切描画されなくなる（過去月＋現在月までしかデータが無いケース）。
        if (path != null) {
          canvas.drawPath(path, linePaint);
        }
        path = null;
        continue;
      }
      final x = AnnualBalanceChartLayout.cellCenterX(i);
      final y = _lineY(getValue(mv));
      if (path == null) {
        path = Path()..moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
    }
    if (path != null) {
      canvas.drawPath(path, linePaint);
    }
  }

  /// 金額 → 上段の Y 座標（スケール反転）
  double _lineY(double priceValue) {
    final scale = value.yAxisScale;
    final range = scale.maxValue - scale.minValue;
    if (range <= 0) {
      return AnnualBalanceChartLayout.lineAreaHeight;
    }
    final ratio = (priceValue - scale.minValue) / range;
    return AnnualBalanceChartLayout.lineAreaHeight -
        ratio * AnnualBalanceChartLayout.lineAreaHeight;
  }

  // ───────────────────────────────────────
  // 中段: 棒
  // ───────────────────────────────────────
  void _paintBarArea(Canvas canvas) {
    // 「収支」ラベルはオーバーレイ painter 側で描画

    // 中央線
    final centerLinePaint = Paint()
      ..color = MyColors.separater
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(
        AnnualBalanceChartLayout.reservedSize,
        dimensions.barCenterLineY,
      ),
      Offset(
        AnnualBalanceChartLayout.drawingAreaWidth,
        dimensions.barCenterLineY,
      ),
      centerLinePaint,
    );

    // 最大の |savings|（未来月を除く）
    final diffs = <double>[];
    for (final mv in value.monthlyBalanceValues) {
      if (mv.monthlyBalanceType == MonthlyBalanceType.future) continue;
      diffs.add(mv.savings.abs().toDouble());
    }
    if (diffs.isEmpty) return;
    final maxDifference = diffs.reduce(max);
    if (maxDifference == 0) return;

    for (int i = 0; i < value.monthlyBalanceValues.length; i++) {
      final mv = value.monthlyBalanceValues[i];
      if (mv.monthlyBalanceType == MonthlyBalanceType.future) continue;

      final diff = mv.savings.toDouble();
      final barHeight =
          (diff.abs() / maxDifference) * AnnualBalanceChartLayout.maxBarHeight;
      final isSurplus = diff >= 0;
      final cx = AnnualBalanceChartLayout.cellCenterX(i);

      // バー
      final barPaint = Paint()
        ..color = isSurplus ? MyColors.incomeEmerald : MyColors.pink
        ..style = PaintingStyle.fill;
      final barRect = Rect.fromLTWH(
        cx - AnnualBalanceChartLayout.barWidth / 2,
        isSurplus
            ? dimensions.barCenterLineY - barHeight
            : dimensions.barCenterLineY,
        AnnualBalanceChartLayout.barWidth,
        barHeight,
      );
      canvas.drawRect(barRect, barPaint);

      // 金額ラベル（3桁カンマ）
      final amountText = _numberFormat.format(diff.abs().toInt());
      final cellWidth = _cellWidth(i);
      final amountTp = TextPainter(
        text: TextSpan(text: amountText, style: GraphTextStyles.graphMiniLabel),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: cellWidth);

      // 黒字: バーの上に / 赤字: バーの下に
      final textY = isSurplus
          ? dimensions.barCenterLineY - barHeight -
              amountTp.height - 2
          : dimensions.barCenterLineY + barHeight + 2;
      amountTp.paint(
        canvas,
        Offset(cx - amountTp.width / 2, textY),
      );
    }
  }

  double _cellWidth(int i) {
    if (i == 0) return AnnualBalanceChartLayout.firstCellWidth;
    if (i == 11) return AnnualBalanceChartLayout.endCellWidth;
    return AnnualBalanceChartLayout.normalCellWidth;
  }

  // ───────────────────────────────────────
  // 下段: 月ラベル
  // ───────────────────────────────────────
  void _paintMonthLabels(Canvas canvas) {
    final top = dimensions.monthLabelTop;
    for (int i = 0; i < value.monthlyBalanceValues.length; i++) {
      final mv = value.monthlyBalanceValues[i];
      final isCurrentMonth = mv.month == value.currentMonth;
      final style = isCurrentMonth
          ? GraphTextStyles.graphMiniLabel.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
          : GraphTextStyles.graphMiniLabel;
      final tp = TextPainter(
        text: TextSpan(text: '${mv.month}月', style: style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _cellWidth(i));
      final cx = AnnualBalanceChartLayout.cellCenterX(i);
      tp.paint(
        canvas,
        Offset(
          cx - tp.width / 2,
          top + (AnnualBalanceChartLayout.monthLabelAreaHeight - tp.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnnualBalanceChartPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.selectedMonthIndex != selectedMonthIndex ||
        oldDelegate.dimensions.barCenterLineY != dimensions.barCenterLineY ||
        oldDelegate.dimensions.monthLabelTop != dimensions.monthLabelTop;
  }
}

/// スクロールで隠れない固定オーバーレイ用の Painter。
/// Y軸の「N万」ラベルと、中段バーエリアの「収支」ラベルのみを描画する。
/// 背景は透過（塗らない）ため、裏のグリッド線・折れ線が透けて見える。
class AnnualBalanceAxisLabelsPainter extends CustomPainter {
  AnnualBalanceAxisLabelsPainter({
    required this.scale,
    required this.dimensions,
  });

  final YAxisScale scale;
  final AnnualBalanceChartDimensions dimensions;

  @override
  void paint(Canvas canvas, Size size) {
    // Y軸「N万」ラベル（上段折れ線エリアの高さ基準）
    for (final gridValue in scale.gridValues) {
      final y = _lineY(gridValue);
      if (y < 0 || y > AnnualBalanceChartLayout.lineAreaHeight) continue;
      final label = '${(gridValue / 10000).truncate()}万';
      final tp = TextPainter(
        text: TextSpan(text: label, style: GraphTextStyles.graphMiniLabel),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      tp.paint(
        canvas,
        Offset(size.width - tp.width - 2, y - tp.height / 2),
      );
    }

    // 「収支」ラベル
    final barLabelTp = TextPainter(
      text: TextSpan(text: '収支', style: GraphTextStyles.graphMiniLabel),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    barLabelTp.paint(
      canvas,
      Offset(
        size.width - barLabelTp.width - 2,
        dimensions.barCenterLineY - barLabelTp.height / 2,
      ),
    );
  }

  double _lineY(double priceValue) {
    final range = scale.maxValue - scale.minValue;
    if (range <= 0) return AnnualBalanceChartLayout.lineAreaHeight;
    final ratio = (priceValue - scale.minValue) / range;
    return AnnualBalanceChartLayout.lineAreaHeight -
        ratio * AnnualBalanceChartLayout.lineAreaHeight;
  }

  @override
  bool shouldRepaint(covariant AnnualBalanceAxisLabelsPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.dimensions.barCenterLineY != dimensions.barCenterLineY;
  }
}
