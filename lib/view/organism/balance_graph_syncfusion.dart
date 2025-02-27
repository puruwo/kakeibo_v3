/// Package import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';

/// Local import
import 'package:kakeibo/model/db_read_impl.dart';

class LineChartA extends StatefulWidget {
  const LineChartA({super.key});

  @override
  State<LineChartA> createState() => _LineChartAState();
}

class _LineChartAState extends State<LineChartA> {
  // チャートデータ
  List<_ChartData> chartData = [];

  // 最大の月毎の収入 or 支出
  late int maxPrice;

  // 上1から本目のメモリ
  late int topLinePrice;

  // 2本目のメモリ
  late int halfLinePrice;

  // メモリの感覚
  late double lineInterval;

  // グラフの背の高さ
  late double maxHeight;

  late DateTime activeDt;

  @override
  void initState() {
    activeDt = DateTime.now();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Map<String, dynamic>>> sumPaymentByMonthFutureMapList =
        sumPaymentByMonthMapListGetter(activeDt.year);

    Future<List<Map<String, dynamic>>> sumIncomeByMonthFutureMapList =
        sumIncomeByMonthMapListGetter(activeDt.year);

    return FutureBuilder(
      future: Future.wait(
          [sumPaymentByMonthFutureMapList, sumIncomeByMonthFutureMapList]),
      builder: (context, snapshot) {
        final sumPaymentByMonthMapList = snapshot.data![0];
        final sumIncomeByMonthMapList = snapshot.data![1];

        maxPrice =
            maxPriceGetter(sumPaymentByMonthMapList, sumIncomeByMonthMapList);

        topLinePrice = topLinePriceGetter(maxPrice);
        halfLinePrice = halfLinePriceGetter(topLinePrice);
        lineInterval = lineIntervalGetter();
        maxHeight = maxHeightGetter();

        // グラフデータの作成
        for (int i = 0; i < sumPaymentByMonthMapList.length; i++) {
          int sumPaymentPrice = sumPaymentByMonthMapList[i]['sum_price'];
          int sumIncomePrice = sumIncomeByMonthMapList[i]['sum_price'];
          chartData.add(_ChartData(i.toDouble(), sumPaymentPrice.toDouble(),
              sumIncomePrice.toDouble()));
        }

        return Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                right: 16,
                left: 16,
                top: 16,
                bottom: 16,
              ),
              child: Container(
                height: 213,
                width: 714,
                decoration: BoxDecoration(
                    color: MyColors.quarternarySystemfill,
                    borderRadius: BorderRadius.circular(8)),
                child: _buildDefaultLineChart(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get the cartesian chart with default line series
  SfCartesianChart _buildDefaultLineChart() {
    return SfCartesianChart(
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
      ),
      borderColor: Colors.transparent,
      plotAreaBorderWidth: 0,
      onAxisLabelTapped: (axisLabelTapArgs) {
        if(axisLabelTapArgs.axisName == 'primaryXAxis'){
          final month = axisLabelTapArgs.value.toInt() + 1;
          print(month);
        }
      },
      margin: const EdgeInsets.all(10),
      legend: const Legend(
          textStyle: TextStyle(color: MyColors.white, fontSize: 14),
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap),

      // x軸の設定
      primaryXAxis: NumericAxis(
        // min,max
        // ビルド時のスクロール位置
        initialVisibleMinimum: -0.35,
        minimum: -0.35,
        maximum: 11.35,

        anchorRangeToVisiblePoints: true,
        rangePadding: ChartRangePadding.normal,

        // ラベル
        labelFormat: '{value}月',
        axisLabelFormatter: (axisLabelRenderArgs) {
          return ChartAxisLabel(
            "${axisLabelRenderArgs.value.toInt() + 1}月",
            const TextStyle(color: MyColors.white, fontSize: 14),
          );
        },
        labelIntersectAction: AxisLabelIntersectAction.hide,
        labelAlignment: LabelAlignment.center,

        // メモリ線の位置（insideだとスクロールといっしょに動く）
        tickPosition: TickPosition.inside,

        // 軸のパディング
        plotOffset: 4,

        // 自動メモリ表示処理
        enableAutoIntervalOnZooming: false,

        // 四捨五入
        decimalPlaces: 0,

        // 最初に何月分表示するか
        autoScrollingDelta: 6,
        // 左寄せスタート
        autoScrollingMode: AutoScrollingMode.start,
        // 境界のラベルをどうするか
        edgeLabelPlacement: EdgeLabelPlacement.none,
        // 表示間隔
        interval: 1,

        // 縦のグリッド、表示しないように記述
        majorGridLines: const MajorGridLines(
          width: 0,
        ),
        // 横軸の下ちょぼ
        majorTickLines:
            const MajorTickLines(size: 0, width: 10, color: MyColors.blue),
      ),

      // y軸の設定
      primaryYAxis: NumericAxis(
          // 表示間隔
          interval: lineInterval,
          // グラフの表示最大値(枠)
          maximum: maxHeight,

          // ラベル
          labelFormat: '{value}',
          axisLabelFormatter: (axisLabelRenderArgs) {
            if (axisLabelRenderArgs.value > 0) {
              return ChartAxisLabel(
                "${axisLabelRenderArgs.value ~/ 10000}万",
                const TextStyle(color: MyColors.secondaryLabel, fontSize: 12),
              );
            } else {
              return ChartAxisLabel("", null);
            }
          },
          labelAlignment: LabelAlignment.center,
          labelPosition: ChartDataLabelPosition.outside,
          labelIntersectAction: AxisLabelIntersectAction.hide,

          // グリッド
          majorGridLines: const MajorGridLines(width: 1.0,color: MyColors.separater),
          // 表示しないために以下記述
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(color: Colors.transparent)),

      series: _getDefaultLineSeries(),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  /// The method returns line series to chart.
  List<LineSeries<_ChartData, num>> _getDefaultLineSeries() {
    return <LineSeries<_ChartData, num>>[
      LineSeries<_ChartData, num>(
        dataSource: chartData,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y,
        name: '支出',
        markerSettings: const MarkerSettings(isVisible: true),
        // ラベルの表示設定
        dataLabelSettings: const DataLabelSettings(
          textStyle: TextStyle(color: MyColors.secondaryLabel, fontSize: 11),
          isVisible: true,
          useSeriesColor: false,
          // ラベルの位置
          labelAlignment: ChartDataLabelAlignment.bottom,
          alignment: ChartAlignment.center,
          // ラベルが領域外に出た時の設定
          overflowMode: OverflowMode.none,
          // ラベルが重なった時の設定
          labelIntersectAction: LabelIntersectAction.shift,
          showZeroValue: false,
          offset: Offset(0, 0),
        ),
      ),
      LineSeries<_ChartData, num>(
          dataSource: chartData,
          name: '収入',
          xValueMapper: (_ChartData sales, _) => sales.x,
          yValueMapper: (_ChartData sales, _) => sales.y2,
          markerSettings: const MarkerSettings(isVisible: true),

          // ラベルの表示設定
          dataLabelSettings: const DataLabelSettings(
            textStyle: TextStyle(color: MyColors.secondaryLabel, fontSize: 11),
            isVisible: true,
            useSeriesColor: false,
            // ラベルの位置
            labelAlignment: ChartDataLabelAlignment.top,
            alignment: ChartAlignment.center,
            // ラベルが領域外に出た時の設定
            overflowMode: OverflowMode.none,
            // ラベルが重なった時の設定
            labelIntersectAction: LabelIntersectAction.shift,
            showZeroValue: false,
            offset: Offset(0, 0),
          ))
    ];
  }

  @override
  void dispose() {
    chartData!.clear();
    super.dispose();
  }

  int topLinePriceGetter(int maxPrice) {
    if (maxPrice < 1000) {
      return 1000;
    } else if (1000 <= maxPrice && maxPrice < 5000) {
      return 5000;
    } else if (5000 <= maxPrice && maxPrice < 10000) {
      return 10000;
    } else if (10000 <= maxPrice && maxPrice < 100000) {
      double convertedMaxPrice = maxPrice / 1000;
      return convertedMaxPrice.round().toInt() * 1000;
    } else if (100000 <= maxPrice && maxPrice < 200000) {
      double convertedMaxPrice = maxPrice / 5000;
      return convertedMaxPrice.round().toInt() * 5000;
    } else if (200000 <= maxPrice && maxPrice < 600000) {
      double convertedMaxPrice = maxPrice / 10000;
      return convertedMaxPrice.round().toInt() * 10000;
    } else if (600000 <= maxPrice && maxPrice < 2000000) {
      double convertedMaxPrice = maxPrice / 50000;
      return convertedMaxPrice.round().toInt() * 50000;
    } else {
      double convertedMaxPrice = maxPrice / 100000;
      return convertedMaxPrice.round().toInt() * 100000;
    }
  }

  int halfLinePriceGetter(int topLinePrice) {
    return (topLinePrice / 2).ceil();
  }

  double lineIntervalGetter() {
    return (topLinePrice - halfLinePrice).toDouble();
  }

  String labelGetter(int linePrice) {
    if (linePrice < 1000) {
      return '$linePrice円';
    } else if (1000 <= linePrice && linePrice < 10000) {
      double convertedLinePrice = linePrice / 10000;
      return '${convertedLinePrice.toStringAsFixed(1)}万';
    } else if (10000 <= linePrice && linePrice < 10000000) {
      double convertedLinePrice = linePrice / 10000;
      return '${convertedLinePrice.floor().toInt()}万';
    } else if (10000000 <= linePrice && linePrice < 100000000) {
      double convertedLinePrice = linePrice / 100000000;
      return '${convertedLinePrice.floor()}億';
    } else if (100000000 <= linePrice && linePrice < 100000000000) {
      double convertedLinePrice = linePrice / 100000000;
      return '${convertedLinePrice.floor().toInt()}億';
    } else {
      return '';
    }
  }

  double maxHeightGetter() {
    double maxHeight = maxPrice > topLinePrice
        ? maxPrice + lineInterval * 0.25
        : topLinePrice + lineInterval * 0.25;
    return maxHeight;
  }

  // {
  // year_month:
  // sum_price:
  // }
  Future<List<Map<String, dynamic>>> sumPaymentByMonthMapListGetter(
      int year) async {
    List<Map<String, dynamic>> list = [];
    for (int i = 0; i < 12; i++) {
      DateTime fromDate = DateTime(year, i + 1, 25);
      DateTime toDate = DateTime(year, i + 2, 25);
      final buff = await getMonthPaymentSum(fromDate, toDate);
      // 一ヶ月分しか返ってこないが、リスト形式で返ってくるためindex=0を指定
      list.add(buff[0]);
    }
    return list;
  }

  // {
  // year_month:
  // sum_price:
  // }
  Future<List<Map<String, dynamic>>> sumIncomeByMonthMapListGetter(
      int year) async {
    List<Map<String, dynamic>> list = [];
    for (int i = 0; i < 12; i++) {
      DateTime fromDate = DateTime(year, i + 1, 25);
      DateTime toDate = DateTime(year, i + 2, 25);
      final buff = await getMonthIncomeSum(fromDate, toDate);
      // 一ヶ月分しか返ってこないが、リスト形式で返ってくるためindex=0を指定
      list.add(buff[0]);

      buff[0]['sum_price'];
    }
    return list;
  }

  int maxPriceGetter(List<Map<String, dynamic>> sumPaymentByMonthMapList,
      List<Map<String, dynamic>> sumIncomeByMonthMapList) {
    int maxPrice = 0;
    int sumPaymentPrice = 0;
    int sumIncomePrice = 0;
    for (int i = 0; i < 12; i++) {
      sumPaymentPrice = sumPaymentByMonthMapList[i]['sum_price'];
      sumIncomePrice = sumIncomeByMonthMapList[i]['sum_price'];

      int largerPrice = 0;
      if (sumIncomePrice > sumPaymentPrice) {
        largerPrice = sumIncomePrice;
      } else {
        largerPrice = sumPaymentPrice;
      }

      if (maxPrice < largerPrice) {
        maxPrice = largerPrice;
      }
    }

    return maxPrice;
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.y2);
  final double x;
  final double y;
  final double y2;
}
