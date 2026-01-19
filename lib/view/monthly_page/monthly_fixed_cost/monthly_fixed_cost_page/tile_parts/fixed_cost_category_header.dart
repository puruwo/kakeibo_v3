import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/component/app_contents_header.dart';

class FixedCostCategoryHeader extends StatelessWidget {
  const FixedCostCategoryHeader({
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
    final color = MyColors().getColorFromHex(colorCode);

    return AppContentsHeader(
      iconWidget: SvgPicture.asset(
        resourcePath,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        semanticsLabel: 'categoryIcon',
        width: 28,
        height: 28,
      ),
      title: categoryName,
    );
  }
}
