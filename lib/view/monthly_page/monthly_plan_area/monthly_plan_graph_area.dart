import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';

class MnothlyPlanGraphArea extends HookConsumerWidget {
  const MnothlyPlanGraphArea({super.key});

  // 横棒グラフのフレームサイズ
  final double barFrameWidth = 280.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedAllCategoryTileEntityProvider).when(
          data: (allCategoryCardEntity) {
            final List<double> barWidthList = List.generate(
                allCategoryCardEntity.categoryCount, (index) => 0.0);

            // 予算が設定されているか
            bool isSetBudget = true;

            // ビルドが完了したかどうか
            final isBuilt = useState(false);

            // 画面の横幅を取得
            final screenWidthSize = MediaQuery.of(context).size.width;

            // 画面の倍率を計算
            // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
            final screenHorizontalMagnification =
                screenHorizontalMagnificationGetter(screenWidthSize);

            isSetBudget = allCategoryCardEntity.allCategoryTotalBudget == 0
                ? false
                : true;

            // 各カテゴリーのグラフ幅を計算
            for (int i = 0; i < barWidthList.length; i++) {
              if (allCategoryCardEntity.allCategoryTotalExpense <
                  allCategoryCardEntity.allCategoryTotalBudget) {
                double degrees = (allCategoryCardEntity.categoryExpenseList[i] /
                    allCategoryCardEntity.allCategoryTotalBudget);
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
                Padding(
                    // バーの上下の余白を調整
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: isSetBudget
                        ? Stack(
                            children: [
                              // バーの背景枠
                              Container(
                                height: 10,
                                width: barFrameWidth *
                                    screenHorizontalMagnification,
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
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ...List.generate(
                                            allCategoryCardEntity.categoryCount,
                                            (index) {
                                          return AnimatedContainer(
                                            height: 10,
                                            width: isBuilt.value
                                                ? barWidthList[index] *
                                                    screenHorizontalMagnification
                                                : 0,
                                            color: MyColors().getColorFromHex(
                                                allCategoryCardEntity
                                                    .categoryColorList[index]),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          );
                                        }),
                                      ]),
                                ),
                              )
                            ],
                          )
                        : const Text(
                            '予算が設定されていません',
                            style: TextStyle(
                                color: MyColors.secondaryLabel, fontSize: 16),
                          ));
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
