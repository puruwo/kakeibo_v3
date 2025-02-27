import 'package:kakeibo/model/db_read_impl.dart';
import 'package:kakeibo/model/tableNameKey.dart';
import 'package:kakeibo/view_model/reference_day_impl.dart';

class CalendarBuilder {
  /// [date]が表す日が所属する月のカレンダーを生成します
  List<List<Map<String, dynamic>>> build(DateTime dt) {
    //カレンダーの日付のリスト
    //基準日の週の全ての日が含まれる
    //dynamic(DateTime,bool)
    //第二項boolはタップできるかどうかisTapable
    final calendar = <List<Map<String, dynamic>>>[];

    //設定会計周期スタート日、デフォルトは25日に設定
    const startDay = 25;

    //基準日
    final referenceDay = getReferenceDay(dt);

    // 基準日の曜日
    // 日曜日が7で表されることもあるため
    int referenceDayWeekday = referenceDay.weekday % 7;

    // 次期間の基準日
    DateTime datetimeOfNextPeriod =
        getReferenceDayOfMonth(DateTime(referenceDay.year,referenceDay.month+1,referenceDay.day).year, DateTime(referenceDay.year,referenceDay.month+1,referenceDay.day).month);

    int dayOfNextPeriodStart = datetimeOfNextPeriod.day;

    // 1週間目だけ作成
    final firstweek = List.generate(7, (index) {
      final i = index; //index==0から始まるので
      // 基準日の曜日からの差分
      final offset = referenceDayWeekday - i;

      final thisLoopDateTime = referenceDay.add(Duration(days: -offset));

      final date = thisLoopDateTime.day;
      final month = thisLoopDateTime.month;
      final year = thisLoopDateTime.year;

      //1日の合計金額を取得
      final priceSum = getExpenceOfDay(year, month, date);

      return {
        //年
        'year': year,
        //月
        'month': month,
        // 基準日の曜日より前なら基準日から差分を引いて算出
        'day': date,
        // 基準日より前ならタップできない
        'isTapable': offset <= 0 ? true : false,
        //選択状態かどうか
        'isSelected':
            dt.compareTo(DateTime(year, month, date)) == 0 ? true : false,
        //1日の合計金額
        'priceSum': priceSum,
      };
    });

    calendar.add(firstweek);

    //二週目以降の作成
    while (true) {
      final map = calendar.last.last;
      //先週の最後のdatetime
      DateTime dateOfLastWeek = DateTime(map['year'], map['month'], map['day']);

      //週の最終日が次の周期の初日より小さければ[isTapable]にすべてtrueを代入

      final week = List.generate(
        7,
        (index) {
          final i = index + 1;
          final now = dateOfLastWeek.add(Duration(days: i));

          final date = now.day;
          final month = now.month;
          final year = now.year;

          //1日の合計金額を取得
          final priceSum = getExpenceOfDay(year, month, date);

          return {
            'year': year,

            'month': month,
            
            'day': date,

            'isTapable':
                //次の基準日より前ならTapable
                now.compareTo(datetimeOfNextPeriod) == -1 ? true : false,

            //選択状態かどうか
            'isSelected':
                dt.compareTo(DateTime(year, month, date)) == 0 ? true : false,

            //1日の合計金額
            'priceSum': priceSum,
          };
        },
      );
      calendar.add(week);

      final lastDateOfWeek = calendar.last.last['day'];

      //nullチェックの記載
      if (lastDateOfWeek >= (dayOfNextPeriodStart - 1)) {
        break;
      }
    }

    return calendar;
  }

  
}

int getDayOfNextPeriodWeekday(int year, int month, int day) {
  return DateTime(year, month, day).weekday;
}

//1日の合計金額を取得
Future<int> getExpenceOfDay(int year, int month, int date) async {
  final dt = DateTime(year, month, date);

  //List<Map<String,Dynamic>>を取得
  final oneDayRecordList = await TBL001Impl().queryDayMutableRows(dt);

  int sum = 0;
  for (int i = 0; i < oneDayRecordList.length; i++) {
    //その日のrecordひとつずつのpriceを取得していく
    int price = oneDayRecordList[i][TBL001RecordKey().price];

    //足し合わせていく
    sum += price;
  }
  return sum;
}
