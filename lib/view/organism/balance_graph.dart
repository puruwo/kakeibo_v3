import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';

import 'package:kakeibo/view_model/provider/active_datetime.dart';
import 'package:kakeibo/model/db_read_impl.dart';

class BalanceGraph extends ConsumerStatefulWidget {
  const BalanceGraph({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BalanceGraphState();
}

class _BalanceGraphState extends ConsumerState<BalanceGraph> {
  List<Color> gradientColors = [
    MyColors.red,
    MyColors.blue,
  ];

  ScrollController? _scrollController;

  // 最大の月毎の収入 or 支出
  late int maxPrice;

  // 上1から本目のメモリ
  late int topLinePrice;

  // 2本目のメモリ
  late int halfLinePrice;

  // メモリの感覚
  late int lineInterval;

  // グラフの背の高さ
  late double maxHeight;

  late DateTime activeDt;

  @override
  void initState() {
    activeDt = DateTime.now();
    // スクロール位置の初期設定357
    // 現在の月でスクロール位置を変える
    _scrollController = ScrollController(initialScrollOffset: (activeDt.month-6) * 60);
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

        return Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                right: 16,
                left: 16,
                top: 16,
                bottom: 16,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Container(
                  height: 213,
                  width: 714,
                  child: LineChart(
                    mainData(sumPaymentByMonthMapList, sumIncomeByMonthMapList),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value) {
      case 0:
        text = const Text('1月', style: style);
        break;
      case 1:
        text = const Text('2月', style: style);
        break;
      case 2:
        text = const Text('3月', style: style);
        break;
      case 3:
        text = const Text('4月', style: style);
        break;
      case 4:
        text = const Text('5月', style: style);
        break;
      case 5:
        text = const Text('6月', style: style);
        break;
      case 6:
        text = const Text('7月', style: style);
        break;
      case 7:
        text = const Text('8月', style: style);
        break;
      case 8:
        text = const Text('9月', style: style);
        break;
      case 9:
        text = const Text('10月', style: style);
        break;
      case 10:
        text = const Text('11月', style: style);
        break;
      case 11:
        text = const Text('12月', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

// 左軸ラベル
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
    );
    String text;

    if (value.toInt() == topLinePrice) {
      text = labelGetter(topLinePrice);
      return Text(text, style: style, textAlign: TextAlign.right);
    } else if (value.toInt() == halfLinePrice) {
      text = labelGetter(halfLinePrice);
      return Text(text, style: style, textAlign: TextAlign.right);
    } else {
      return Container();
    }
  }

// 右軸ラベル
  Widget rightTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
    );
    String text;

    if (value.toInt() == topLinePrice) {
      text = labelGetter(topLinePrice);
      return Text(text, style: style, textAlign: TextAlign.left);
    } else if (value.toInt() == halfLinePrice) {
      text = labelGetter(halfLinePrice);
      return Text(text, style: style, textAlign: TextAlign.left);
    } else {
      return Container();
    }
  }

  LineChartData mainData(List<Map<String, dynamic>> paymentListMap,
      List<Map<String, dynamic>> incomeListMap) {
    return LineChartData(
      // タッチ操作時の設定
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,                        // タッチ時のアクションの有無
        getTouchedSpotIndicator: defaultTouchedIndicators, // インジケーターの設定
        touchTooltipData: LineTouchTooltipData(            // ツールチップの設定
          getTooltipItems: defaultLineTooltipItem,         // 表示文字設定
          tooltipBgColor: MyColors.dimGray,                    // 背景の色
          tooltipRoundedRadius: 10.0,                       // 角丸
        ),
      ),
      
      gridData: FlGridData(
        
        show: true,
        drawVerticalLine: false,
        // メモリの間隔
        horizontalInterval: lineInterval.toDouble(),
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: MyColors.dimGray,
            strokeWidth: 0.01,
          );
        },
      ),
      
      titlesData: FlTitlesData(
        show: true,
        // 上の軸表示 false
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // 横軸
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        // 左軸
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: lineInterval.toDouble(),
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
        // 右軸
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: lineInterval.toDouble(),
            getTitlesWidget: rightTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),

      // 外の枠線
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: MyColors.black),
      ),

      // グラフの最大値最小値
      minX: -0.2,
      maxX: 11.2,
      minY: 0,
      maxY: maxHeight,

      // 描画データの配置
      lineBarsData: [

        LineChartBarData(
          // 支出グラフデータの作成
          spots: List.generate(paymentListMap.length, (index) {
            int sumPrice = paymentListMap[index]['sum_price'];
            return FlSpot(index.toDouble(), sumPrice.toDouble());
          }),

          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          // 下の影
          belowBarData: BarAreaData(
            show: false,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),

        LineChartBarData(
          // 収入グラフデータの作成
          spots: List.generate(incomeListMap.length, (index) {
            int sumPrice = incomeListMap[index]['sum_price'];
            return FlSpot(index.toDouble(), sumPrice.toDouble());
          }),
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          // 下の影
          belowBarData: BarAreaData(
            show: false,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
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

  int lineIntervalGetter() {
    return topLinePrice - halfLinePrice;
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
