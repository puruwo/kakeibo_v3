import 'package:intl/intl.dart';

import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_entity.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_repository.dart';
// import 'package:kakeibo/logger.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

DatabaseHelper db = DatabaseHelper.instance;

class ImplementsDailyExpenseRepository implements DailyExpenseRepository {
  @override
  Future<List<DailyExpenseEntity>> fetchDailyTotalsByPeriod({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    // 期間指定（yyyyMMddの固定長数字なので大小比較が日付順と一致する）
    final fromArgs = DateFormat('yyyyMMdd').format(fromDate);
    final toArgs = DateFormat('yyyyMMdd').format(toDate);

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
        WHERE ${SqfExpense.date} >= $fromArgs AND ${SqfExpense.date} <= $toArgs

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
        WHERE ${SqfFixedCostExpense.tableName}.${SqfFixedCostExpense.date} >= $fromArgs AND ${SqfFixedCostExpense.tableName}.${SqfFixedCostExpense.date} <= $toArgs

        UNION ALL

        -- 収入
        SELECT
          ${SqfIncome.date} as date,
          0 as price,
          ${SqfIncome.price} AS incomePrice
        FROM ${SqfIncome.tableName}
        WHERE ${SqfIncome.date} >= $fromArgs AND ${SqfIncome.date} <= $toArgs
      )
      GROUP BY date
    ''';

    // 実行
    final dailyExpenseList = await db.query(sql);

    // logger.i('====SQLが実行されました====\n ImplementsDailyExpenseRepository\n$sql');

    return dailyExpenseList.map(DailyExpenseEntity.fromJson).toList();
  }
}
