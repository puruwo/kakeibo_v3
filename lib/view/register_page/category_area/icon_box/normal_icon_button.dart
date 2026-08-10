import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/register_page/select_category_controller/select_category_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';

/// ADR-020 A案: 円（AppIconCircleContainer）は使わず裸アイコンで統一する。
/// 非選択は不透明度を落とし、選択中（[SelectedIconButton]）との差は
/// 不透明度・ラベルの太さ・下線ドットの3サインで表現する。
class NormalIconButton extends ConsumerWidget {
  const NormalIconButton({
    required this.categoryEntity,
    super.key,
  });

  final ICategoryEntity categoryEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.watch(selectCategoryControllerNotifierProvider.notifier);

    final color = ColorCode.toColor(categoryEntity.colorCode);

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
            child: Opacity(
              opacity: 0.42,
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
          ),

          //テキストラベル（非選択：控えめな色・通常ウェイト）
          SizedBox(
            width: 62.2 * ((context.screenHorizontalMagnification - 1) / 5 + 1),
            child: Center(
              child: Text(
                categoryEntity.categoryName,
                style: RegisterPageStyles.categoryLabel.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // 選択中のみ表示される下線ドットと高さを揃えるための透明スロット
          const SizedBox(height: 3),
          const SizedBox(width: 14, height: 2.5),
        ],
      ),
    );
  }
}
