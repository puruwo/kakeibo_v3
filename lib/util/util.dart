import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

// 値段をカンマ区切りフォーマットで出力する処理

String formattedPriceGetter(int price) {
  mathFunc(Match match) => '${match[1]},';
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String stringPrice = price.toString();
  String result = stringPrice.replaceAllMapped(reg, mathFunc);
  return result;
}

String formattedPriceGetterAndZeroAsHyphen(int price) {
  if (price == 0) {
    return '---';
  }
  return formattedPriceGetter(price);
}

String yenmarkFormattedPriceGetter(int price) {
  mathFunc(Match match) => '${match[1]},';
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String stringPrice = price.toString();
  String result = stringPrice.replaceAllMapped(reg, mathFunc);
  return '¥ $result';
}

/// 符号付き¥フォーマット
/// 負: -¥ 5,400 / showPlusSign=true かつ正: +¥ 1,200 / それ以外: ¥ 0
String signedYenmarkFormattedPriceGetter(
  int price, {
  bool showPlusSign = false,
}) {
  if (price < 0) return '-${yenmarkFormattedPriceGetter(-price)}';
  if (showPlusSign && price > 0) return '+${yenmarkFormattedPriceGetter(price)}';
  return yenmarkFormattedPriceGetter(price);
}

yyyyToyyyyGetter(DateScopeEntity dateScope) {
  // 代表年（YearBasis設定に従う。デフォルトは開始年）で年度表示
  return '${dateScope.representativeYear.year}年度';
}

// 選択月の表示フォーマット取得
yyyyMMtoMMGetter(PeriodValue? monthPeriod) {
  if (monthPeriod == null) {
    return '';
  }
  final referenceDay = monthPeriod.startDatetime;
  // 基準日が月初日設定なら表示月はその月のみ
  if (referenceDay.day == 1) {
    final label = '${referenceDay.year}年 ${referenceDay.month}月';
    return label;
  }
  // 基準日が月初日以外設定なら表示月はその月とその次の月
  else {
    // 12月の次の月は1月なので分岐して処理
    if (referenceDay.month == 12) {
      final label = '${referenceDay.year}年 ${referenceDay.month} - ${1}月';
      return label;
    } else {
      final label =
          '${referenceDay.year}年 ${referenceDay.month} - ${referenceDay.month + 1}月';
      return label;
    }
  }
}
