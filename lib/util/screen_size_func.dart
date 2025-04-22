/// Package imports
import 'dart:math';

/// Local imports
import 'package:kakeibo/constant/properties.dart';

double screenWidthGetter(){
  return ScreenLayoutProperties().defaultWidth.toDouble();
}

/// 画面の倍率を計算
/// iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
double screenHorizontalMagnificationGetter(double screenWidthSize) {
    if (screenWidthSize <= 375) {
      return 1.0;
    } else if (screenWidthSize <= 430) {
      return screenWidthSize / ScreenLayoutProperties().defaultWidth;
    } else {
      return 430.0 / ScreenLayoutProperties().defaultWidth;
    }
  }

double screenVerticalMagnificationGetter(
    double screenWidthSize, double screenHorizontalMagnification) {
  if (screenHorizontalMagnification >= 1.0) {
    // y=x^0.8
    return pow(screenHorizontalMagnification, 0.8) as double;
  }else{
    return 1.0;
  }
}