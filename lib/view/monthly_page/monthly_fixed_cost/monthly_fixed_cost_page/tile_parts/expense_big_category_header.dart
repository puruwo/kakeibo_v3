import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/view/component/app_contents_header.dart';

class ExpenseBigCategoryHeader extends StatelessWidget {
  const ExpenseBigCategoryHeader({
    super.key,
    required this.categoryName,
    required this.colorCode,
    required this.resourcePath,
  });

  final String categoryName;
  final String colorCode;
  final String resourcePath;

  @override
  Widget build(BuildContext context) {
    // カテゴリーの色を取得
    final color = ColorCode.toColor(colorCode);

    return Column(
      children: [
        AppContentsHeader(
          type: AppContentsHeaderType.listCardSectionTitle,
          iconWidget: SvgPicture.asset(
            resourcePath,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            semanticsLabel: 'categoryIcon',
            width: 24,
            height: 24,
          ),
          title: categoryName,
        ),
        Divider(height: 0, thickness: 1),

        // 旧10px。区切り線直下の詰め余白は sm へ切り下げ（ツールチップ内周の 10→md とは用途が異なる）
        SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
