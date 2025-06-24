import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view_model/state/register_page/select_category_controller/select_category_controller.dart';

class NormalIconButton extends ConsumerWidget {
  const NormalIconButton({
    required this.categoryEntity,
    Key? key,
  }) : super(key: key);

  final ICategoryEntity categoryEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.watch(selectCategoryControllerNotifierProvider.notifier);

    final color = MyColors().getColorFromHex(categoryEntity.colorCode);

    return GestureDetector(
      
      onTap: () {
        notifier.setData(categoryEntity);
      },

      child: Column(
        children: [
          SizedBox(
              height: 44 * context.screenVerticalMagnification,
              width: 62.2 * context.screenHorizontalMagnification,
              child: Container(
                decoration: BoxDecoration(
                  color: MyColors.secondarySystemfill,
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
                categoryEntity.smallCategoryName,
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
