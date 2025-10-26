import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';

class SelectedIconButton extends ConsumerWidget {
  const SelectedIconButton({
    required this.categoryEntity,
    Key? key,
  }) : super(key: key);

  final ICategoryEntity categoryEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final color = MyColors().getColorFromHex(categoryEntity.colorCode);

    return GestureDetector(

      onTap: () {
      },

      child: Column(
        children: [
          SizedBox(
              height: 44 * context.screenVerticalMagnification,
              width: 62.2 * context.screenHorizontalMagnification,
              child: Container(
                decoration: BoxDecoration(
                  color: MyColors.systemGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SvgPicture.asset(
                    categoryEntity.resourcePath,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    semanticsLabel: 'categoryIcon',
                    width: 25,
                    height: 25,
                  ),
                ),
              )),

          //テキストラベル
          SizedBox(
            width: 62.2 * ((context.screenHorizontalMagnification - 1) / 5 + 1),
            child: Center(
              child: Text(
                categoryEntity.categoryName,
                style: const TextStyle(
                  color: MyColors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }
}
