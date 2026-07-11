import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/constant/strings.dart';

class NoneIconBox extends StatelessWidget {
  const NoneIconBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 44 * context.screenVerticalMagnification,
          width: 62.2 * context.screenHorizontalMagnification,
          child: Container(
            decoration: BoxDecoration(
              // 空きスロットは背景に溶ける面の色にする
              // （トークン移行時に text（白）へ誤マッピングされていたバグの修正。旧実装はMyColors.black）
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        //テキストラベル
        SizedBox(
          width: 62.2 * ((context.screenHorizontalMagnification - 1) / 5 + 1),
          child: Center(
            child: Text(
              '',
              style: RegisterPageStyles.categoryLabel,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
      ],
    );
  }
}
