import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/model/table_calmn_name.dart';
import 'package:kakeibo/theme/category_palette.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';
import 'package:sqflite/sqflite.dart';

/// v10で廃止した旧テーブル `fixed_cost_expense` の列名（移行SQL専用）
///
/// 廃止済みのテーブルなので `table_calmn_name.dart` には残さず、
/// 旧形状を読む必要があるマイグレーションコード側に閉じ込める。
class _LegacyFixedCostExpense {
  static const tableName = 'fixed_cost_expense';

  static const id = '_id';
  static const fixedCostId = 'fixed_cost_id';
  static const fixedCostCategoryId = 'fixed_cost_category_id';
  static const date = 'date';
  static const price = 'price';
  static const name = 'name';
  static const confirmedCostType = 'confirmed_cost_type';
  static const isConfirmed = 'is_confirmed';
}

/// v10で廃止した旧テーブル `fixed_cost_category` の列名（移行SQL専用）
class _LegacyFixedCostCategory {
  static const tableName = 'fixed_cost_category';

  static const id = '_id';
  static const categoryName = 'category_name';
  static const colorCode = 'color_code';
  static const resourcePath = 'resource_path';
  static const displayOrder = 'display_order';
  static const isDisplayed = 'is_displayed';
}

/// v10で削除した `fixed_cost.fixed_cost_category_id` 列（移行SQL専用）
const _legacyFixedCostCategoryIdColumn = 'fixed_cost_category_id';

/// v7〜v12 の固定費統一色（v13 で個別化する対象。移行SQL専用）
const _v12FixedCostGrayHex = '8E8E93';

/// v13: 旧支出パレット（v7〜v12）→ 新支出パレットの対応表（KP-012 仕様書 §3.1）
///
/// 既定7カテゴリーも同じ表で新既定色になる（食費 red / 日用品 orange / 遊び娯楽 sky /
/// 交通費 blue / 衣服美容 violet / 医療費 magenta / 雑費 amber）。
const _v13ExpenseColorMap = <String, String>{
  'FF7171': CategoryPalette.expense1Hex, // red
  'FB5B01': CategoryPalette.expense2Hex, // orange
  '3DD8E0': CategoryPalette.expense6Hex, // シアン → sky
  '4BA6FF': CategoryPalette.expense7Hex, // blue
  'BB87FF': CategoryPalette.expense9Hex, // violet
  'DF2828': CategoryPalette.expense10Hex, // 深紅 → magenta
  'FFC700': CategoryPalette.expense3Hex, // amber
  'AC3E00': CategoryPalette.expense12Hex, // brown
};

/// v13: 旧収入パレット → 新収入パレットの対応表（1段ずつ濃い側へ）
const _v13IncomeColorMap = <String, String>{
  '6EE7B7': CategoryPalette.income1Hex,
  '21D19F': CategoryPalette.income2Hex,
  '10B981': CategoryPalette.income3Hex,
  '059669': CategoryPalette.income4Hex,
};

/// v13: 旧グレーの固定費由来カテゴリーに名前で割り当てる色（sql_on_create のシードと同じ対応）
///
/// v6 シードの並び（住居費・通信費・サブスク・光熱費）と新規インストールの並び
/// （住居費・サブスク・通信費・光熱費）が異なるため、display_order ではなく名前で引く。
/// 「その他」系はグレーのまま（新 gray と同値）。
const _v13FixedCostDerivedColorByName = <String, String>{
  '住居費': CategoryPalette.expense8Hex, // indigo
  'サブスク': CategoryPalette.expense11Hex, // pink
  '通信費': CategoryPalette.expense5Hex, // teal
  '光熱費': CategoryPalette.expense4Hex, // lime
  _legacyFallbackCategoryName: CategoryPalette.grayHex,
  FixedCostDerivedCategoryConstants.freshInstallFallbackCategoryName:
      CategoryPalette.grayHex,
};

/// v13: 名前が対応表に無い旧グレーの行（ユーザー独自の固定費カテゴリー）へ
/// display_order 順に巡回配布する色。名前対応表で使われた色は後回しにする
const _v13FixedCostDerivedRotation = <String>[
  CategoryPalette.expense8Hex, // indigo
  CategoryPalette.expense11Hex, // pink
  CategoryPalette.expense5Hex, // teal
  CategoryPalette.expense4Hex, // lime
];

/// 既定の固定費カテゴリー「その他」の名称
///
/// 参照先の `fixed_cost_category` が欠損している行の救済先を特定するために使う
/// （仕様 §5 手順2）。移行SQL専用のためこのファイルに閉じる。
const _legacyFallbackCategoryName = 'その他';

class DataBaseMigrate {
  // 固定費機能追加のためのマイグレーション
  toV3(Database db) async {
    await db.execute('''CREATE TABLE ${SqfFixedCost.tableName} (
          ${SqfFixedCost.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${SqfFixedCost.name} TEXT NOT NULL,
          ${SqfFixedCost.variable} INTEGER NOT NULL,
          ${SqfFixedCost.price} INTEGER,
          ${SqfFixedCost.estimatedPrice} INTEGER,
          $_legacyFixedCostCategoryIdColumn INTEGER NOT NULL,
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
    await db.execute('''CREATE TABLE ${_LegacyFixedCostCategory.tableName} (
          ${_LegacyFixedCostCategory.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${_LegacyFixedCostCategory.categoryName} TEXT NOT NULL,
          ${_LegacyFixedCostCategory.colorCode} TEXT NOT NULL,
          ${_LegacyFixedCostCategory.resourcePath} TEXT NOT NULL,
          ${_LegacyFixedCostCategory.displayOrder} INTEGER NOT NULL,
          ${_LegacyFixedCostCategory.isDisplayed} INTEGER NOT NULL
          );
          ''');

    // 固定費カテゴリーの初期データ挿入
    await db.execute('''
          INSERT INTO ${_LegacyFixedCostCategory.tableName} (
          ${_LegacyFixedCostCategory.categoryName},
          ${_LegacyFixedCostCategory.colorCode},
          ${_LegacyFixedCostCategory.resourcePath},
          ${_LegacyFixedCostCategory.displayOrder},
          ${_LegacyFixedCostCategory.isDisplayed})
          VALUES
          ('住居費', 'FF5722', 'assets/images/icon_home.svg', 0, 1),
          ('通信費', '2196F3', 'assets/images/icon_phone.svg', 1, 1),
          ('サブスク', '9C27B0', 'assets/images/icon_subscription.svg', 2, 1),
          ('光熱費', 'FFC107', 'assets/images/icon_utility.svg', 3, 1),
          ('その他', '607D8B', 'assets/images/icon_others.svg', 4, 1);
          ''');

    // 2. 新テーブル作成: fixed_cost_expense
    print('2. fixed_cost_expenseテーブル作成中...');
    await db.execute('''CREATE TABLE ${_LegacyFixedCostExpense.tableName} (
          ${_LegacyFixedCostExpense.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${_LegacyFixedCostExpense.fixedCostCategoryId} INTEGER NOT NULL,
          ${_LegacyFixedCostExpense.date} TEXT NOT NULL,
          ${_LegacyFixedCostExpense.price} INTEGER NOT NULL,
          ${_LegacyFixedCostExpense.name} TEXT,
          ${_LegacyFixedCostExpense.confirmedCostType} INTEGER,
          ${_LegacyFixedCostExpense.isConfirmed} INTEGER NOT NULL
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
      "UPDATE ${_LegacyFixedCostCategory.tableName} SET ${_LegacyFixedCostCategory.colorCode} = '8E8E93';",
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
          $_legacyFixedCostCategoryIdColumn INTEGER NOT NULL,
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
            $_legacyFixedCostCategoryIdColumn,
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
            $_legacyFixedCostCategoryIdColumn,
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
    logger.i('2. ${_LegacyFixedCostExpense.tableName}のfixed_cost_id列を検査中...');
    final columns = await db.rawQuery(
      'PRAGMA table_info(${_LegacyFixedCostExpense.tableName})',
    );
    final hasFixedCostId = columns.any(
      (column) => column['name'] == _LegacyFixedCostExpense.fixedCostId,
    );

    if (hasFixedCostId) {
      logger.i('2-1. fixed_cost_id列は既に存在するためスキップ');
    } else {
      logger.i('2-1. fixed_cost_id列が無いため追加・補完します');
      await db.execute(
        'ALTER TABLE ${_LegacyFixedCostExpense.tableName} ADD COLUMN ${_LegacyFixedCostExpense.fixedCostId} INTEGER;',
      );

      // 名前と固定費カテゴリーの一致でマスタと突合して補完する
      // （支払実績の日付はマスタ側の支払日と一致しないため突合キーに使わない）
      await db.execute('''
          UPDATE ${_LegacyFixedCostExpense.tableName}
          SET ${_LegacyFixedCostExpense.fixedCostId} = (
            SELECT fc.${SqfFixedCost.id}
            FROM ${SqfFixedCost.tableName} fc
            WHERE fc.${SqfFixedCost.name} = ${_LegacyFixedCostExpense.tableName}.${_LegacyFixedCostExpense.name}
              AND fc.$_legacyFixedCostCategoryIdColumn = ${_LegacyFixedCostExpense.tableName}.${_LegacyFixedCostExpense.fixedCostCategoryId}
            LIMIT 1
          )
          WHERE ${_LegacyFixedCostExpense.fixedCostId} IS NULL;
          ''');

      // 突合できなかったレコードはNULLのまま保持し、件数だけログに残す
      final unresolved = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM ${_LegacyFixedCostExpense.tableName} WHERE ${_LegacyFixedCostExpense.fixedCostId} IS NULL',
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
  // 仕様書 §4・§5（固定費カテゴリー統合_仕様書.html）の手順1〜4を実施する。
  //   手順1・2: 固定費カテゴリーの支出カテゴリーへの移設と fixed_cost の参照付替
  //   手順3・4: fixed_cost_expense → expense の実績移行と旧2テーブルのDROP
  //
  // 注意: onUpgrade は既にトランザクション内で呼ばれるため、
  // ここでは db.transaction() や DatabaseHelper 経由のリポジトリを使わず、
  // 引数の db に対する raw SQL のみで書く（既存 toV6〜toV9 と同じ作法）。
  Future<void> toV10(Database db) async {
    logger.i('=== v10マイグレーション開始: 固定費カテゴリー統合 ===');

    await _migrateExpenseTableToV10(db);
    await _moveFixedCostCategoryToExpenseCategory(db);
    await _migrateFixedCostExpenseToExpense(db);
    await _dropFixedCostCategoryIdColumn(db);
    await _dropLegacyFixedCostTables(db);

    logger.i('=== v10マイグレーション完了 ===');
  }

  // 予想額の手動設定フラグの追加 (v10 → v11)
  //
  // 当初は toV10 内に追記していたが、v10 は先行の TestFlight で配信済みだったため
  // v10 適用済みの端末では列が追加されず fixed_cost の全クエリが失敗した。
  // 独立したバージョンとして切り直す（仕様 §6.9）。
  Future<void> toV11(Database db) async {
    logger.i('=== v11マイグレーション開始: 予想額の手動設定フラグ ===');
    await _addEstimatedPriceIsManualColumn(db);
    logger.i('=== v11マイグレーション完了 ===');
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
            ${_LegacyFixedCostCategory.id},
            ${_LegacyFixedCostCategory.categoryName},
            ${_LegacyFixedCostCategory.colorCode},
            ${_LegacyFixedCostCategory.resourcePath},
            ${_LegacyFixedCostCategory.isDisplayed}
          FROM ${_LegacyFixedCostCategory.tableName}
          ORDER BY ${_LegacyFixedCostCategory.displayOrder} ASC, ${_LegacyFixedCostCategory.id} ASC;
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
      final fixedCostCategoryId = category[_LegacyFixedCostCategory.id] as int;
      final name = category[_LegacyFixedCostCategory.categoryName] as String;

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
          category[_LegacyFixedCostCategory.colorCode],
          category[_LegacyFixedCostCategory.resourcePath],
          nextDisplayOrder,
          category[_LegacyFixedCostCategory.isDisplayed],
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
      if (name == _legacyFallbackCategoryName) {
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
            WHERE $_legacyFixedCostCategoryIdColumn = ?;
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
    const name = FixedCostDerivedCategoryConstants.freshInstallFallbackCategoryName;
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
        // v10 当時の固定費統一色（歴史上の値。v13 手順1がこの値を検索して個別化する）
        _v12FixedCostGrayHex,
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

  /// v10-3: fixed_cost_expense の実績を expense へ移行する（仕様 §5 手順3）
  ///
  /// - `_id` は持ち越さず expense 側で新規採番する（両テーブルともAUTOINCREMENTのため）
  /// - 確定行(is_confirmed=1): price=旧price / estimated_price=NULL
  /// - 未確定行(is_confirmed=0): price=NULL / estimated_price=マスタの推定額をJOIN転記
  ///   （旧行のpriceは0固定で推定額ではないため移行しない）
  /// - name→memo、拠出元は通常支出と同じ既定値（生活収支）
  /// - `fixed_cost_id` が欠損している行は「名称＋旧カテゴリー」でマスタへ再突合し、
  ///   それでも不明なら fixed_cost_id=NULL の通常支出として移行する（金額を失わない）
  /// - T2以降に expense へ直接生成された行と同一 `fixed_cost_id`＋`date` の旧行は
  ///   二重計上になるためスキップする
  ///
  /// 旧テーブルが無ければ何もしない（冪等性・中断残骸への耐性）。
  Future<void> _migrateFixedCostExpenseToExpense(Database db) async {
    if (!await _tableExists(db, _LegacyFixedCostExpense.tableName)) {
      logger.i('3. ${_LegacyFixedCostExpense.tableName}が無いため実績移行をスキップ');
      return;
    }

    logger.i('3. ${_LegacyFixedCostExpense.tableName}の実績をexpenseへ移行します');

    // 旧カテゴリー列・旧カテゴリーテーブルは、この後の手順で消える。
    // 中断残骸（旧実績だけが残っている等）でも落ちないよう、有無を見てから使う。
    final fixedCostColumns = await db.rawQuery(
      'PRAGMA table_info(${SqfFixedCost.tableName})',
    );
    final canRematchByCategory = fixedCostColumns.any(
      (column) => column['name'] == _legacyFixedCostCategoryIdColumn,
    );

    // --- 3-1: fixed_cost_id が欠損している行をマスタへ再突合する ---
    // v6経由の端末には fixed_cost_id が NULL のままの実績が残っている。
    // 参照先マスタが消えている行（IDだけ残った行）も同じ扱いで拾い直す。
    if (canRematchByCategory) {
      final rematched = await db.rawUpdate('''
          UPDATE ${_LegacyFixedCostExpense.tableName}
          SET ${_LegacyFixedCostExpense.fixedCostId} = (
            SELECT fc.${SqfFixedCost.id}
            FROM ${SqfFixedCost.tableName} fc
            WHERE fc.${SqfFixedCost.name} = ${_LegacyFixedCostExpense.tableName}.${_LegacyFixedCostExpense.name}
              AND fc.$_legacyFixedCostCategoryIdColumn = ${_LegacyFixedCostExpense.tableName}.${_LegacyFixedCostExpense.fixedCostCategoryId}
            ORDER BY fc.${SqfFixedCost.id} ASC
            LIMIT 1
          )
          WHERE NOT EXISTS (
            SELECT 1 FROM ${SqfFixedCost.tableName} fc2
            WHERE fc2.${SqfFixedCost.id} = ${_LegacyFixedCostExpense.tableName}.${_LegacyFixedCostExpense.fixedCostId}
          );
          ''');
      if (rematched > 0) {
        logger.i('3-1. fixed_cost_idの再突合を試みた行: $rematched件');
      }
    }

    // --- 3-2: カテゴリーの解決表を作る ---
    // 旧カテゴリーID → 移設先の小カテゴリーID。
    // 同名カテゴリーが併存する場合は display_order が最大のもの
    // （＝手順1の移設で末尾に作られた方）を選ぶ。
    final smallCategoryIdByLegacyCategoryId = <int, int>{};
    if (await _tableExists(db, _LegacyFixedCostCategory.tableName)) {
      final rows = await db.rawQuery('''
          SELECT
            fcc.${_LegacyFixedCostCategory.id} AS legacy_id,
            (
              SELECT esc.${SqfExpenseSmallCategory.id}
              FROM ${SqfExpenseSmallCategory.tableName} esc
              JOIN ${SqfExpenseBigCategory.tableName} ebc
                ON ebc.${SqfExpenseBigCategory.id} = esc.${SqfExpenseSmallCategory.bigCategoryKey}
              WHERE ebc.${SqfExpenseBigCategory.name} = fcc.${_LegacyFixedCostCategory.categoryName}
                AND esc.${SqfExpenseSmallCategory.name} = fcc.${_LegacyFixedCostCategory.categoryName}
              ORDER BY ebc.${SqfExpenseBigCategory.displayOrder} DESC
              LIMIT 1
            ) AS small_id
          FROM ${_LegacyFixedCostCategory.tableName} fcc;
          ''');
      for (final row in rows) {
        final smallId = row['small_id'];
        if (smallId is int) {
          smallCategoryIdByLegacyCategoryId[row['legacy_id'] as int] = smallId;
        }
      }
    }
    final fallbackSmallCategoryId = await _resolveFallbackSmallCategoryId(db);
    // 解決表をSQLへ埋め込む（旧テーブルへのJOINを持ち込まないため）
    final categoryCaseExpr = smallCategoryIdByLegacyCategoryId.isEmpty
        ? 'NULL'
        : 'CASE fce.${_LegacyFixedCostExpense.fixedCostCategoryId}'
              '${smallCategoryIdByLegacyCategoryId.entries.map((e) => ' WHEN ${e.key} THEN ${e.value}').join()}'
              ' ELSE NULL END';

    // --- 3-3: expense へINSERTする ---
    // 小カテゴリーは ①マスタの expense_small_category_id（手順2で解決済み）
    // ②旧カテゴリーからの解決表 ③救済先 の順に採用する。
    // rawInsert の戻り値は最終行IDのため、件数は挿入前後の差分で求める
    final beforeCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${SqfExpense.tableName}'),
        ) ??
        0;
    await db.rawInsert('''
          INSERT INTO ${SqfExpense.tableName} (
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
            COALESCE(
              fc.${SqfFixedCost.expenseSmallCategoryId},
              $categoryCaseExpr,
              $fallbackSmallCategoryId
            ),
            fce.${_LegacyFixedCostExpense.date},
            CASE WHEN fce.${_LegacyFixedCostExpense.isConfirmed} = 1
              THEN fce.${_LegacyFixedCostExpense.price} ELSE NULL END,
            fce.${_LegacyFixedCostExpense.name},
            ${AccountTypeConstants.living},
            fc.${SqfFixedCost.id},
            fce.${_LegacyFixedCostExpense.isConfirmed},
            CASE WHEN fce.${_LegacyFixedCostExpense.isConfirmed} = 1
              THEN NULL ELSE fc.${SqfFixedCost.estimatedPrice} END
          FROM ${_LegacyFixedCostExpense.tableName} fce
          LEFT JOIN ${SqfFixedCost.tableName} fc
            ON fc.${SqfFixedCost.id} = fce.${_LegacyFixedCostExpense.fixedCostId}
          WHERE NOT EXISTS (
            SELECT 1 FROM ${SqfExpense.tableName} e
            WHERE e.${SqfExpense.fixedCostId} IS NOT NULL
              AND e.${SqfExpense.fixedCostId} = fce.${_LegacyFixedCostExpense.fixedCostId}
              AND e.${SqfExpense.date} = fce.${_LegacyFixedCostExpense.date}
          );
          ''');
    final afterCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${SqfExpense.tableName}'),
        ) ??
        0;
    final migrated = afterCount - beforeCount;
    logger.i('3-4. expenseへ移行した固定費実績: $migrated件');
  }

  /// カテゴリーを解決できない実績の救済先小カテゴリーIDを返す
  ///
  /// 「その他」（移行時の名称）→「固定費その他」（新規インストール時の名称）の順で探し、
  /// どちらも無ければ最小IDの小カテゴリーへ寄せる（NOT NULL列を埋めるための最終手段）。
  Future<int> _resolveFallbackSmallCategoryId(Database db) async {
    final byName = Sqflite.firstIntValue(
      await db.rawQuery(
        '''
          SELECT esc.${SqfExpenseSmallCategory.id}
          FROM ${SqfExpenseSmallCategory.tableName} esc
          JOIN ${SqfExpenseBigCategory.tableName} ebc
            ON ebc.${SqfExpenseBigCategory.id} = esc.${SqfExpenseSmallCategory.bigCategoryKey}
          WHERE ebc.${SqfExpenseBigCategory.name} IN (?, ?)
          ORDER BY ebc.${SqfExpenseBigCategory.displayOrder} DESC
          LIMIT 1;
          ''',
        [
          _legacyFallbackCategoryName,
          FixedCostDerivedCategoryConstants.freshInstallFallbackCategoryName,
        ],
      ),
    );
    if (byName != null) {
      return byName;
    }

    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT MIN(${SqfExpenseSmallCategory.id}) FROM ${SqfExpenseSmallCategory.tableName}',
          ),
        ) ??
        0;
  }

  /// v10-4: fixed_cost からテーブル再作成方式で fixed_cost_category_id 列を削除する
  ///
  /// 参照先は手順2で expense_small_category_id へ移っており、旧列は不要になる。
  /// 列が既に無ければ何もしない（冪等性）。
  Future<void> _dropFixedCostCategoryIdColumn(Database db) async {
    final columns = await db.rawQuery(
      'PRAGMA table_info(${SqfFixedCost.tableName})',
    );
    final hasLegacyColumn = columns.any(
      (column) => column['name'] == _legacyFixedCostCategoryIdColumn,
    );
    if (!hasLegacyColumn) {
      logger.i('4. ${SqfFixedCost.tableName}の旧カテゴリー列は削除済みのためスキップ');
      return;
    }

    logger.i('4. ${SqfFixedCost.tableName}を再作成して旧カテゴリー列を削除します');
    // 過去の中断で残骸テーブルがあっても再実行に耐えるよう先にDROPする
    await db.execute('DROP TABLE IF EXISTS fixed_cost_v10_new;');
    await db.execute('''
          CREATE TABLE fixed_cost_v10_new (
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
    await db.execute('''
          INSERT INTO fixed_cost_v10_new (
            ${SqfFixedCost.id},
            ${SqfFixedCost.name},
            ${SqfFixedCost.variable},
            ${SqfFixedCost.price},
            ${SqfFixedCost.estimatedPrice},
            ${SqfFixedCost.expenseSmallCategoryId},
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
            ${SqfFixedCost.expenseSmallCategoryId},
            ${SqfFixedCost.intervalNumber},
            ${SqfFixedCost.intervalUnit},
            ${SqfFixedCost.firstPaymentDate},
            ${SqfFixedCost.recentPaymentDate},
            ${SqfFixedCost.nextPaymentDate},
            ${SqfFixedCost.deleteFlag}
          FROM ${SqfFixedCost.tableName};
          ''');
    await db.execute('DROP TABLE ${SqfFixedCost.tableName};');
    await db.execute(
      'ALTER TABLE fixed_cost_v10_new RENAME TO ${SqfFixedCost.tableName};',
    );
  }

  /// v10-4b: fixed_cost に estimated_price_is_manual 列を追加する（仕様 §6.9）
  ///
  /// 予想額を自動算出（0）と手動設定（1）で切り替えるためのフラグ。
  /// v10は未配信のため新バージョンを切らず、toV10の中に追記している。
  // v12 (v11 → v12)
  //
  // 当初「変動固定費の確定扱い・0円行の修復」を入れてビルド160で配信したが、
  // 実機DBの検査でそのような行は存在せず、55円は確定行の実額（仕様どおりの平均）と判明した。
  // 配信済みのためバージョン番号は維持し、処理は行わない（2026/08/23）。
  Future<void> toV12(Database db) async {
    logger.i('=== v12マイグレーション: 変更なし（予約済みバージョン） ===');
  }

  // カテゴリーカラーパレット刷新 (v12 → v13)
  //
  // 支出8色＋固定費グレー1色 → 支出12色＋グレー1色、収入4色を新パレットへ置き換える（KP-012）。
  // スキーマ変更はなく color_code の値だけを更新する。
  //   手順0: color_code を大文字に正規化する（UI から保存した色は ColorCode.fromColor で小文字になる）
  //   手順1: 旧グレー（固定費由来）の行を名前で個別色にする。名前が対応表に無い行は巡回配布
  //   手順2: 残りの行を旧色→新色の対応表で1対1に置換する（既定カテゴリーも同じ表に乗る）
  // 対応表に無い値（想定外）はそのまま残す。
  // 新色は旧色のどれとも一致せず、手順1もグレーの行を「名前で」引くため、2回実行しても結果は同じ（冪等）。
  Future<void> toV13(Database db) async {
    logger.i('=== v13マイグレーション開始: カテゴリーカラーパレット刷新 ===');

    await _normalizeColorCodeToUpperCase(db);
    await _assignColorsToLegacyGrayExpenseCategories(db);
    await _replaceColorsByMap(
      db,
      tableName: SqfExpenseBigCategory.tableName,
      colorColumn: SqfExpenseBigCategory.colorCode,
      colorMap: _v13ExpenseColorMap,
      label: '13-2. 支出大カテゴリー',
    );
    await _replaceColorsByMap(
      db,
      tableName: SqfIncomeBigCategory.tableName,
      colorColumn: SqfIncomeBigCategory.colorCode,
      colorMap: _v13IncomeColorMap,
      label: '13-3. 収入大カテゴリー',
    );

    logger.i('=== v13マイグレーション完了 ===');
  }

  /// v13-0: 支出・収入大カテゴリーの color_code を大文字に揃える
  ///
  /// 画面から保存した色は `ColorCode.fromColor` により小文字6桁で入るため、
  /// 大文字で持つ対応表・旧グレー検索と一致させる（値の意味は変わらない）。
  Future<void> _normalizeColorCodeToUpperCase(Database db) async {
    await db.execute(
      'UPDATE ${SqfExpenseBigCategory.tableName} '
      'SET ${SqfExpenseBigCategory.colorCode} = UPPER(${SqfExpenseBigCategory.colorCode});',
    );
    await db.execute(
      'UPDATE ${SqfIncomeBigCategory.tableName} '
      'SET ${SqfIncomeBigCategory.colorCode} = UPPER(${SqfIncomeBigCategory.colorCode});',
    );
    logger.i('13-0. color_code を大文字に正規化しました');
  }

  /// v13-1: 旧グレー（v7〜v12 の固定費統一色）の支出大カテゴリーを個別色にする
  ///
  /// - 名前が対応表（住居費 indigo / サブスク pink / 通信費 teal / 光熱費 lime / その他系 gray）に
  ///   あればその色。端末ごとの display_order に依らず、新規インストールのシードと同じ名前→色になる
  /// - 対応表に無い名前（ユーザー独自の固定費カテゴリー）は display_order 昇順（同順位は _id 昇順）で、
  ///   名前対応で使われなかった色 → 全4色の順に巡回配布する
  Future<void> _assignColorsToLegacyGrayExpenseCategories(Database db) async {
    final rows = await db.query(
      SqfExpenseBigCategory.tableName,
      columns: [SqfExpenseBigCategory.id, SqfExpenseBigCategory.name],
      where: '${SqfExpenseBigCategory.colorCode} = ?',
      whereArgs: [_v12FixedCostGrayHex],
      orderBy: '${SqfExpenseBigCategory.displayOrder} ASC, ${SqfExpenseBigCategory.id} ASC',
    );
    logger.i('13-1. 旧グレーの支出大カテゴリー ${rows.length} 件を個別色にします');

    final usedByName = <String>{};
    final unnamedIds = <Object?>[];
    for (final row in rows) {
      final name = row[SqfExpenseBigCategory.name] as String;
      final color = _v13FixedCostDerivedColorByName[name];
      if (color == null) {
        unnamedIds.add(row[SqfExpenseBigCategory.id]);
        continue;
      }
      usedByName.add(color);
      await db.update(
        SqfExpenseBigCategory.tableName,
        {SqfExpenseBigCategory.colorCode: color},
        where: '${SqfExpenseBigCategory.id} = ?',
        whereArgs: [row[SqfExpenseBigCategory.id]],
      );
    }

    // 名前で引けなかった行は、未使用色を優先した巡回で配る
    final rotation = [
      ..._v13FixedCostDerivedRotation.where((c) => !usedByName.contains(c)),
      ..._v13FixedCostDerivedRotation.where(usedByName.contains),
    ];
    for (var i = 0; i < unnamedIds.length; i++) {
      await db.update(
        SqfExpenseBigCategory.tableName,
        {SqfExpenseBigCategory.colorCode: rotation[i % rotation.length]},
        where: '${SqfExpenseBigCategory.id} = ?',
        whereArgs: [unnamedIds[i]],
      );
    }
  }

  /// v13-2/3: 対応表に載っている旧色を新色へ1対1で置換する
  ///
  /// 新色は旧色のどれとも一致しないため、2回実行しても値は変わらない（冪等）。
  Future<void> _replaceColorsByMap(
    Database db, {
    required String tableName,
    required String colorColumn,
    required Map<String, String> colorMap,
    required String label,
  }) async {
    var updated = 0;
    for (final entry in colorMap.entries) {
      updated += await db.update(
        tableName,
        {colorColumn: entry.value},
        where: '$colorColumn = ?',
        whereArgs: [entry.key],
      );
    }
    logger.i('$label: $updated 件の色を新パレットへ置換しました');
  }

  /// v11: fixed_cost に estimated_price_is_manual を追加する。
  /// 列が既にあれば何もしない（冪等性。新規インストールは onCreate で既に持つ）。
  Future<void> _addEstimatedPriceIsManualColumn(Database db) async {
    final columns = await db.rawQuery(
      'PRAGMA table_info(${SqfFixedCost.tableName})',
    );
    final hasColumn = columns.any(
      (column) => column['name'] == SqfFixedCost.estimatedPriceIsManual,
    );
    if (hasColumn) {
      logger.i('11-1. ${SqfFixedCost.estimatedPriceIsManual}は追加済みのためスキップ');
      return;
    }

    logger.i('11-1. ${SqfFixedCost.tableName}に${SqfFixedCost.estimatedPriceIsManual}を追加します');
    // 既存マスタは全て自動算出（0）として扱う
    await db.execute(
      'ALTER TABLE ${SqfFixedCost.tableName} '
      'ADD COLUMN ${SqfFixedCost.estimatedPriceIsManual} INTEGER NOT NULL DEFAULT 0;',
    );
  }

  /// v10-5: 役目を終えた旧2テーブルをDROPする（仕様 §5 手順4）
  Future<void> _dropLegacyFixedCostTables(Database db) async {
    await db.execute(
      'DROP TABLE IF EXISTS ${_LegacyFixedCostExpense.tableName};',
    );
    await db.execute(
      'DROP TABLE IF EXISTS ${_LegacyFixedCostCategory.tableName};',
    );
    logger.i('5. 旧テーブル(fixed_cost_expense / fixed_cost_category)をDROPしました');
  }

  /// テーブルが存在するか
  Future<bool> _tableExists(Database db, String tableName) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = ?",
        [tableName],
      ),
    );
    return (count ?? 0) > 0;
  }
}
