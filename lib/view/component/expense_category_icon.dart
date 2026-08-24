import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';

/// カテゴリーアイコン（SVG）を色付きで表示する共通部品
///
/// 固定費の設定画面・トップの固定費ミニカード・支出一覧などで使う。
class ExpenseCategoryIcon extends StatelessWidget {
  const ExpenseCategoryIcon({
    super.key,
    required this.resourcePath,
    required this.colorCode,
    this.size = kAppInsetRowIconSize,
  });

  final String resourcePath;
  final String colorCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (resourcePath.isEmpty) {
      return SizedBox(width: size, height: size);
    }
    return SvgPicture.asset(
      resourcePath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        ColorCode.toColor(colorCode),
        BlendMode.srcIn,
      ),
    );
  }
}
