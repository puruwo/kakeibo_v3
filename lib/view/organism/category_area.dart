import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/util/screen_size_func.dart';

import 'package:kakeibo/view/molecule/icon_button.dart';

import 'package:kakeibo/view_model/provider/torok_state/selected_segment_status.dart';
import 'package:kakeibo/view_model/provider/torok_state/torok_state.dart';

import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/model/db_read_impl.dart';

import 'package:kakeibo/constant/colors.dart';

class CategoryArea extends ConsumerStatefulWidget {
  const CategoryArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CategoryAreaState();
}

class _CategoryAreaState extends ConsumerState<CategoryArea> {
  final pageController = PageController(initialPage: 0);
  Future<int> pageNumber = Future(() => 0);
  Future<int> displayCategoryNumber = Future(() => 0);

  @override
  Widget build(context) {
    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    // 縦サイズは横よりも少ない倍率で拡大
    final screenVerticalMagnification = screenVerticalMagnificationGetter(
        screenWidthSize, screenHorizontalMagnification);

//状態管理---------------------------------------------------------------------------------------

    final activeButtonNumberProvider = ref.watch(torokRecordNotifierProvider
        .select((record) => record.categoryOrderKey));

    final activeButtonNumberNotifier =
        ref.watch(torokRecordNotifierProvider.notifier);

    final torokMode = ref.watch(selectedSegmentStatusNotifierProvider);

    int? displayCategoryNumberq;
    // 表示するページ数
    pageNumber = Future(() async {
      if (torokMode == SelectedEnum.sisyt) {
        // 表示するカテゴリー数
        displayCategoryNumberq = await getDisplaySisytCategoryNumber();
      } else if (torokMode == SelectedEnum.syunyu) {
        // 表示するカテゴリー数
        displayCategoryNumberq = await getDisplaySyunyuCategoryNumber();
      }

      // 小数点切り上げ
      return (displayCategoryNumberq! / 15).ceil();
    });

    // 表示するカテゴリー数
    if (torokMode == SelectedEnum.sisyt) {
      displayCategoryNumber = getDisplaySisytCategoryNumber();
    } else if (torokMode == SelectedEnum.syunyu) {
      displayCategoryNumber = getDisplaySyunyuCategoryNumber();
    }

//----------------------------------------------------------------------------------------------

    return FutureBuilder(
      future: Future.wait([pageNumber, displayCategoryNumber]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        return SizedBox(
          height: 200*screenVerticalMagnification,
          width: 343 * screenHorizontalMagnification,
          child: PageView.builder(
            controller: pageController,
            itemCount: snapshot.data![0],
            itemBuilder: (context, pageIndex) {
              final displayCategoryNumber = snapshot.data![1];

              return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3, //3行の意味
                    (columnIndex) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //indexの実装
                        children: List.generate(
                          5, //1列5個の意味

                          (rowIndex) {
                            //ボタンの番号
                            final buttonNumber =
                                pageIndex * 15 + columnIndex * 5 + rowIndex;
                            //ボタン番号とrecordが持つボタン番号が一致しているかの判定をする、選択状態かどうかを決める
                            final isSelected =
                                (buttonNumber == activeButtonNumberProvider);

                            // ボタンのkey
                            // 表示するカテゴリー数(displayCategoryNumber)より小さければそのbuttonNumberを代入
                            // カテゴリー数より大きければ-1を代入(表示しない)
                            final buttonInfo =
                                buttonNumber + 1 <= displayCategoryNumber
                                    ? buttonNumber
                                    : -1;

                            late Widget icon;
                            Future<String> label = Future(() => '');
                            if (buttonInfo != -1) {
                              icon = (torokMode == SelectedEnum.sisyt)
                                  ? CategoryHandler().sisytIconGetter(
                                      buttonInfo,
                                      height: 25,
                                      width: 25)
                                  : CategoryHandler().syunyuIconGetter(
                                      buttonInfo,
                                      height: 25,
                                      width: 25);
                              label = (torokMode == SelectedEnum.sisyt)
                                  ? CategoryHandler()
                                      .sisytCategoryNameGetter(buttonInfo)
                                  : CategoryHandler()
                                      .syunyuCategoryNameGetter(buttonInfo);
                            } else if (buttonInfo == -1) {
                              icon = SizedBox(
                                height: 44*screenVerticalMagnification,
                                width: 62.2* screenHorizontalMagnification,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: MyColors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }

                            return FutureBuilder(
                                future: label,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Padding(
                                      padding: (rowIndex != 0 && rowIndex != 4)
                                          ? const EdgeInsets.symmetric(
                                              horizontal: 4)
                                          : (rowIndex == 0)
                                              ? const EdgeInsets.only(right: 4)
                                              : const EdgeInsets.only(left: 4),
                                      child: Container()
                                    );
                                  } else {
                                    return GestureDetector(
                                      onTap: buttonInfo != -1
                                          ? () {
                                              //状態の更新
                                              activeButtonNumberNotifier
                                                  .updateCategory(buttonNumber);
                                            }
                                          : () {
                                              // 何もしない
                                            },
                                      child: Padding(
                                        // 位置によってpaddingの幅を変える
                                        padding:
                                            (rowIndex != 0 && rowIndex != 4)
                                                ? const EdgeInsets.symmetric(
                                                    horizontal: 4)
                                                : (rowIndex == 0)
                                                    ? const EdgeInsets.only(
                                                        right: 4)
                                                    : const EdgeInsets.only(
                                                        left: 4),
                                        child: CategoryIconButton(
                                          //nullチェックどうするか考え直す
                                          buttonInfo: buttonInfo,
                                          isSelected: isSelected,
                                          icon: icon,
                                          label: snapshot.data!,
                                        ),
                                      ),
                                    );
                                  }
                                });
                          },
                        )),
                  ));
            },
          ),
        );
      },
    );
  }
}
