import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/register_page_styles.dart';
import 'package:kakeibo/view_model/state/register_page/select_category_controller/select_category_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';

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

    return AppInkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        notifier.setData(categoryEntity);
      },
      child: Column(
        children: [
          SizedBox(
              height: 58 * context.screenVerticalMagnification,
              width: 58 * context.screenVerticalMagnification,
              child: Container(
                decoration: const BoxDecoration(
                  color: MyColors.secondarySystemfill,
                  shape: BoxShape.circle,
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
                style: RegisterPageStyles.categoryLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
