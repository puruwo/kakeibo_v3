import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/register_page_styles.dart';

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
              color: MyColors.black,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        //テキストラベル
        SizedBox(
          width: 62.2 * ((context.screenHorizontalMagnification - 1) / 5 + 1),
          child: const Center(
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
