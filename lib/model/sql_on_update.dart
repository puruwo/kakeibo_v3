import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/theme/category_palette.dart';
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
    await db.execute(
      'ALTER TABLE expense_new RENAME TO ${SqfExpense.tableName};',
    );

    print('=== v6マイグレーション完了 ===');
  }

  // カテゴリーカラー刷新のマイグレーション (v6 → v7)
  toV7(Database db) async {
    print('=== v7マイグレーション開始: カテゴリーカラー更新 ===');

    // 支出大カテゴリーのカラー更新
    await db.execute(
      "UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = 'FF7171' WHERE ${SqfExpenseBigCategory.id} = 1;",
    ); // 食費
    await db.execute(
      "UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = 'FB5B01' WHERE ${SqfExpenseBigCategory.id} = 2;",
    ); // 日用品
    await db.execute(
      "UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = '3DD8E0' WHERE ${SqfExpenseBigCategory.id} = 3;",
    ); // 遊び娯楽
    await db.execute(
      "UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = '4BA6FF' WHERE ${SqfExpenseBigCategory.id} = 4;",
    ); // 交通費
    await db.execute(
      "UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = 'BB87FF' WHERE ${SqfExpenseBigCategory.id} = 5;",
    ); // 衣服美容
    await db.execute(
      "UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = 'DF2828' WHERE ${SqfExpenseBigCategory.id} = 6;",
    ); // 医療費
    await db.execute(
      "UPDATE ${SqfExpenseBigCategory.tableName} SET ${SqfExpenseBigCategory.colorCode} = 'FFC700' WHERE ${SqfExpenseBigCategory.id} = 7;",
    ); // 雑費

    // 固定費カテゴリーのカラーを全て統一（MatBlue）
    await db.execute(
      "UPDATE ${SqfFixedCostCategory.tableName} SET ${SqfFixedCostCategory.colorCode} = '8E8E93';",
    );

    // 収入大カテゴリーのカラー更新
    await db.execute(
      "UPDATE ${SqfIncomeBigCategory.tableName} SET ${SqfIncomeBigCategory.colorCode} = '21D19F' WHERE ${SqfIncomeBigCategory.id} = 1;",
    ); // 月次収入
    await db.execute(
      "UPDATE ${SqfIncomeBigCategory.tableName} SET ${SqfIncomeBigCategory.colorCode} = '10B981' WHERE ${SqfIncomeBigCategory.id} = 2;",
    ); // ボーナス

    print('=== v7マイグレーション完了 ===');
  }

  // スキーマ負債解消のマイグレーション (v7 → v8)
  Future<void> toV8(Database db) async {
    logger.i('=== v8マイグレーション開始: スキーマ負債解消 ===');

    // 1. fixed_cost: タイポしていたカラム名 fiirst_payment_date を first_payment_date へ改名
    //    既存マイグレーションに合わせてテーブル再作成方式で行う。
    //    ただし、定数修正後かつv8バージョンbump前のビルドでDBが作成された端末は
    //    最初から正しい first_payment_date を持つため、タイポ版カラムの有無を検査し
    //    存在する場合のみ改名処理を行う（存在しない端末でのクラッシュを回避）。
    logger.i('1. ${SqfFixedCost.tableName}のカラム名を検査中...');
    final fixedCostColumns = await db.rawQuery(
      'PRAGMA table_info(${SqfFixedCost.tableName})',
    );
    final hasTypoPaymentDate = fixedCostColumns.any(
      (column) => column['name'] == 'fiirst_payment_date',
    );

    if (!hasTypoPaymentDate) {
      logger.i('1-1. 既に${SqfFixedCost.firstPaymentDate}のため改名をスキップ');
    } else {
      logger.i('1-1. タイポ版カラムが存在するため改名します');
      // 過去の中断で残骸テーブルがあっても再実行に耐えるよう先にDROPする
      await db.execute('DROP TABLE IF EXISTS fixed_cost_new;');
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
        'ALTER TABLE fixed_cost_new RENAME TO ${SqfFixedCost.tableName};',
      );
    }

    // 2. fixed_cost_expense: v6マイグレーション経由の端末には fixed_cost_id 列が
    //    存在しない（v7以降の新規インストールには存在する）ため、検査して補完する
    logger.i('2. ${SqfFixedCostExpense.tableName}のfixed_cost_id列を検査中...');
    final columns = await db.rawQuery(
      'PRAGMA table_info(${SqfFixedCostExpense.tableName})',
    );
    final hasFixedCostId = columns.any(
      (column) => column['name'] == SqfFixedCostExpense.fixedCostId,
    );

    if (hasFixedCostId) {
      logger.i('2-1. fixed_cost_id列は既に存在するためスキップ');
    } else {
      logger.i('2-1. fixed_cost_id列が無いため追加・補完します');
      await db.execute(
        'ALTER TABLE ${SqfFixedCostExpense.tableName} ADD COLUMN ${SqfFixedCostExpense.fixedCostId} INTEGER;',
      );

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
      final unresolved = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM ${SqfFixedCostExpense.tableName} WHERE ${SqfFixedCostExpense.fixedCostId} IS NULL',
        ),
      );
      logger.i('2-2. 突合できなかった固定費支出: $unresolved件');
    }

    logger.i('=== v8マイグレーション完了 ===');
  }

  // 収入大カテゴリーへの会計種別導入マイグレーション (v8 → v9)
  // ADR-025: 集計スコープをカテゴリーID（1/2）決め打ちから
  // カテゴリーごとの会計種別（1=生活収支, 2=特別枠）に変更する
  Future<void> toV9(Database db) async {
    logger.i('=== v9マイグレーション開始: 会計種別（account_type）導入 ===');

    // 中断・再実行に耐えるよう、列の有無を検査してから追加する
    logger.i('1. ${SqfIncomeBigCategory.tableName}のaccount_type列を検査中...');
    final columns = await db.rawQuery(
      'PRAGMA table_info(${SqfIncomeBigCategory.tableName})',
    );
    final hasAccountType = columns.any(
      (column) => column['name'] == SqfIncomeBigCategory.accountType,
    );

    if (hasAccountType) {
      logger.i('1-1. account_type列は既に存在するためスキップ');
    } else {
      logger.i('1-1. account_type列を追加します（デフォルト=生活収支）');
      await db.execute(
        'ALTER TABLE ${SqfIncomeBigCategory.tableName} ADD COLUMN ${SqfIncomeBigCategory.accountType} INTEGER NOT NULL DEFAULT 1;',
      );

      // 既定カテゴリー「ボーナス(id=2)」のみ特別枠に設定する
      // （id=1「月次収入」およびユーザー追加済みのid=3以降はデフォルトの生活収支のまま。
      //   従来id=3以降はどの集計にも属さない孤児だったため、生活収支への編入が最も安全）
      await db.execute(
        'UPDATE ${SqfIncomeBigCategory.tableName} SET ${SqfIncomeBigCategory.accountType} = 2 WHERE ${SqfIncomeBigCategory.id} = 2;',
      );
    }

    logger.i('=== v9マイグレーション完了 ===');
  }

  // 固定費カテゴリー統合のマイグレーション (v9 → v10) 第1段階
  //
  // 仕様書 §4・§5（固定費カテゴリー統合_仕様書.html）の手順1・2までを実施する。
  // 手順3（fixed_cost_expense → expense の実績移行）と手順4（旧2テーブルDROP）は
  // T6 で本関数に追記する。そのため fixed_cost_category_id 列・旧2テーブルは残す。
  //
  // 注意: onUpgrade は既にトランザクション内で呼ばれるため、
  // ここでは db.transaction() や DatabaseHelper 経由のリポジトリを使わず、
  // 引数の db に対する raw SQL のみで書く（既存 toV6〜toV9 と同じ作法）。
  Future<void> toV10(Database db) async {
    logger.i('=== v10マイグレーション開始: 固定費カテゴリー統合（第1段階） ===');

    await _migrateExpenseTableToV10(db);
    await _moveFixedCostCategoryToExpenseCategory(db);

    logger.i('=== v10マイグレーション完了（第1段階） ===');
  }

  /// v10-1: expense をテーブル再作成方式で新定義へ移行する
  ///
  /// - price を NULL 許容化（実額のみを格納。未確定固定費の間は NULL）
  /// - fixed_cost_id / is_confirmed / estimated_price を追加
  /// - 既存行は全列コピーし、通常支出として is_confirmed=1 を立てる
  Future<void> _migrateExpenseTableToV10(Database db) async {
    logger.i('1. ${SqfExpense.tableName}の列構成を検査中...');
    final expenseColumns = await db.rawQuery(
      'PRAGMA table_info(${SqfExpense.tableName})',
    );
    final expenseColumnNames = expenseColumns
        .map((column) => column['name'] as String)
        .toSet();
    // 3列すべてが揃っていれば移行済みとみなす（2回実行しても壊れないようにする）
    final alreadyMigrated =
        expenseColumnNames.contains(SqfExpense.fixedCostId) &&
        expenseColumnNames.contains(SqfExpense.isConfirmed) &&
        expenseColumnNames.contains(SqfExpense.estimatedPrice);

    if (alreadyMigrated) {
      logger.i('1-1. ${SqfExpense.tableName}は移行済みのためスキップ');
      return;
    }

    logger.i('1-1. ${SqfExpense.tableName}を再作成します');
    // 過去の中断で残骸テーブルがあっても再実行に耐えるよう先にDROPする
    await db.execute('DROP TABLE IF EXISTS expense_v10_new;');
    await db.execute('''
          CREATE TABLE expense_v10_new (
            ${SqfExpense.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${SqfExpense.expenseSmallCategoryId} INTEGER NOT NULL,
            ${SqfExpense.date} TEXT NOT NULL,
            ${SqfExpense.price} INTEGER,
            ${SqfExpense.memo} TEXT,
            ${SqfExpense.incomeSourceBigCategory} INTEGER NOT NULL,
            ${SqfExpense.fixedCostId} INTEGER,
            ${SqfExpense.isConfirmed} INTEGER NOT NULL DEFAULT 1,
            ${SqfExpense.estimatedPrice} INTEGER
          );
          ''');

    // 既存行は全て通常支出なので fixed_cost_id=NULL・is_confirmed=1・
    // estimated_price=NULL を明示して引き継ぐ
    await db.execute('''
          INSERT INTO expense_v10_new (
            ${SqfExpense.id},
            ${SqfExpense.expenseSmallCategoryId},
            ${SqfExpense.date},
            ${SqfExpense.price},
            ${SqfExpense.memo},
            ${SqfExpense.incomeSourceBigCategory},
            ${SqfExpense.fixedCostId},
            ${SqfExpense.isConfirmed},
            ${SqfExpense.estimatedPrice}
          )
          SELECT
            ${SqfExpense.id},
            ${SqfExpense.expenseSmallCategoryId},
            ${SqfExpense.date},
            ${SqfExpense.price},
            ${SqfExpense.memo},
            ${SqfExpense.incomeSourceBigCategory},
            NULL,
            1,
            NULL
          FROM ${SqfExpense.tableName};
          ''');

    await db.execute('DROP TABLE ${SqfExpense.tableName};');
    await db.execute(
      'ALTER TABLE expense_v10_new RENAME TO ${SqfExpense.tableName};',
    );
  }

  /// v10-2: 固定費カテゴリーを支出カテゴリーへ移設し、fixed_cost の参照を付け替える
  ///
  /// 仕様 §5 手順1・手順2。手順1で作った小カテゴリーへ手順2で付け替えるため、
  /// 2手順を1メソッドにまとめている。
  /// 冪等性は `fixed_cost.expense_small_category_id` 列の有無で判定する
  /// （onUpgrade は1トランザクションのため、途中失敗時は手順1ごとロールバックされ、
  ///   列が存在する＝手順1・2とも完了済み、が成り立つ）。
  Future<void> _moveFixedCostCategoryToExpenseCategory(Database db) async {
    logger.i('2. ${SqfFixedCost.tableName}のexpense_small_category_id列を検査中...');
    final fixedCostColumns = await db.rawQuery(
      'PRAGMA table_info(${SqfFixedCost.tableName})',
    );
    final hasExpenseSmallCategoryId = fixedCostColumns.any(
      (column) => column['name'] == SqfFixedCost.expenseSmallCategoryId,
    );

    if (hasExpenseSmallCategoryId) {
      logger.i('2-1. カテゴリー移設は実施済みのためスキップ');
      return;
    }

    // --- 手順1: fixed_cost_category を expense_big_category ＋ 同名の小カテゴリーへ移設 ---
    logger.i('2-1. 固定費カテゴリーを支出カテゴリーへ移設します');
    final fixedCostCategories = await db.rawQuery('''
          SELECT
            ${SqfFixedCostCategory.id},
            ${SqfFixedCostCategory.categoryName},
            ${SqfFixedCostCategory.colorCode},
            ${SqfFixedCostCategory.resourcePath},
            ${SqfFixedCostCategory.isDisplayed}
          FROM ${SqfFixedCostCategory.tableName}
          ORDER BY ${SqfFixedCostCategory.displayOrder} ASC, ${SqfFixedCostCategory.id} ASC;
          ''');

    // 表示順は既存の支出カテゴリーの末尾に連番で追加する
    var nextDisplayOrder =
        (Sqflite.firstIntValue(
              await db.rawQuery(
                'SELECT IFNULL(MAX(${SqfExpenseBigCategory.displayOrder}), -1) FROM ${SqfExpenseBigCategory.tableName}',
              ),
            ) ??
            -1) +
        1;
    var nextSmallCategoryOrderKey =
        (Sqflite.firstIntValue(
              await db.rawQuery(
                'SELECT IFNULL(MAX(${SqfExpenseSmallCategory.smallCategoryOrderKey}), -1) FROM ${SqfExpenseSmallCategory.tableName}',
              ),
            ) ??
            -1) +
        1;

    // 旧固定費カテゴリーID → 移設先の小カテゴリーID
    final smallCategoryIdByFixedCostCategoryId = <int, int>{};
    // 参照欠損の救済先（「その他」由来の小カテゴリー）
    int? fallbackSmallCategoryId;

    for (final category in fixedCostCategories) {
      final fixedCostCategoryId = category[SqfFixedCostCategory.id] as int;
      final name = category[SqfFixedCostCategory.categoryName] as String;

      // 既存支出カテゴリーに同名があってもマージせず、別レコードとして併存させる
      final bigCategoryId = await db.rawInsert(
        '''
            INSERT INTO ${SqfExpenseBigCategory.tableName} (
              ${SqfExpenseBigCategory.name},
              ${SqfExpenseBigCategory.colorCode},
              ${SqfExpenseBigCategory.resourcePath},
              ${SqfExpenseBigCategory.displayOrder},
              ${SqfExpenseBigCategory.isDisplayed}
            ) VALUES (?, ?, ?, ?, ?);
            ''',
        [
          name,
          category[SqfFixedCostCategory.colorCode],
          category[SqfFixedCostCategory.resourcePath],
          nextDisplayOrder,
          category[SqfFixedCostCategory.isDisplayed],
        ],
      );
      nextDisplayOrder++;

      // 各大カテゴリー配下に同名の小カテゴリーを1件だけ作る（固定費の移行先）
      final smallCategoryId = await db.rawInsert(
        '''
            INSERT INTO ${SqfExpenseSmallCategory.tableName} (
              ${SqfExpenseSmallCategory.bigCategoryKey},
              ${SqfExpenseSmallCategory.name},
              ${SqfExpenseSmallCategory.smallCategoryOrderKey},
              ${SqfExpenseSmallCategory.displayedOrderInBig},
              ${SqfExpenseSmallCategory.defaultDisplayed}
            ) VALUES (?, ?, ?, 0, 1);
            ''',
        [bigCategoryId, name, nextSmallCategoryOrderKey],
      );
      nextSmallCategoryOrderKey++;

      smallCategoryIdByFixedCostCategoryId[fixedCostCategoryId] =
          smallCategoryId;
      if (name == FixedCostCategoryConstants.fallbackCategoryName) {
        fallbackSmallCategoryId = smallCategoryId;
      }
    }
    logger.i('2-2. 移設した固定費カテゴリー: ${fixedCostCategories.length}件');

    // --- 手順2: fixed_cost の参照付替 ---
    // 列は ADD COLUMN で追加する（fixed_cost_category_id はT6まで残す）。
    // NOT NULL のため DEFAULT 0 を置き、この後のUPDATEで実IDを埋める。
    await db.execute(
      'ALTER TABLE ${SqfFixedCost.tableName} ADD COLUMN ${SqfFixedCost.expenseSmallCategoryId} INTEGER NOT NULL DEFAULT 0;',
    );

    for (final entry in smallCategoryIdByFixedCostCategoryId.entries) {
      await db.rawUpdate(
        '''
            UPDATE ${SqfFixedCost.tableName}
            SET ${SqfFixedCost.expenseSmallCategoryId} = ?
            WHERE ${SqfFixedCost.fixedCostCategoryId} = ?;
            ''',
        [entry.value, entry.key],
      );
    }

    // 参照先の fixed_cost_category が欠損している行の救済
    final unresolved =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ${SqfFixedCost.tableName} WHERE ${SqfFixedCost.expenseSmallCategoryId} = 0',
          ),
        ) ??
        0;
    if (unresolved > 0) {
      // 「その他」が無いDB（ユーザーが削除した等）でも救済先を必ず用意する
      fallbackSmallCategoryId ??= await _createFallbackExpenseCategory(
        db,
        displayOrder: nextDisplayOrder,
        smallCategoryOrderKey: nextSmallCategoryOrderKey,
      );
      await db.rawUpdate(
        '''
            UPDATE ${SqfFixedCost.tableName}
            SET ${SqfFixedCost.expenseSmallCategoryId} = ?
            WHERE ${SqfFixedCost.expenseSmallCategoryId} = 0;
            ''',
        [fallbackSmallCategoryId],
      );
      logger.i('2-3. 参照欠損のため「その他」由来カテゴリーへ割当: $unresolved件');
    }
  }

  /// 参照欠損の救済先が無い場合に作る「固定費その他」カテゴリー（大＋同名の小）
  ///
  /// 戻り値は作成した小カテゴリーのID。
  Future<int> _createFallbackExpenseCategory(
    Database db, {
    required int displayOrder,
    required int smallCategoryOrderKey,
  }) async {
    const name = FixedCostCategoryConstants.freshInstallFallbackCategoryName;
    final bigCategoryId = await db.rawInsert(
      '''
          INSERT INTO ${SqfExpenseBigCategory.tableName} (
            ${SqfExpenseBigCategory.name},
            ${SqfExpenseBigCategory.colorCode},
            ${SqfExpenseBigCategory.resourcePath},
            ${SqfExpenseBigCategory.displayOrder},
            ${SqfExpenseBigCategory.isDisplayed}
          ) VALUES (?, ?, ?, ?, 1);
          ''',
      [
        name,
        CategoryPalette.fixedCostHex,
        'assets/images/icon_others.svg',
        displayOrder,
      ],
    );
    return db.rawInsert(
      '''
          INSERT INTO ${SqfExpenseSmallCategory.tableName} (
            ${SqfExpenseSmallCategory.bigCategoryKey},
            ${SqfExpenseSmallCategory.name},
            ${SqfExpenseSmallCategory.smallCategoryOrderKey},
            ${SqfExpenseSmallCategory.displayedOrderInBig},
            ${SqfExpenseSmallCategory.defaultDisplayed}
          ) VALUES (?, ?, ?, 0, 1);
          ''',
      [bigCategoryId, name, smallCategoryOrderKey],
    );
  }
}
