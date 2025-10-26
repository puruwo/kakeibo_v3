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
          ${SqfExpense.incomeSourceBigCategory} INTEGER NOT NULL
          );
          ''');

    await db.execute('''
          INSERT INTO new_expense (${SqfExpense.id},${SqfExpense.expenseSmallCategoryId},${SqfExpense.date},${SqfExpense.price},${SqfExpense.memo},${SqfExpense.incomeSourceBigCategory})
          SELECT * FROM ${SqfExpense.tableName};
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

  // 固定費分離アーキテクチャへのマイグレーション (v5 → v6)
  toV6(Database db) async {
    print('=== v6マイグレーション開始: 固定費分離処理 ===');

    // 1. 新テーブル作成: fixed_cost_category
    print('1. fixed_cost_categoryテーブル作成中...');
    await db.execute('''CREATE TABLE ${SqfFixedCostCategory.tableName} (
          ${SqfFixedCostCategory.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${SqfFixedCostCategory.categoryName} TEXT NOT NULL,
          ${SqfFixedCostCategory.colorCode} TEXT NOT NULL,
          ${SqfFixedCostCategory.resourcePath} TEXT NOT NULL,
          ${SqfFixedCostCategory.displayOrder} INTEGER NOT NULL,
          ${SqfFixedCostCategory.isDisplayed} INTEGER NOT NULL
          );
          ''');

    // 固定費カテゴリーの初期データ挿入
    await db.execute('''
          INSERT INTO ${SqfFixedCostCategory.tableName} (
          ${SqfFixedCostCategory.categoryName},
          ${SqfFixedCostCategory.colorCode},
          ${SqfFixedCostCategory.resourcePath},
          ${SqfFixedCostCategory.displayOrder},
          ${SqfFixedCostCategory.isDisplayed})
          VALUES
          ('住居費', 'FF5722', 'assets/images/icon_home.svg', 0, 1),
          ('通信費', '2196F3', 'assets/images/icon_phone.svg', 1, 1),
          ('サブスク', '9C27B0', 'assets/images/icon_subscription.svg', 2, 1),
          ('光熱費', 'FFC107', 'assets/images/icon_utility.svg', 3, 1),
          ('その他', '607D8B', 'assets/images/icon_others.svg', 4, 1);
          ''');

    // 2. 新テーブル作成: fixed_cost_expense
    print('2. fixed_cost_expenseテーブル作成中...');
    await db.execute('''CREATE TABLE ${SqfFixedCostExpense.tableName} (
          ${SqfFixedCostExpense.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${SqfFixedCostExpense.fixedCostCategoryId} INTEGER NOT NULL,
          ${SqfFixedCostExpense.date} TEXT NOT NULL,
          ${SqfFixedCostExpense.price} INTEGER NOT NULL,
          ${SqfFixedCostExpense.name} TEXT,
          ${SqfFixedCostExpense.confirmedCostType} INTEGER,
          ${SqfFixedCostExpense.isConfirmed} INTEGER NOT NULL
          );
          ''');

    // 5. expenseテーブルの構造変更（fixed_cost_id と is_confirmed カラムを削除）
    print('5. expenseテーブルの構造を変更中...');

    // 新しい構造のテーブルを作成
    await db.execute('''
          CREATE TABLE expense_new (
            ${SqfExpense.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfExpense.expenseSmallCategoryId} INTEGER NOT NULL,
            ${SqfExpense.date} TEXT NOT NULL,
            ${SqfExpense.price} INTEGER NOT NULL,
            ${SqfExpense.memo} TEXT,
            ${SqfExpense.incomeSourceBigCategory} INTEGER NOT NULL
          );
          ''');

    // 残りのデータをコピー（fixed_cost_idとis_confirmedを除く）
    await db.execute('''
          INSERT INTO expense_new (
            ${SqfExpense.id},
            ${SqfExpense.expenseSmallCategoryId},
            ${SqfExpense.date},
            ${SqfExpense.price},
            ${SqfExpense.memo},
            ${SqfExpense.incomeSourceBigCategory}
          )
          SELECT
            ${SqfExpense.id},
            ${SqfExpense.expenseSmallCategoryId},
            ${SqfExpense.date},
            ${SqfExpense.price},
            ${SqfExpense.memo},
            ${SqfExpense.incomeSourceBigCategory}
          FROM ${SqfExpense.tableName};
          ''');

    // 旧テーブルを削除
    await db.execute('DROP TABLE ${SqfExpense.tableName};');

    // 新テーブルをリネーム
    await db.execute('ALTER TABLE expense_new RENAME TO ${SqfExpense.tableName};');

    print('=== v6マイグレーション完了 ===');
  }
}
