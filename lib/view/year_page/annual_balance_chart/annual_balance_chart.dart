import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

class AnnualBalanceChart extends StatelessWidget {
  final List<String> months = [
    '1月',
    '2月',
    '3月',
    '4月',
    '5月',
    '6月',
    '7月',
    '8月',
    '9月',
    '10月',
    '11月',
    '12月'
  ];

  final List<double> income = [
    250000,
    240000,
    260000,
    220000,
    230000,
    250000,
    270000,
    280000,
    260000,
    250000,
    255000,
    240000
  ];

  final List<double> expense = [
    200000,
    300000,
    210000,
    200000,
    210000,
    230000,
    220000,
    220000,
    270000,
    230000,
    230000,
    220000
  ];

  @override
  Widget build(BuildContext context) {
    // エリアの幅
    const scrollAreaWidth = 700.0;

    const horizontalPadding = 8.0;

    // 描画可能エリアの幅
    const double drawingAreaWidth = scrollAreaWidth - horizontalPadding * 2;

    // 棒グラフエリアの高さ
    const barGraphHeight = 40.0;

    // グラフのメモリ表示スペース
    const reservedSize = 24.0;

    // グリッドの間隔
    const verticalInterval = 100000.0;

    // チャートエリアの幅
    const chartAreaWidth = drawingAreaWidth - reservedSize;

    // 差分を計算
    final differences =
        List.generate(income.length, (i) => income[i] - expense[i]);

    // 差の最大値を計算
    final maxDifference = differences.reduce(max);

    // グラフの最小値と最大値を計算
    final minY = (income + expense).reduce(min);
    final maxY = (income + expense).reduce(max);
    final maxMinDifference = (maxY - minY).abs(); // 最大値と最小値の差を計算

    // 棒グラフのバーの幅
    const barWidth = 25.0;

    // チャートエリアのマージン
    final topMargin = (verticalInterval / 3) * maxMinDifference / 100000.0;
    final bottomMargin = (verticalInterval / 2) * maxMinDifference / 100000.0;
    const lewtMargin = 0.3;
    const rightMargin = 0.3;

    // 一つのセルの幅を計算
    const cellWidth = chartAreaWidth / (11 + lewtMargin + rightMargin);
    const firstCellWidth = cellWidth * (0.5 + lewtMargin);
    const endCellWidth = cellWidth * (0.5 + rightMargin);

    return Container(
      width: scrollAreaWidth,
      decoration: BoxDecoration(
        color: MyColors.quarternarySystemfill,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
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
                        borderData: FlBorderData(show: false), //グラフの枠線を非表示
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
                            // 最大値と最小値の幅より外は非表示
                            if (value < minY - verticalInterval ||
                                value > maxY + verticalInterval) {
                              return const FlLine(
                                color: MyColors.transparent,
                                strokeWidth: 1,
                              );
                            }
                            // それ以外は表示
                            return const FlLine(
                              color: MyColors.separater,
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
                                if (value == meta.max || value == meta.min) {
                                  return const SizedBox.shrink();
                                }
                                // 最大値と最小値の幅より外は非表示
                                if (value < minY - verticalInterval ||
                                    value > maxY + verticalInterval) {
                                  return const SizedBox.shrink();
                                }
                                // それ以外の時は二桁に丸めて表示
                                return Text('${(value / 10000).truncate()}万',
                                    style: const TextStyle(
                                        color: MyColors.secondaryLabel,
                                        fontSize: 12));
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
                            spots: List.generate(income.length,
                                (i) => FlSpot(i.toDouble(), income[i])),
                            isCurved: false,
                            color: MyColors.mintBlue,
                            barWidth: 2,
                            dotData: const FlDotData(show: true),
                          ),
                          LineChartBarData(
                            spots: List.generate(expense.length,
                                (i) => FlSpot(i.toDouble(), expense[i])),
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
                    const Positioned(
                        left: 0,
                        bottom: barGraphHeight / 2 - 6,
                        child: SizedBox(
                          width: reservedSize,
                          child: Text('収支',
                              style: TextStyle(
                                  color: MyColors.secondaryLabel,
                                  fontSize: 12)),
                        )),
                    // 基準線: バーエリアの中央
                    Positioned(
                      top: barGraphHeight / 2,
                      left: reservedSize,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: MyColors.separater,
                      ),
                    ),
                    // 棒グラフ
                    Padding(
                      padding: const EdgeInsets.only(left: reservedSize),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(differences.length, (i) {
                          final diff = differences[i];
                          final barHeight =
                              (diff.abs() / maxDifference) * barGraphHeight;
                          const double baseline =
                              barGraphHeight / 2; // bar area half height

                          return SizedBox(
                            width: i == 0
                                ? firstCellWidth
                                : i == 11
                                    ? endCellWidth
                                    : cellWidth,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  left: i == 0
                                      ? firstCellWidth -
                                          (cellWidth - barWidth) / 2 -
                                          barWidth
                                      : (cellWidth - barWidth) / 2,
                                  bottom: diff >= 0 ? baseline : null,
                                  top: diff < 0 ? baseline : null,
                                  child: Container(
                                    width: barWidth,
                                    height: barHeight,
                                    color: diff >= 0
                                        ? MyColors.mintBlue
                                        : MyColors.pink,
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
                padding: const EdgeInsets.fromLTRB(reservedSize, 0, 0, 0),
                child: SizedBox(
                  width: drawingAreaWidth - reservedSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(12, (i) {
                      return i == 0
                          ? SizedBox(
                              width: firstCellWidth,
                              child: Text(
                                '   ${months[i]}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.left,
                              ),
                            )
                          : i == 11
                              ? SizedBox(
                                  width: endCellWidth,
                                  child: Text(
                                    '      ${months[i]}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    textAlign: TextAlign.left,
                                  ),
                                )
                              : SizedBox(
                                  width: cellWidth,
                                  child: Text(
                                    '${months[i]}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ));
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
