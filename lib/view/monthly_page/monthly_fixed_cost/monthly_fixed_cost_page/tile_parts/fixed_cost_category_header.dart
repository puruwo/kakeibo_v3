import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/strings.dart';

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

    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 8.0),
      child: Row(
        children: [
          // アイコン
          SvgPicture.asset(
            resourcePath,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            semanticsLabel: 'categoryIcon',
            width: 28,
            height: 28,
          ),
          const SizedBox(width: 12),
          // カテゴリー名
          Text(
            categoryName,
            style: MonthlyPageStyles.fixedCostHeaderCategoryName,
          ),
        ],
      ),
    );
  }
}
