import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

var logger = Logger();

class DataBaseHelperHandling {
  funcOnCreate(Database db) async {
    await db.execute('''
          CREATE TABLE ${SqfExpense.tableName} (
            ${SqfExpense.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfExpense.expenseSmallCategoryId} INTEGER NOT NULL,
            ${SqfExpense.date} TEXT NOT NULL,
            ${SqfExpense.price} INTEGER NOT NULL,
            ${SqfExpense.memo} TEXT)
          ;
          ''');
    logger.i('${SqfExpense.tableName}が作成されました');

    await db.execute('''
          CREATE TABLE ${SqfIncome.tableName} (
            ${SqfIncome.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfIncome.incomeSmallCategoryId} INTEGER NOT NULL,
            ${SqfIncome.date} TEXT NOT NULL,
            ${SqfIncome.price} INTEGER NOT NULL,
            ${SqfIncome.memo} TEXT
          );
          ''');

    await db.execute('''
          CREATE TABLE ${SqfBudget.tableName} (
            ${SqfBudget.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfBudget.expenseBigCategoryId} INTEGER NOT NULL,
            ${SqfBudget.date} TEXT NOT NULL,
            ${SqfBudget.price} INTEGER
          );
          ''');

    await db.execute('''
          INSERT INTO ${SqfBudget.tableName}
          (${SqfBudget.id}, ${SqfBudget.expenseBigCategoryId}, ${SqfBudget.date}, ${SqfBudget.price})
          VALUES
          (0, 0, '20240101', 35000),
          (1, 1, '20240101', 5000),
          (2, 2, '20240101', 32000),
          (3, 3, '20240101', 9000),
          (4, 4, '20240101', 15000),
          (5, 5, '20240101', 0),
          (6, 6, '20240101', 5000);
          ''');

    await db.execute('''
          CREATE TABLE ${SqfExpenseSmallCategory.tableName} (
            ${SqfExpenseSmallCategory.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfExpenseSmallCategory.bigCategoryKey} INTEGER NOT NULL,
            ${SqfExpenseSmallCategory.name} TEXT NOT NULL,
            ${SqfExpenseSmallCategory.smallCategoryOrderKey} INTEGER NOT NULL,
            ${SqfExpenseSmallCategory.displayedOrderInBig} INTEGER NOT NULL,
            ${SqfExpenseSmallCategory.defaultDisplayed} INTEGER NOT NULL
          );
          ''');

    await db.execute('''
          INSERT INTO ${SqfExpenseSmallCategory.tableName} (
            ${SqfExpenseSmallCategory.id},
            ${SqfExpenseSmallCategory.bigCategoryKey},
            ${SqfExpenseSmallCategory.name},
            ${SqfExpenseSmallCategory.smallCategoryOrderKey},
            ${SqfExpenseSmallCategory.displayedOrderInBig},
            ${SqfExpenseSmallCategory.defaultDisplayed}) 
            VALUES(0, 0, '食費', 0, 0, 1),
                  (1, 0, 'コンビニ', 1, 1, 1),
                  (2, 0, '外食', 2, 2, 1),
                  (3, 0, '社食', 3, 3, 1),
                  (4, 1, '消耗品', 4, 0, 1),
                  (5, 1, '雑貨', 5, 1, 1),
                  (6, 2, '遊び', 6, 0, 1),
                  (7, 2, '飲み', 7, 1, 1),
                  (8, 2, 'ライブ', 8, 2, 1),
                  (9, 2, 'ご褒美', 9, 3, 1),
                  (10, 3, '交通費', 10, 0, 1),
                  (11, 3, '帰省', 11, 1, 1),
                  (12, 4, 'カット', 12, 0, 1),
                  (13, 5, '医療費', 13, 0, 1),
                  (14, 6, 'その他', 14, 0, 1);
          ''');

    await db.execute('''
          CREATE TABLE ${SqfExpenseBigCategory.tableName} (
            ${SqfExpenseBigCategory.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfExpenseBigCategory.name} TEXT NOT NULL,
            ${SqfExpenseBigCategory.colorCode} TEXT NOT NULL,
            ${SqfExpenseBigCategory.resourcePath} TEXT NOT NULL,
            ${SqfExpenseBigCategory.displayOrder} INTEGER NOT NULL,
            ${SqfExpenseBigCategory.isDisplayed} INTEGER NOT NULL
          )
          ;''');

    await db.execute('''
          INSERT INTO ${SqfExpenseBigCategory.tableName} (
          ${SqfExpenseBigCategory.id},
          ${SqfExpenseBigCategory.name},
          ${SqfExpenseBigCategory.colorCode},
          ${SqfExpenseBigCategory.resourcePath},
          ${SqfExpenseBigCategory.displayOrder},
          ${SqfExpenseBigCategory.isDisplayed}) 
          VALUES(0, '食費', 'FF7070', 'assets/images/icon_meal.svg', 0, 1),
                (1, '日用品', '21D19F', 'assets/images/icon_commodity.svg', 1, 1),
                (2, '遊び娯楽', 'ED112B', 'assets/images/icon_favo.svg', 2, 1),
                (3, '交通費', '2596FF', 'assets/images/icon_transportation.svg', 3, 1),
                (4, '衣服美容', 'FFC857', 'assets/images/icon_clothes.svg', 4, 1),
                (5, '医療費', 'B118C8', 'assets/images/icon_medical.svg', 5, 1),
                (6, '雑費', '3E2F5B', 'assets/images/icon_others.svg', 6, 1);
          ''');

    await db.execute('''
          CREATE TABLE ${SqfIncomeSmallCategory.tableName} (
            ${SqfIncomeSmallCategory.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfIncomeSmallCategory.bigCategoryKey} INTEGER NOT NULL,
            ${SqfIncomeSmallCategory.name} TEXT NOT NULL,
            ${SqfIncomeSmallCategory.smallCategoryOrderKey} INTEGER NOT NULL,
            ${SqfIncomeSmallCategory.displayedOrderInBig} INTEGER NOT NULL,
            ${SqfIncomeSmallCategory.defaultDisplayed} INTEGER NOT NULL
          );
          ''');

    await db.execute('''
          INSERT INTO ${SqfIncomeSmallCategory.tableName} (
            ${SqfIncomeSmallCategory.id},
            ${SqfIncomeSmallCategory.bigCategoryKey},
            ${SqfIncomeSmallCategory.name},
            ${SqfIncomeSmallCategory.smallCategoryOrderKey},
            ${SqfIncomeSmallCategory.displayedOrderInBig},
            ${SqfIncomeSmallCategory.defaultDisplayed}) 
            VALUES(0, 0, '給与', 0, 0, 1),
                  (1, 1, 'ボーナス', 1, 1, 1),
                  (2, 1, '小遣い', 2, 2, 1),
                  (3, 1, '臨時収入', 3, 3, 1);
          ''');

    await db.execute('''
          CREATE TABLE ${SqfIncomeBigCategory.tableName} (
            ${SqfIncomeBigCategory.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfIncomeBigCategory.name} TEXT NOT NULL,
            ${SqfIncomeBigCategory.colorCode} TEXT NOT NULL,
            ${SqfIncomeBigCategory.resourcePath} TEXT NOT NULL,
            ${SqfIncomeBigCategory.displayOrder} INTEGER NOT NULL,
            ${SqfIncomeBigCategory.isDisplayed} INTEGER NOT NULL
          )
          ;''');

    await db.execute('''
          INSERT INTO ${SqfIncomeBigCategory.tableName} (
          ${SqfIncomeBigCategory.id},
          ${SqfIncomeBigCategory.name},
          ${SqfIncomeBigCategory.colorCode},
          ${SqfIncomeBigCategory.resourcePath},
          ${SqfIncomeBigCategory.displayOrder},
          ${SqfIncomeBigCategory.isDisplayed}) 
          VALUES
          (0, '定期収入', 'FFC857', 'assets/images/icon_regular_income.svg', 0, 1),
          (1, '臨時収入', 'ECB22D', 'assets/images/icon_extra_income.svg', 1, 1);
          ''');

    
  }

  funcOnUpdate(Database db) async {
    // print('データベースの更新処理が呼び出されました');
  }
}
