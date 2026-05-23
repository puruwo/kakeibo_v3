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

String yenFormattedPriceGetter(int price) {
  mathFunc(Match match) => '${match[1]},';
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String stringPrice = price.toString();
  String result = stringPrice.replaceAllMapped(reg, mathFunc);
  return '¥$result';
}

yyyyToyyyyGetter(DateScopeEntity dateScope) {
  final startDate = dateScope.yearPeriod.startDatetime;
  final endDate = dateScope.yearPeriod.endDatetime;

  // 年のまたぎがない場合は、年のみ表示
  if (startDate.year == endDate.year) {
    final label = '${startDate.year}年';
    return label;
  } else {
    final label = '${startDate.year}年 - ${endDate.year}年';
    return label;
  }
}

// 選択月の表示フォーマット取得
// 集計期間の開始月（集計開始日を含む月）を「yyyy年 m月」形式で返す
yyyyMMtoMMGetter(PeriodValue? monthPeriod) {
  if (monthPeriod == null) {
    return '';
  }
  final referenceDay = monthPeriod.startDatetime;
  return '${referenceDay.year}年 ${referenceDay.month}月';
}
