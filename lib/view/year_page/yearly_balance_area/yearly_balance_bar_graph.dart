import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';

enum YearlyBalanceBarGraphStatus { underBudget, overBudget, noBudget }

class YearlyBalanceBarGraph extends HookConsumerWidget {
  const YearlyBalanceBarGraph(
      {required this.budget, required this.expense, super.key});

  final int budget;
  final int expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    YearlyBalanceBarGraphStatus barGraphStatus;
    // 入力した値よりグラフの状態を出す
    if (budget == 0) {
      barGraphStatus = YearlyBalanceBarGraphStatus.noBudget;
    } else if (expense <= budget) {
      barGraphStatus = YearlyBalanceBarGraphStatus.underBudget;
    } else {
      barGraphStatus = YearlyBalanceBarGraphStatus.overBudget;
    }

    final isBuilt = useState(false);

    //ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isBuilt.value = true;
    });

    return LayoutBuilder(builder: ((context, constraints) {

      // 画面の横幅を取得し、棒グラフの幅を設定
      final double barFrameWidth = constraints.maxWidth;

      //横棒グラフの初期値
      double barInitialWidth = barFrameWidth;

      // 画面の倍率を計算
      // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
      final screenHorizontalMagnification =context.screenHorizontalMagnification;

      // アニメーション後の横棒グラフの幅を計算
      int lastPrice = budget - expense;
      double degrees = (lastPrice / budget);
      double barWidth =
          degrees <= 1.0 ? barFrameWidth * degrees : barFrameWidth;

      // 予算よりも利用額が少ない場合
      if (barGraphStatus == YearlyBalanceBarGraphStatus.underBudget) {
        return Stack(
          alignment: Alignment.centerRight,
          children: [
            // バーの背景枠
            Container(
              height: 10,
              width: barFrameWidth * screenHorizontalMagnification,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: MyColors.secondarySystemfill,
              ),
            ),
            // バーの中身
            AnimatedContainer(
              height: 10,
              width: isBuilt.value
                  ? barWidth * screenHorizontalMagnification
                  : barInitialWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: MyColors.themeColor,
              ),
              duration: const Duration(milliseconds: 500),
            ),
          ],
        );
      }

      // 予算よりも利用額が多い場合
      if (barGraphStatus == YearlyBalanceBarGraphStatus.overBudget) {
        return Stack(
          alignment: Alignment.centerRight,
          children: [
          // バーの中身
          AnimatedContainer(
            height: 10,
            width: barFrameWidth * screenHorizontalMagnification,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyColors.themeColor,
            ),
            duration: const Duration(milliseconds: 500),
          ),
          // バーの超過分マスク
          SizedBox(
            width: (barFrameWidth * (-lastPrice)/(budget - lastPrice)) * screenHorizontalMagnification,
            child: AnimatedOpacity(
              opacity: isBuilt.value ? 1.0 : 0.0,
              curve: Curves.easeInExpo,
              duration: const Duration(milliseconds: 700),
              child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(10),left: Radius.circular(10)),
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        'assets/images/over_fill.png',
                        width: 280,
                        height: 10,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )),
            ),
          )
        ]);
      }

      // 予算が設定されていない場合
      if (barGraphStatus == YearlyBalanceBarGraphStatus.noBudget) {
        return const Text(
          '予算が設定されていません',
          style: TextStyle(color: MyColors.secondaryLabel, fontSize: 16),
        );
      } else {
        return const Text(
          '予期せぬエラーが発生しました',
          style: TextStyle(color: MyColors.secondaryLabel, fontSize: 16),
        );
      }
    }));
  }
}
