import 'package:kakeibo/logger.dart';
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
    await db
        .execute('ALTER TABLE expense_new RENAME TO ${SqfExpense.tableName};');

    print('=== v6マイグレーション完了 ===');
  }

  // カテゴリーカラー刷新のマイグレーション (v6 → v7)
  toV7(Database db) async {
    print('=== v7マイグレーション開始: カテゴリーカラー更新 ===');

    // 支出大カテゴリーのカラー更新
    await db.execute("UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = 'FF7171' WHERE ${SqfExpenseBigCategory.id} = 1;"); // 食費
    await db.execute("UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = 'FB5B01' WHERE ${SqfExpenseBigCategory.id} = 2;"); // 日用品
    await db.execute("UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = '3DD8E0' WHERE ${SqfExpenseBigCategory.id} = 3;"); // 遊び娯楽
    await db.execute("UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = '4BA6FF' WHERE ${SqfExpenseBigCategory.id} = 4;"); // 交通費
    await db.execute("UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = 'BB87FF' WHERE ${SqfExpenseBigCategory.id} = 5;"); // 衣服美容
    await db.execute("UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = 'DF2828' WHERE ${SqfExpenseBigCategory.id} = 6;"); // 医療費
    await db.execute("UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = 'FFC700' WHERE ${SqfExpenseBigCategory.id} = 7;"); // 雑費

    // 固定費カテゴリーのカラーを全て統一（MatBlue）
    await db.execute("UPDATE ${SqfFixedCostCategory.tableName} SET ${SqfFixedCostCategory.colorCode} = '8E8E93';");

    // 収入大カテゴリーのカラー更新
    await db.execute("UPDATE ${SqfIncomeBigCategory.tableName} SET ${SqfIncomeBigCategory.colorCode} = '21D19F' WHERE ${SqfIncomeBigCategory.id} = 1;"); // 月次収入
    await db.execute("UPDATE ${SqfIncomeBigCategory.tableName} SET ${SqfIncomeBigCategory.colorCode} = '10B981' WHERE ${SqfIncomeBigCategory.id} = 2;"); // ボーナス

    print('=== v7マイグレーション完了 ===');
  }

  // スキーマ負債解消のマイグレーション (v7 → v8)
  Future<void> toV8(Database db) async {
    logger.i('=== v8マイグレーション開始: スキーマ負債解消 ===');

    // 1. fixed_cost: タイポしていたカラム名 fiirst_payment_date を first_payment_date へ改名
    //    既存マイグレーションに合わせてテーブル再作成方式で行う
    logger.i('1. ${SqfFixedCost.tableName}のカラム名を修正中...');
    await db.execute('''CREATE TABLE fixed_cost_new (
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

    await db.execute('''
          INSERT INTO fixed_cost_new (
            ${SqfFixedCost.id},
            ${SqfFixedCost.name},
            ${SqfFixedCost.variable},
            ${SqfFixedCost.price},
            ${SqfFixedCost.estimatedPrice},
            ${SqfFixedCost.fixedCostCategoryId},
            ${SqfFixedCost.intervalNumber},
            ${SqfFixedCost.intervalUnit},
            ${SqfFixedCost.firstPaymentDate},
            ${SqfFixedCost.recentPaymentDate},
            ${SqfFixedCost.nextPaymentDate},
            ${SqfFixedCost.deleteFlag}
          )
          SELECT
            ${SqfFixedCost.id},
            ${SqfFixedCost.name},
            ${SqfFixedCost.variable},
            ${SqfFixedCost.price},
            ${SqfFixedCost.estimatedPrice},
            ${SqfFixedCost.fixedCostCategoryId},
            ${SqfFixedCost.intervalNumber},
            ${SqfFixedCost.intervalUnit},
            fiirst_payment_date,
            ${SqfFixedCost.recentPaymentDate},
            ${SqfFixedCost.nextPaymentDate},
            ${SqfFixedCost.deleteFlag}
          FROM ${SqfFixedCost.tableName};
          ''');

    await db.execute('DROP TABLE ${SqfFixedCost.tableName};');
    await db.execute(
        'ALTER TABLE fixed_cost_new RENAME TO ${SqfFixedCost.tableName};');

    // 2. fixed_cost_expense: v6マイグレーション経由の端末には fixed_cost_id 列が
    //    存在しない（v7以降の新規インストールには存在する）ため、検査して補完する
    logger.i('2. ${SqfFixedCostExpense.tableName}のfixed_cost_id列を検査中...');
    final columns = await db
        .rawQuery('PRAGMA table_info(${SqfFixedCostExpense.tableName})');
    final hasFixedCostId = columns
        .any((column) => column['name'] == SqfFixedCostExpense.fixedCostId);

    if (hasFixedCostId) {
      logger.i('2-1. fixed_cost_id列は既に存在するためスキップ');
    } else {
      logger.i('2-1. fixed_cost_id列が無いため追加・補完します');
      await db.execute(
          'ALTER TABLE ${SqfFixedCostExpense.tableName} ADD COLUMN ${SqfFixedCostExpense.fixedCostId} INTEGER;');

      // 名前と固定費カテゴリーの一致でマスタと突合して補完する
      // （支払実績の日付はマスタ側の支払日と一致しないため突合キーに使わない）
      await db.execute('''
          UPDATE ${SqfFixedCostExpense.tableName}
          SET ${SqfFixedCostExpense.fixedCostId} = (
            SELECT fc.${SqfFixedCost.id}
            FROM ${SqfFixedCost.tableName} fc
            WHERE fc.${SqfFixedCost.name} = ${SqfFixedCostExpense.tableName}.${SqfFixedCostExpense.name}
              AND fc.${SqfFixedCost.fixedCostCategoryId} = ${SqfFixedCostExpense.tableName}.${SqfFixedCostExpense.fixedCostCategoryId}
            LIMIT 1
          )
          WHERE ${SqfFixedCostExpense.fixedCostId} IS NULL;
          ''');

      // 突合できなかったレコードはNULLのまま保持し、件数だけログに残す
      final unresolved = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM ${SqfFixedCostExpense.tableName} WHERE ${SqfFixedCostExpense.fixedCostId} IS NULL'));
      logger.i('2-2. 突合できなかった固定費支出: $unresolved件');
    }

    logger.i('=== v8マイグレーション完了 ===');
  }
}
