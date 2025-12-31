import 'package:intl/intl.dart';

import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_entity.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_repository.dart';
// import 'package:kakeibo/logger.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

DatabaseHelper db = DatabaseHelper.instance;

class ImplementsDailyExpenseRepository implements DailyExpenseRepository {
  @override
  Future<DailyExpenseEntity> fetchWithCategory(
      {required int incomeSourceBigId, required DateTime dateTime}) async {
    // 日付指定
    final whereArgs = DateFormat('yyyyMMdd').format(dateTime);

    final sql = '''
      SELECT
        date,
        SUM(price) AS totalExpense,
        SUM(incomePrice) AS totalIncome
      FROM (
        -- 通常の支出（ボーナス含む）
        SELECT
          ${SqfExpense.date} as date,
          ${SqfExpense.price} as price,
          0 AS incomePrice
        FROM ${SqfExpense.tableName}
        WHERE ${SqfExpense.date} = $whereArgs

        UNION ALL

        -- 固定費支出（確定分はprice、未確定分はestimatedPrice）
        SELECT
          ${SqfFixedCostExpense.tableName}.${SqfFixedCostExpense.date} as date,
          CASE 
            WHEN ${SqfFixedCostExpense.tableName}.${SqfFixedCostExpense.isConfirmed} = 1 THEN ${SqfFixedCostExpense.tableName}.${SqfFixedCostExpense.price}
            ELSE ${SqfFixedCost.tableName}.${SqfFixedCost.estimatedPrice}
          END as price,
          0 AS incomePrice
        FROM ${SqfFixedCostExpense.tableName}
        LEFT JOIN ${SqfFixedCost.tableName} 
          ON ${SqfFixedCostExpense.tableName}.${SqfFixedCostExpense.fixedCostId} = ${SqfFixedCost.tableName}.${SqfFixedCost.id}
        WHERE ${SqfFixedCostExpense.tableName}.${SqfFixedCostExpense.date} = $whereArgs

        UNION ALL

        -- 収入
        SELECT
          ${SqfIncome.date} as date,
          0 as price,
          ${SqfIncome.price} AS incomePrice
        FROM ${SqfIncome.tableName}
        WHERE ${SqfIncome.date} = $whereArgs
      )
      GROUP BY date
    ''';

    // 実行
    final dailyExpense = await db.query(sql);

    // logger.i('====SQLが実行されました====\n ImplementsDailyExpenseRepository\n$sql');

    // もしデータがない場合
    if (dailyExpense.isEmpty) {
      return DailyExpenseEntity(
          date: dateTime, totalExpense: 0, totalIncome: 0);
    }
    // データがある場合
    return DailyExpenseEntity.fromJson(dailyExpense.first);
  }
}
