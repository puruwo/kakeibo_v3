import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kakeibo/constant/properties.dart';

extension MediaQueryExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// 画面の倍率を計算
  /// iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
  double get screenHorizontalMagnification {
    if (screenWidth <= 375) {
      return 1.0;
    } else if (screenWidth <= 430) {
      return screenWidth / ScreenLayoutProperties().defaultWidth;
    } else {
      return 430.0 / ScreenLayoutProperties().defaultWidth;
    }
  }

  double get screenVerticalMagnification{
    if (screenHorizontalMagnification >= 1.0) {
      // y=x^0.8
      return pow(screenHorizontalMagnification, 0.8) as double;
    } else {
      return 1.0;
    }
  }

  // リスト内テキストボックスの倍率を計算
  // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
  double get listSmallcategoryMemoOffset {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return screenWidth - defaultWidth;
  }

  // カレンダーサイズから左の空白の大きさを計算
  double get leftsidePadding {
    return 14.5 * screenHorizontalMagnification;
  }
}
