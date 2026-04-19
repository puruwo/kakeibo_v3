import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/graph_text_styles.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/monthly_balance_value/monthly_balance_value.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_annual_balance_chart_value_provider.dart';

class AnnualBalanceChart extends ConsumerStatefulWidget {
  const AnnualBalanceChart({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnnualBalanceChartState();
}

class _AnnualBalanceChartState extends ConsumerState<AnnualBalanceChart> {
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0, // 初期スクロール位置を設定
    keepScrollOffset: false, // スクロール位置を保持する
  );

  // メモリ線の本数を抑えるための候補刻み（1/2/5系列）
  static const List<double> _verticalIntervalCandidates = [
    10000.0,
    20000.0,
    50000.0,
    100000.0,
    200000.0,
    500000.0,
    1000000.0,
    2000000.0,
    5000000.0,
    10000000.0,
  ];

  // メモリ線の最大本数の目安
  static const int _targetGridCount = 5;

  // 金額表示フォーマッタ（3桁カンマ区切り）
  static final NumberFormat _amountFormatter = NumberFormat('#,###');

  /// 折れ線グラフのメモリ線が多くなりすぎないよう、データ範囲に応じて間隔を決める
  double _calcVerticalInterval(double maxMinDifference) {
    for (final candidate in _verticalIntervalCandidates) {
      if (maxMinDifference / candidate <= _targetGridCount) {
        return candidate;
      }
    }
    return _verticalIntervalCandidates.last;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(resolvedAnnualBalanceChartValueProvider)
        .when(
          data: (chartData) {
            // チャートのデータがない場合の処理
            if (chartData.hasNoRecord) {
              return CardContainer(
                width: double.infinity,
                height: 30,
                child: Center(
                  child: Text('まだ記録がありません', style: AppTextStyles.errorMessage),
                ),
              );
            }

            // 収入のリストを作成
            // 未来の収入はリストに格納しない
            final List<double> income = [
              for (int i = 0; i < chartData.monthlyBalanceValues.length; i++)
                if (chartData.monthlyBalanceValues[i].monthlyBalanceType !=
                    MonthlyBalanceType.future)
                  chartData.monthlyBalanceValues[i].monthlyIncome.toDouble(),
            ];

            // 支出のリストを作成
            // 未来の支出はリストに格納しない
            final List<double> expense = [
              for (int i = 0; i < chartData.monthlyBalanceValues.length; i++)
                if (chartData.monthlyBalanceValues[i].monthlyBalanceType !=
                    MonthlyBalanceType.future)
                  chartData.monthlyBalanceValues[i].monthlyExpense.toDouble(),
            ];

            // エリアの幅
            const scrollAreaWidth = 700.0;

            const horizontalPadding = 8.0;

            // 描画可能エリアの幅
            const double drawingAreaWidth =
                scrollAreaWidth - horizontalPadding * 2;

            // グラフのメモリ表示スペース
            const reservedSize = 24.0;

            // チャートエリアの幅
            const chartAreaWidth = drawingAreaWidth - reservedSize;

            // 差分を計算
            final differences = [
              for (int i = 0; i < chartData.monthlyBalanceValues.length; i++)
                if (chartData.monthlyBalanceValues[i].monthlyBalanceType !=
                    MonthlyBalanceType.future)
                  chartData.monthlyBalanceValues[i].savings.toDouble(),
            ];

            // 差の絶対値の最大値を計算
            final maxDifference = differences.map((e) => e.abs()).reduce(max);
            // 0除算を避けるための基準値
            final barScaleBase = maxDifference == 0 ? 1.0 : maxDifference;

            // プラス・マイナスの有無
            final hasPositive = differences.any((d) => d > 0);
            final hasNegative = differences.any((d) => d < 0);

            // 棒グラフのラベル用スペース（バー上または下の金額表示分）
            const barLabelSpace = 14.0;
            // 片側バーの最大描画高さ
            const maxBarHeight = 24.0;

            // プラス・マイナス各セクションの高さ（ラベル + バー）
            final positiveSectionHeight = hasPositive
                ? (barLabelSpace + maxBarHeight)
                : 0.0;
            final negativeSectionHeight = hasNegative
                ? (maxBarHeight + barLabelSpace)
                : 0.0;

            // 棒グラフエリア全体の高さ（セクションが全て 0 の場合の保険）
            final barGraphHeight = positiveSectionHeight + negativeSectionHeight == 0
                ? barLabelSpace + maxBarHeight
                : positiveSectionHeight + negativeSectionHeight;

            // 基準線の位置（棒グラフエリア上端からの距離）
            // プラスセクションがない場合は 0（エリア最上部）が基準線になる
            final barCenterLinePosition = positiveSectionHeight;

            // グラフの最小値と最大値を計算
            final minY = (income + expense).reduce(min);
            final maxY = (income + expense).reduce(max);
            final maxMinDifference = (maxY - minY).abs(); // 最大値と最小値の差を計算

            // メモリ線の本数を制御するための間隔
            final verticalInterval = _calcVerticalInterval(maxMinDifference);

            // 棒グラフのバーの幅
            const barWidth = 25.0;

            // チャートエリアのマージン
            final topMargin =
                (verticalInterval / 3) * maxMinDifference / 100000.0;
            final bottomMargin =
                (verticalInterval / 2) * maxMinDifference / 100000.0;
            const lewtMargin = 0.3;
            const rightMargin = 0.3;

            // 一つのセルの幅を計算
            const normalCellWidth =
                chartAreaWidth / (11 + lewtMargin + rightMargin);
            const firstCellWidth = normalCellWidth * (0.5 + lewtMargin);
            const endCellWidth = normalCellWidth * (0.5 + rightMargin);

            // 初期スクロール位置を設定するために、ビルド後にコールバックを追加
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (chartData.monthIndex <= 3) {
                _scrollController.animateTo(
                  _scrollController.position.minScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (4 <= chartData.monthIndex &&
                  chartData.monthIndex <= 7) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent / 2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (8 <= chartData.monthIndex &&
                  chartData.monthIndex <= 11) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _scrollController.animateTo(
                  _scrollController.position.minScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            });

            return CardContainer(
              width: scrollAreaWidth,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 折れ線＋バーエリア
                      SizedBox(
                        width: drawingAreaWidth,
                        height: 150,
                        child: Stack(
                          children: [
                            LineChart(
                              LineChartData(
                                borderData: FlBorderData(
                                  show: false,
                                ), //グラフの枠線を非表示
                                minX: 0 - lewtMargin,
                                maxX: 11 + rightMargin,
                                minY: minY - bottomMargin,
                                maxY: maxY + topMargin,

                                // タッチした時のポップアップを消去
                                lineTouchData: const LineTouchData(
                                  enabled: false,
                                ),

                                // グリッド
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  drawHorizontalLine: true,
                                  horizontalInterval: verticalInterval,
                                  getDrawingHorizontalLine: (value) {
                                    // 最大値、最小値の一つ外のグリッドから内側を表示
                                    if (value >= minY - verticalInterval &&
                                        value <= maxY + verticalInterval &&
                                        value >= 0) {
                                      return const FlLine(
                                        color: MyColors.separater,
                                        strokeWidth: 1,
                                      );
                                    }
                                    // それ以外は表示
                                    return const FlLine(
                                      color: MyColors.transparent,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),

                                // 左側のタイトルプロパティ
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: verticalInterval,
                                      reservedSize: reservedSize,
                                      getTitlesWidget: (value, meta) {
                                        // メモリの値が最大値か最小値と同じ場合は非表示
                                        if (value == meta.max ||
                                            value == meta.min) {
                                          return const SizedBox.shrink();
                                        }
                                        // 最大値と最小値の幅より外は非表示
                                        if (value < minY - verticalInterval ||
                                            value > maxY + verticalInterval) {
                                          return const SizedBox.shrink();
                                        }
                                        // マイナスのときは非表示
                                        if (value < 0) {
                                          return const SizedBox.shrink();
                                        }
                                        // それ以外の時は二桁に丸めて表示
                                        return FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${(value / 10000).truncate()}万',
                                            style:
                                                GraphTextStyles.graphMiniLabel,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // 下側のタイトルは非表示
                                  bottomTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  // 上側のタイトルは非表示
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  // 右側のタイトルは非表示
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),

                                // 線グラフ
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      // 未来の収支は表示しない
                                      for (
                                        int i = 0;
                                        i <
                                            chartData
                                                .monthlyBalanceValues
                                                .length;
                                        i++
                                      )
                                        if (chartData
                                                .monthlyBalanceValues[i]
                                                .monthlyBalanceType !=
                                            MonthlyBalanceType.future)
                                          FlSpot(
                                            i.toDouble(),
                                            chartData
                                                .monthlyBalanceValues[i]
                                                .monthlyIncome
                                                .toDouble(),
                                          ),
                                    ],
                                    isCurved: false,
                                    color: MyColors.incomeEmerald,
                                    barWidth: 2,
                                    dotData: const FlDotData(show: true),
                                  ),
                                  LineChartBarData(
                                    spots: [
                                      for (
                                        int i = 0;
                                        i <
                                            chartData
                                                .monthlyBalanceValues
                                                .length;
                                        i++
                                      )
                                        if (chartData
                                                .monthlyBalanceValues[i]
                                                .monthlyBalanceType !=
                                            MonthlyBalanceType.future)
                                          FlSpot(
                                            i.toDouble(),
                                            chartData
                                                .monthlyBalanceValues[i]
                                                .monthlyExpense
                                                .toDouble(),
                                          ),
                                    ],
                                    isCurved: false,
                                    color: MyColors.pink,
                                    barWidth: 2,
                                    dotData: const FlDotData(show: true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 棒グラフエリア
                      SizedBox(
                        width: drawingAreaWidth,
                        height: barGraphHeight,
                        child: Stack(
                          children: [
                            // 収支ラベル
                            Positioned(
                              left: 0,
                              top: barCenterLinePosition - 7,
                              child: SizedBox(
                                width: reservedSize,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '収支',
                                    style: GraphTextStyles.graphMiniLabel,
                                  ),
                                ),
                              ),
                            ),
                            // 基準線: 収支±0 の位置
                            Positioned(
                              top: barCenterLinePosition,
                              left: reservedSize,
                              right: 0,
                              child: Container(
                                height: 1,
                                color: MyColors.separater,
                              ),
                            ),
                            // 棒グラフと金額ラベル
                            Padding(
                              padding: const EdgeInsets.only(
                                left: reservedSize,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: List.generate(differences.length, (
                                  i,
                                ) {
                                  final diff = differences[i];
                                  final barHeight =
                                      (diff.abs() / barScaleBase) *
                                      maxBarHeight;
                                  final cellWidth = i == 0
                                      ? firstCellWidth
                                      : i == 11
                                      ? endCellWidth
                                      : normalCellWidth;
                                  // セル内での棒の左オフセット
                                  // i == 0 だけセル幅が狭いため、通常セルと同じ絶対位置に揃える
                                  final barLeft = i == 0
                                      ? firstCellWidth -
                                            (normalCellWidth - barWidth) / 2 -
                                            barWidth
                                      : (normalCellWidth - barWidth) / 2;

                                  return SizedBox(
                                    width: cellWidth,
                                    height: barGraphHeight,
                                    child: Stack(
                                      children: [
                                        // 棒
                                        Positioned(
                                          left: barLeft,
                                          top: diff >= 0
                                              ? barCenterLinePosition -
                                                    barHeight
                                              : barCenterLinePosition,
                                          child: Container(
                                            width: barWidth,
                                            height: barHeight,
                                            color: diff >= 0
                                                ? MyColors.incomeEmerald
                                                : MyColors.pink,
                                          ),
                                        ),
                                        // 金額ラベル
                                        Positioned(
                                          left: 0,
                                          width: cellWidth,
                                          height: barLabelSpace,
                                          top: diff >= 0
                                              ? barCenterLinePosition -
                                                    barHeight -
                                                    barLabelSpace
                                              : barCenterLinePosition +
                                                    barHeight,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              _amountFormatter.format(
                                                diff.abs().toInt(),
                                              ),
                                              style: GraphTextStyles
                                                  .graphMiniLabel,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // X軸ラベルのみ
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          reservedSize,
                          0,
                          0,
                          0,
                        ),
                        child: SizedBox(
                          width: drawingAreaWidth - reservedSize,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(12, (i) {
                              return i == 0
                                  ? SizedBox(
                                      width: firstCellWidth,
                                      child: Text(
                                        '  ${chartData.monthlyBalanceValues[i].month}月',
                                        style: GraphTextStyles.graphMiniLabel,
                                        textAlign: TextAlign.left,
                                      ),
                                    )
                                  : i == 11
                                  ? SizedBox(
                                      width: endCellWidth,
                                      child: Text(
                                        '     ${chartData.monthlyBalanceValues[i].month}月',
                                        style: GraphTextStyles.graphMiniLabel,
                                        textAlign: TextAlign.left,
                                      ),
                                    )
                                  : SizedBox(
                                      width: normalCellWidth,
                                      child: Text(
                                        '${chartData.monthlyBalanceValues[i].month}月',
                                        style: GraphTextStyles.graphMiniLabel,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (error, stackTrace) {
            return Center(child: Text('Error: $error'));
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
        );
  }
}
