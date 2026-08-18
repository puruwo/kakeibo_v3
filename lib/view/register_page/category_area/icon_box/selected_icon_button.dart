import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/constant/strings.dart';

/// ADR-020 A案: 選択中は不透明度100%＋太字ラベル＋下線ドットの3サインで示す。
/// [NormalIconButton]と同じ裸アイコン構成で、円は使わない。
class SelectedIconButton extends ConsumerWidget {
  const SelectedIconButton({
    required this.categoryEntity,
    super.key,
  });

  final ICategoryEntity categoryEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ColorCode.toColor(categoryEntity.colorCode);

    return AppInkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {},
      child: Column(
        children: [
          SizedBox(
            height: 34 * context.screenVerticalMagnification,
            width: 34 * context.screenVerticalMagnification,
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
          ),

          //テキストラベル（選択中：白・太字）
          SizedBox(
            width: 62.2 * ((context.screenHorizontalMagnification - 1) / 5 + 1),
            child: Center(
              child: Text(
                categoryEntity.categoryName,
                style: RegisterPageStyles.categoryLabel.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // 下線ドット（一般/固定費/収入タブ等の選択インジケーターと同じ視覚言語）
          const SizedBox(height: 3),
          Container(
            width: 14,
            height: 2.5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
