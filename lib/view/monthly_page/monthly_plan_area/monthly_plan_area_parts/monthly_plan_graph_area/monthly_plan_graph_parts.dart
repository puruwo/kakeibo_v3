import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';

class MnothlyPlanGraph extends HookConsumerWidget {
  const MnothlyPlanGraph(
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

    final totalExpenseRatio = allCategoryCardEntity.expenseCategoryRatioList
        .fold(0.0, (sum, ratio) => sum + ratio);
    final isExpenseOverflow = totalExpenseRatio > 1.0;

    Widget barGraph = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 0,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ...List.generate(
              allCategoryCardEntity.expenseCategoryNameList.length, (i) {
            return AnimatedContainer(
              height: 8.5,
              width: isBuilt.value
                  ? allCategoryCardEntity.expenseCategoryRatioList[i] *
                      maxGraphWidth
                  : 0,
              color: ColorCode.toColor(
                  allCategoryCardEntity.expenseCategoryColorList[i]),
              duration: const Duration(milliseconds: 500),
            );
          }),
        ]),
      ),
    );

    // 収入グラフと同様、オーバーフロー時は右端にフェードアウト効果を適用
    if (isExpenseOverflow) {
      barGraph = ShaderMask(
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

    return Stack(
      children: [
        // バーの背景枠
        Container(
          height: 8.5,
          width: maxGraphWidth * allCategoryCardEntity.totalBadgetRatio,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.colors.fillSecondary,
          ),
        ),
        barGraph,
      ],
    );
  }
}
