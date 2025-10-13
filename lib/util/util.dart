import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/view_model/reference_day_impl.dart';

// 値段をカンマ区切りフォーマットで出力する処理

String formattedPriceGetter(int price) {
  mathFunc(Match match) => '${match[1]},';
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String stringPrice = price.toString();
  String result = stringPrice.replaceAllMapped(reg, mathFunc);
  return result;
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
  return '$result 円';
}

yyyyMMtoMMGetter(DateTime activeDt) {
  final referenceDay = getReferenceDay(activeDt);
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

yyyyToyyyyGetter(DateScopeEntity dateScope) {

  final startDate = dateScope.yearPeriod.startDatetime;  
  final endDate = dateScope.yearPeriod.endDatetime;  

  // 年のまたぎがない場合は、年のみ表示
  if (startDate.year == endDate.year) {
      final label = '${startDate.year}年';
      return label;
  }
  else {
      final label = '${startDate.year}年 - ${endDate.year}年';
      return label; 
  }
}
