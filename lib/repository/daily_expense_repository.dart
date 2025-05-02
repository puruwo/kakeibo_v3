import 'package:intl/intl.dart';

import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_entity.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_repository.dart';
import 'package:kakeibo/model/database_helper.dart';

DatabaseHelper db = DatabaseHelper.instance;

class ImplementsDailyExpenseRepository implements DailyExpenseRepository{

  @override
  Future<DailyExpenseEntity> fetch({required DateTime dateTime}) async {

    // 日付指定
    final whereArgs = DateFormat('yyyyMMdd').format(dateTime);

    final sql = '''
      SELECT 
        date,
        SUM(price) AS totalExpense
      FROM TBL001
      WHERE date = $whereArgs
      GROUP BY date
    ''';

    // 実行
    final dailyExpense = await db.query(sql);
    
    // もしデータがない場合
    if(dailyExpense.isEmpty){
      return DailyExpenseEntity(date: dateTime, totalExpense: 0);
    }
    // データがある場合
    return DailyExpenseEntity.fromJson(dailyExpense.first);
  
  }
}

  