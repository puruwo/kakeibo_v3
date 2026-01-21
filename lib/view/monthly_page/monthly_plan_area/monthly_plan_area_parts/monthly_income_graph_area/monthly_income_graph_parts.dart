import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';

class MonthlyIncomeGraph extends HookConsumerWidget {
  const MonthlyIncomeGraph(
      {super.key,
      required this.maxGraphWidth,
      required this.allCategoryCardEntity});

  final double maxGraphWidth;
  final MonthPlanCardModel allCategoryCardEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ビルドが完了したかどうか
    final isBuilt = useState(false);

    //ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isBuilt.value = true;
    });

    // 収入がオーバーフローしているかどうかを判定 (KAN-25条件)
    // 収入の合計比率が1を超えている場合はオーバーフロー
    final totalIncomeRatio = allCategoryCardEntity.incomeCategoryRatioList
        .fold(0.0, (sum, ratio) => sum + ratio);
    final isIncomeOverflow = totalIncomeRatio > 1.0;

    // バーグラフ本体
    Widget barGraph = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 0,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ...List.generate(allCategoryCardEntity.incomeCategoryNameList.length,
              (i) {
            return AnimatedContainer(
              height: 10,
              width: isBuilt.value
                  ? allCategoryCardEntity.incomeCategoryRatioList[i] *
                      maxGraphWidth
                  : 0,
              color: MyColors().getColorFromHex(
                  allCategoryCardEntity.incomeCategoryColorList[i]),
              duration: const Duration(milliseconds: 500),
            );
          }),
        ]),
      ),
    );

    // オーバーフロー時は右端にフェードアウト効果を追加
    if (isIncomeOverflow) {
      return ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.85, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: barGraph,
      );
    }

    return barGraph;
  }
}
