import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/view/page/third_page.dart';

class CategoryIconButton extends ConsumerWidget {
  final int buttonInfo;
  final bool isSelected;
  final Widget icon;
  final String label;
  const CategoryIconButton({
    this.buttonInfo = -1,
    this.isSelected = false,
    required this.icon,
    this.label = '',
    Key? key,
  }) : super(key: key);

  Widget build(BuildContext context, WidgetRef ref) {
    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    // 縦サイズは横よりも少ない倍率で拡大
    final screenVerticalMagnification = screenVerticalMagnificationGetter(
        screenWidthSize, screenHorizontalMagnification);

    return Column(
      children: [
        //アイコンボタン本体
        buttonInfo != -1
            //非選択状態
            ? SizedBox(
                height: 44 * screenVerticalMagnification,
                width: 62.2 * screenHorizontalMagnification,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        //非選択状態 or 選択状態
                        isSelected == false
                            ? MyColors.secondarySystemfill
                            : MyColors.systemGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: icon,
                ),
              )
            : SizedBox(
                height: 44 * screenVerticalMagnification,
                width: 62.2 * screenHorizontalMagnification,
                child: Container(
                  decoration: BoxDecoration(
                    color: MyColors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

        //テキストラベル

        SizedBox(
          width: 62.2 * ((screenHorizontalMagnification - 1) / 5 + 1),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: MyColors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
      ],
    );
  }
}
