import 'package:flutter/material.dart';
import 'package:kakeibo/theme/category_palette.dart';

/// 固定費カテゴリー専用のアイコンリスト
class FixedCostIcons {
  static const List<String> iconPathList = [
    'assets/images/icon_home.svg',
    'assets/images/icon_phone.svg',
    'assets/images/icon_subscription.svg',
    'assets/images/icon_utility.svg',
    'assets/images/icon_insurance.svg',
    'assets/images/icon_gym.svg',
    'assets/images/icon_car.svg',
    'assets/images/icon_education.svg',
    'assets/images/icon_rent.svg',
    'assets/images/icon_others.svg',
  ];
}

/// 固定費カテゴリー専用のカラーリスト（MatBlue統一）
class FixedCostColors {
  static const List<Color> colorList = [
    CategoryPalette.fixedCost,
  ];
}
