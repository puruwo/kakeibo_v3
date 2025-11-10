import 'package:intl/intl.dart';

import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_entity.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_repository.dart';
// import 'package:kakeibo/logger.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

DatabaseHelper db = DatabaseHelper.instance;

class ImplementsDailyExpenseRepository implements DailyExpenseRepository{

  @override
  Future<DailyExpenseEntity> fetchWithCategory({required int incomeSourceBigId, required DateTime dateTime}) async {

    // 日付指定
    final whereArgs = DateFormat('yyyyMMdd').format(dateTime);

    final sql = '''
      SELECT
        date,
        SUM(price) AS totalExpense
      FROM (
        -- 通常の支出
        SELECT
          ${SqfExpense.date} as date,
          ${SqfExpense.price} as price
        FROM ${SqfExpense.tableName}
        WHERE ${SqfExpense.date} = $whereArgs
        AND ${SqfExpense.incomeSourceBigCategory} = $incomeSourceBigId

        UNION ALL

        -- 固定費支出
        SELECT
          ${SqfFixedCostExpense.date} as date,
          ${SqfFixedCostExpense.price} as price
        FROM ${SqfFixedCostExpense.tableName}
        WHERE ${SqfFixedCostExpense.date} = $whereArgs
      )
      GROUP BY date
    ''';

    // 実行
    final dailyExpense = await db.query(sql);

    // logger.i('====SQLが実行されました====\n ImplementsDailyExpenseRepository\n$sql');

    // もしデータがない場合
    if(dailyExpense.isEmpty){
      return DailyExpenseEntity(date: dateTime, totalExpense: 0);
    }
    // データがある場合
    return DailyExpenseEntity.fromJson(dailyExpense.first);

  }

  @override
  Future<Map<int, DailyExpenseEntity>> fetchMultipleSourcesWithCategory({
    required List<int> incomeSourceBigIds,
    required DateTime dateTime
  }) async {
    final whereArgs = DateFormat('yyyyMMdd').format(dateTime);
    final result = <int, DailyExpenseEntity>{};

    for (final incomeSourceBigId in incomeSourceBigIds) {
      final dailyExpense = await fetchWithCategory(
        incomeSourceBigId: incomeSourceBigId,
        dateTime: dateTime
      );
      result[incomeSourceBigId] = dailyExpense;
    }

    return result;
  }
}

  