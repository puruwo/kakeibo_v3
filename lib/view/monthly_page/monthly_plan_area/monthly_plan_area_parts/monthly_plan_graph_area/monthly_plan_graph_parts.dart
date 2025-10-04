import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/util/screen_size_func.dart';

class MnothlyPlanGraph extends HookConsumerWidget {
  const MnothlyPlanGraph({super.key, required this.allCategoryCardEntity});

  final AllCategoryCardModel allCategoryCardEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<double> barWidthList =
        List.generate(allCategoryCardEntity.categoryCount, (index) => 0.0);

    // ビルドが完了したかどうか
    final isBuilt = useState(false);

    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    // 横棒グラフのフレームサイズ
    final double barFrameWidth = screenWidthSize - 64;

    // 各カテゴリーのグラフ幅を計算
    for (int i = 0; i < barWidthList.length; i++) {
      if (allCategoryCardEntity.allCategoryTotalExpense <
          allCategoryCardEntity.denominator) {
        double degrees = (allCategoryCardEntity.categoryExpenseList[i] /
            allCategoryCardEntity.denominator);
        barWidthList[i] = degrees = barFrameWidth * degrees;
      } else {
        double degrees = (allCategoryCardEntity.categoryExpenseList[i] /
            allCategoryCardEntity.allCategoryTotalExpense);
        barWidthList[i] = degrees = barFrameWidth * degrees;
      }
    }

    //ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isBuilt.value = true;
    });

    return
        // バーグラフ
        Stack(
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
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 0,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ...List.generate(allCategoryCardEntity.categoryCount, (index) {
                return AnimatedContainer(
                  height: 10,
                  width: isBuilt.value
                      ? barWidthList[index] * screenHorizontalMagnification
                      : 0,
                  color: MyColors().getColorFromHex(
                      allCategoryCardEntity.categoryColorList[index]),
                  duration: const Duration(milliseconds: 500),
                );
              }),
            ]),
          ),
        )
      ],
    );
  }
}
