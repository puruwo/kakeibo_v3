import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseMigrate {

  // 固定費機能追加のためのマイグレーション
  toV3(Database db) async {
    await db.execute('''CREATE TABLE ${SqfFixedCost.tableName} (
          ${SqfFixedCost.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${SqfFixedCost.name} TEXT NOT NULL,
          ${SqfFixedCost.variable} INTEGER NOT NULL,
          ${SqfFixedCost.price} INTEGER,
          ${SqfFixedCost.estimatedPrice} INTEGER,
          ${SqfFixedCost.expenseSmallCategoryId} INTEGER NOT NULL,
          ${SqfFixedCost.intervalNumber} INTEGER NOT NULL,
          ${SqfFixedCost.intervalUnit} INTEGER NOT NULL,
          ${SqfFixedCost.firstPaymentDate} TEXT NOT NULL,
          ${SqfFixedCost.recentPaymentDate} TEXT,
          ${SqfFixedCost.nextPaymentDate} TEXT NOT NULL,
          ${SqfFixedCost.deleteFlag} INTEGER NOT NULL
          );
          ''');

    await db.execute('''CREATE TABLE ${SqfBatchHistory.tableName} (
          ${SqfBatchHistory.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${SqfBatchHistory.startDate} TEXT NOT NULL,
          ${SqfBatchHistory.endDate} TEXT NOT NULL,
          ${SqfBatchHistory.status} INTEGER NOT NULL
          );
          ''');

    await db.execute('''
          INSERT INTO ${SqfBatchHistory.tableName} (
          ${SqfBatchHistory.startDate},
          ${SqfBatchHistory.endDate},
          ${SqfBatchHistory.status})
          VALUES
          ('20250401', '${DateTime.now().toFormattedString()}', 1);
          ''');

    await db.execute('''
          CREATE TABLE new_expense (
          ${SqfExpense.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${SqfExpense.expenseSmallCategoryId} INTEGER NOT NULL,
          ${SqfExpense.date} TEXT NOT NULL,
          ${SqfExpense.price} INTEGER NOT NULL,
          ${SqfExpense.memo} TEXT,
          ${SqfExpense.incomeSourceBigCategory} INTEGER NOT NULL,
          ${SqfExpense.fixedCostId} INTEGER,
          ${SqfExpense.isConfirmed} INTEGER NOT NULL DEFAULT 1
          );
          ''');

    await db.execute('''
          INSERT INTO new_expense (${SqfExpense.id},${SqfExpense.expenseSmallCategoryId},${SqfExpense.date},${SqfExpense.price},${SqfExpense.memo},${SqfExpense.incomeSourceBigCategory},${SqfExpense.isConfirmed})
          SELECT *, 1 FROM ${SqfExpense.tableName};
          ''');

    await db.execute('''
          DROP TABLE ${SqfExpense.tableName};
          ALTER TABLE new_expense RENAME TO ${SqfExpense.tableName}
          ''');
  }

  toV5(Database db) async {
    await db.execute('''
          ALTER TABLE new_expense RENAME TO ${SqfExpense.tableName};
          ''');
  }
}
