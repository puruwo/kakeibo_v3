import 'package:flutter/material.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/daily_bar_data.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/prediction_graph_value.dart';
import 'package:kakeibo/view/daily_expense_summary_page/daily_expense_summary_page.dart';
import 'package:kakeibo/view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_painter.dart';
import 'package:kakeibo/view/monthly_page/prediction_graph_area/prediction_graph_parts/prediction_graph_tooltip.dart';

class PredictionGraphWidget extends StatefulWidget {
  const PredictionGraphWidget({super.key, required this.data});

  final PredictionGraphValue data;

  @override
  State<PredictionGraphWidget> createState() => _PredictionGraphWidgetState();
}

class _PredictionGraphWidgetState extends State<PredictionGraphWidget> {
  DateTime? _selectedDate;
  Offset? _tapPosition;
  Size _widgetSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _widgetSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque, // タップを確実に検知
          onTapDown: (details) {
            // ツールチップ表示中に外をタップしたら閉じる
            if (_selectedDate != null) {
              // タップ位置がツールチップ領域外かチェック
              if (!_isPositionInsideTooltip(details.localPosition)) {
                setState(() {
                  _selectedDate = null;
                  _tapPosition = null;
                });
                return;
              }
            }
            _handleTap(details.localPosition, context);
          },
          onTapUp: (_) {},
          // スライドで日付切り替え
          onPanUpdate: (details) {
            _handleTap(details.localPosition, context);
          },
          onPanEnd: (_) {},
          child: Stack(
            children: [
              CustomPaint(
                painter: PredictionGraphPainter(data: widget.data),
                child: Container(),
              ),
              if (_selectedDate != null && _tapPosition != null)
                _buildTooltip(),
            ],
          ),
        );
      },
    );
  }

  /// タップ位置がツールチップ領域内かチェック
  bool _isPositionInsideTooltip(Offset position) {
    if (_tapPosition == null) return false;

    const tooltipWidth = 200.0;
    const tooltipHeight = 150.0; // おおよそのツールチップ高さ
    const tooltipTop = 8.0;

    double tooltipX = _tapPosition!.dx - tooltipWidth / 2;
    if (tooltipX < 8) tooltipX = 8;
    if (tooltipX + tooltipWidth > _widgetSize.width - 8) {
      tooltipX = _widgetSize.width - tooltipWidth - 8;
    }

    return position.dx >= tooltipX &&
        position.dx <= tooltipX + tooltipWidth &&
        position.dy >= tooltipTop &&
        position.dy <= tooltipTop + tooltipHeight;
  }

  void _handleTap(Offset position, BuildContext context) {
    final size = context.size;
    if (size == null) return;

    // グラフエリアのマージン（PredictionGraphPainterと同じ値）
    const double leftMargin = 6;
    const double rightMargin = 12;
    const double graphLeftOffset = 40.0;

    final totalWidth = size.width - leftMargin - rightMargin;
    final graphWidth = totalWidth - graphLeftOffset;
    const graphStartX = leftMargin + graphLeftOffset;

    // グラフエリア内かチェック
    if (position.dx < graphStartX || position.dx > graphStartX + graphWidth) {
      setState(() {
        _selectedDate = null;
        _tapPosition = null;
      });
      return;
    }

    // タップ位置から日付を算出
    final totalDays =
        widget.data.toDate.difference(widget.data.fromDate).inDays + 1;
    final relativeX = position.dx - graphStartX;
    final dayIndex =
        (relativeX / graphWidth * totalDays).floor().clamp(0, totalDays - 1);
    final selectedDate = widget.data.fromDate.add(Duration(days: dayIndex));

    // その日の支出が0円かチェック（0円の日はツールチップ表示しない）
    final dailyBarData = widget.data.dailyBarDataList?.firstWhere(
      (d) =>
          d.date.year == selectedDate.year &&
          d.date.month == selectedDate.month &&
          d.date.day == selectedDate.day,
      orElse: () => DailyBarData(
        date: selectedDate,
        isFutureDate: false,
        categoryExpenses: [],
        normalizedTotalHeight: 0,
      ),
    );

    // カテゴリー別支出が空の場合はツールチップを表示しない
    if (dailyBarData == null || dailyBarData.categoryExpenses.isEmpty) {
      setState(() {
        _selectedDate = null;
        _tapPosition = null;
      });
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
      _tapPosition = position;
    });
  }

  Widget _buildTooltip() {
    final selectedDate = _selectedDate!;
    final tapPosition = _tapPosition!;

    // 累計支出を計算
    int cumulativeExpense = 0;
    if (widget.data.expensePoints != null) {
      for (final point in widget.data.expensePoints!) {
        if (!point.date.isAfter(selectedDate)) {
          cumulativeExpense = point.price;
        }
      }
    }

    // その日のカテゴリー別支出を取得
    final dailyBarData = widget.data.dailyBarDataList?.firstWhere(
      (d) =>
          d.date.year == selectedDate.year &&
          d.date.month == selectedDate.month &&
          d.date.day == selectedDate.day,
      orElse: () => DailyBarData(
        date: selectedDate,
        isFutureDate: false,
        categoryExpenses: [],
        normalizedTotalHeight: 0,
      ),
    );

    // ツールチップの位置を計算（画面外にはみ出さないように）
    const tooltipWidth = 200.0;
    double tooltipX = tapPosition.dx - tooltipWidth / 2;
    // 左端見切れ防止
    if (tooltipX < 8) tooltipX = 8;
    // 右端見切れ防止（ウィジェット内での位置）
    if (tooltipX + tooltipWidth > _widgetSize.width - 8) {
      tooltipX = _widgetSize.width - tooltipWidth - 8;
    }

    return Positioned(
      left: tooltipX,
      top: 8,
      child: GraphTooltip(
        date: selectedDate,
        cumulativeExpense: cumulativeExpense,
        totalFixedCostExpense: widget.data.totalFixedCostExpense ?? 0,
        categoryExpenses: dailyBarData?.categoryExpenses ?? [],
        onTapTooltip: () {
          // ツールチップを閉じてからナビゲーション
          setState(() {
            _selectedDate = null;
            _tapPosition = null;
          });
          Navigator.of(context).push(
            DailyExpenseSummaryPage.route(selectedDate),
          );
        },
      ),
    );
  }
}
