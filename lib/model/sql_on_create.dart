import 'package:flutter/foundation.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/model/debug_seeder.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/theme/category_palette.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelperHandling {
  funcOnCreate(Database db) async {
    await db.execute('''
          CREATE TABLE ${SqfExpense.tableName} (
            ${SqfExpense.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfExpense.expenseSmallCategoryId} INTEGER NOT NULL,
            ${SqfExpense.date} TEXT NOT NULL,
            ${SqfExpense.price} INTEGER NOT NULL,
            ${SqfExpense.memo} TEXT,
            ${SqfExpense.incomeSourceBigCategory} INTEGER NOT NULL
            )
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
            ${SqfBudget.month} TEXT NOT NULL,
            ${SqfBudget.price} INTEGER
          );
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
            ${SqfExpenseSmallCategory.bigCategoryKey},
            ${SqfExpenseSmallCategory.name},
            ${SqfExpenseSmallCategory.smallCategoryOrderKey},
            ${SqfExpenseSmallCategory.displayedOrderInBig},
            ${SqfExpenseSmallCategory.defaultDisplayed}) 
            VALUES(1, '食費', 0, 0, 1),
                  (1, 'コンビニ', 1, 1, 1),
                  (1, '外食', 2, 2, 1),
                  (1, '社食', 3, 3, 1),
                  (2, '消耗品', 4, 0, 1),
                  (2, '雑貨', 5, 1, 1),
                  (3, '遊び', 6, 0, 1),
                  (3, '飲み', 7, 1, 1),
                  (3, 'ライブ', 8, 2, 1),
                  (3, 'ご褒美', 9, 3, 1),
                  (4, '交通費', 10, 0, 1),
                  (4, '帰省', 11, 1, 1),
                  (5, 'カット', 12, 0, 1),
                  (6, '医療費', 13, 0, 1),
                  (7, 'その他', 14, 0, 1);
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
          ${SqfExpenseBigCategory.name},
          ${SqfExpenseBigCategory.colorCode},
          ${SqfExpenseBigCategory.resourcePath},
          ${SqfExpenseBigCategory.displayOrder},
          ${SqfExpenseBigCategory.isDisplayed}) 
          VALUES('食費', '${CategoryPalette.expense1Hex}', 'assets/images/icon_meal.svg', 0, 1),
                ('日用品', '${CategoryPalette.expense2Hex}', 'assets/images/icon_commodity.svg', 1, 1),
                ('遊び娯楽', '${CategoryPalette.expense3Hex}', 'assets/images/icon_favo.svg', 2, 1),
                ('交通費', '${CategoryPalette.expense4Hex}', 'assets/images/icon_transportation.svg', 3, 1),
                ('衣服美容', '${CategoryPalette.expense5Hex}', 'assets/images/icon_clothes.svg', 4, 1),
                ('医療費', '${CategoryPalette.expense6Hex}', 'assets/images/icon_medical.svg', 5, 1),
                ('雑費', '${CategoryPalette.expense7Hex}', 'assets/images/icon_others.svg', 6, 1);
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
            ${SqfIncomeSmallCategory.bigCategoryKey},
            ${SqfIncomeSmallCategory.name},
            ${SqfIncomeSmallCategory.smallCategoryOrderKey},
            ${SqfIncomeSmallCategory.displayedOrderInBig},
            ${SqfIncomeSmallCategory.defaultDisplayed}) 
            VALUES(1, '給与', 0, 0, 1),
                  (2, 'ボーナス', 1, 1, 1),
                  (1, '小遣い', 2, 2, 1),
                  (1, '臨時収入', 3, 3, 1);
          ''');

    await db.execute('''
          CREATE TABLE ${SqfIncomeBigCategory.tableName} (
            ${SqfIncomeBigCategory.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfIncomeBigCategory.name} TEXT NOT NULL,
            ${SqfIncomeBigCategory.colorCode} TEXT NOT NULL,
            ${SqfIncomeBigCategory.resourcePath} TEXT NOT NULL,
            ${SqfIncomeBigCategory.accountType} INTEGER NOT NULL DEFAULT 1
          )
          ;''');

    // account_type: 1=生活収支, 2=特別枠（ADR-025）
    await db.execute('''
          INSERT INTO ${SqfIncomeBigCategory.tableName} (
          ${SqfIncomeBigCategory.name},
          ${SqfIncomeBigCategory.colorCode},
          ${SqfIncomeBigCategory.resourcePath},
          ${SqfIncomeBigCategory.accountType})
          VALUES
          ('月次収入', '${CategoryPalette.income1Hex}', 'assets/images/icon_regular_income.svg', 1),
          ('ボーナス', '${CategoryPalette.income2Hex}', 'assets/images/icon_extra_income.svg', 2);
          ''');

    await db.execute('''CREATE TABLE ${SqfFixedCost.tableName} (
          ${SqfFixedCost.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${SqfFixedCost.name} TEXT NOT NULL,
          ${SqfFixedCost.variable} INTEGER NOT NULL,
          ${SqfFixedCost.price} INTEGER,
          ${SqfFixedCost.estimatedPrice} INTEGER,
          ${SqfFixedCost.fixedCostCategoryId} INTEGER NOT NULL,
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

    // バッチ実行履歴の初期レコード
    // 「インストール日を含む集計期間の開始日前日」を実行済み最終日として記録し、
    // 初回バッチがインストール日以降の期間のみを生成するようにする
    // （初回起動時点では集計開始日は必ず既定値のため、既定値25日で計算する）
    const defaultAggregationStartDay = 25;
    final now = DateTime.now();
    final currentPeriodStart = now.day >= defaultAggregationStartDay
        ? DateTime(now.year, now.month, defaultAggregationStartDay)
        : DateTime(now.year, now.month - 1, defaultAggregationStartDay);
    final initialBatchProcessedDate = currentPeriodStart
        .add(const Duration(days: -1))
        .toFormattedString();
    await db.execute('''
          INSERT INTO ${SqfBatchHistory.tableName} (
          ${SqfBatchHistory.startDate},
          ${SqfBatchHistory.endDate},
          ${SqfBatchHistory.status})
          VALUES
          ('$initialBatchProcessedDate', '$initialBatchProcessedDate', 1);
          ''');

    await db.execute('''CREATE TABLE ${SqfFixedCostExpense.tableName} (
          ${SqfFixedCostExpense.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${SqfFixedCostExpense.fixedCostId} INTEGER NOT NULL,
          ${SqfFixedCostExpense.fixedCostCategoryId} INTEGER NOT NULL,
          ${SqfFixedCostExpense.date} TEXT NOT NULL,
          ${SqfFixedCostExpense.price} INTEGER NOT NULL,
          ${SqfFixedCostExpense.name} TEXT NOT NULL,
          ${SqfFixedCostExpense.confirmedCostType} INTEGER NOT NULL,
          ${SqfFixedCostExpense.isConfirmed} INTEGER NOT NULL
          );
          ''');

    await db.execute('''CREATE TABLE ${SqfFixedCostCategory.tableName} (
          ${SqfFixedCostCategory.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${SqfFixedCostCategory.categoryName} TEXT NOT NULL,
          ${SqfFixedCostCategory.colorCode} TEXT NOT NULL,
          ${SqfFixedCostCategory.resourcePath} TEXT NOT NULL,
          ${SqfFixedCostCategory.displayOrder} INTEGER NOT NULL,
          ${SqfFixedCostCategory.isDisplayed} INTEGER NOT NULL
          );
          ''');

    await db.execute('''
          INSERT INTO ${SqfFixedCostCategory.tableName} (
          ${SqfFixedCostCategory.categoryName},
          ${SqfFixedCostCategory.colorCode},
          ${SqfFixedCostCategory.resourcePath},
          ${SqfFixedCostCategory.displayOrder},
          ${SqfFixedCostCategory.isDisplayed})
          VALUES
          ('住居費', '${CategoryPalette.fixedCostHex}', 'assets/images/icon_home.svg', 0, 1),
          ('サブスク', '${CategoryPalette.fixedCostHex}', 'assets/images/icon_subscription.svg', 1, 1),
          ('通信費', '${CategoryPalette.fixedCostHex}', 'assets/images/icon_cell_tower.svg', 2, 1),
          ('光熱費', '${CategoryPalette.fixedCostHex}', 'assets/images/icon_water_drop.svg', 3, 1),
          ('その他', '${CategoryPalette.fixedCostHex}', 'assets/images/icon_others.svg', 4, 1);
          ''');

    // 開発用モックデータ（デバッグビルド限定）
    // リリースビルドの新規インストールはカテゴリーマスタのみの空状態で開始する
    if (kDebugMode && DebugSeeder.enabled) {
      await DebugSeeder().insert(db);
    }
  }
}
