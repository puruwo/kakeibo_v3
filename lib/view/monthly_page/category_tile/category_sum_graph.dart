import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';

class CategorySumGraph extends HookConsumerWidget {
  const CategorySumGraph({required this.categoryTile, super.key});
  final CategoryCardEntity categoryTile;

  int get budget => categoryTile.monthlyBudget;
  CategoryAccountingEntity get monthlyExpenseByCategoryEntity =>
      categoryTile.monthlyExpenseByCategoryEntity;
  List<SmallCategoryTileEntity> get smallCategoryEntity =>
      categoryTile.smallCategoryList;

  final double barFrameWidth = 280.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //横棒グラフの初期値
    double barWidth = 0;
    final isBuilt = useState(false);

    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    barWidth = categoryTile.graphRatio! <= 1.0
        ? barFrameWidth * categoryTile.graphRatio!
        : barFrameWidth;
    //ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isBuilt.value = true;
    });

    switch (categoryTile.graphType) {
      // 予算あり
      case GraphType.hasBudget:
      // 他のカードも全て予算なしだが、支出はある
      case GraphType.allNoBudget:
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 3),
          child: Stack(
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
                    : 0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColors().getColorFromHex(
                      monthlyExpenseByCategoryEntity.categoryColor),
                ),
                duration: const Duration(milliseconds: 500),
              ),
            ],
          ),
        );
      // 予算あり、支出超過
      case GraphType.hasBudgetButOver:
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 3),
          child: Stack(children: [
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
                  ? barFrameWidth * screenHorizontalMagnification
                  : 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: MyColors().getColorFromHex(
                    monthlyExpenseByCategoryEntity.categoryColor),
              ),
              duration: const Duration(milliseconds: 500),
            ),
            // バーの超過分マスク
            SizedBox(
              width: barFrameWidth * screenHorizontalMagnification,
              child: AnimatedOpacity(
                opacity: isBuilt.value ? 1.0 : 0.0,
                curve: Curves.easeInExpo,
                duration: const Duration(milliseconds: 700),
                child: Container(
                  width: barFrameWidth,
                  // alignment: Alignment.centerRight,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(10)),
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              (barFrameWidth * categoryTile.graphRatio!),
                          child: Image.asset(
                            'assets/images/over_fill.png',
                            width: 280,
                            height: 10,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                ),
              ),
            )
          ]),
        );
      // 予算なし支出なし
      case GraphType.noExpenseNoBudget:
      // 他に予算設定はあるが、該当カテゴリーに予算なし
      case GraphType.noBudgetOtherHasBudget:
      // 個別カード表示で利用 --予算なし
      case GraphType.noBudget:
        return Container();
    }
  }
}

class MyClipper extends CustomClipper<Rect> {
  final double frameWidth;
  final double degrees;

  MyClipper({required this.frameWidth, required this.degrees});

  @override
  Rect getClip(Size size) {
    double maskWidth = frameWidth * (degrees - 1);
    return Rect.fromLTWH(0, 0, maskWidth, 10);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
