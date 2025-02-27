import 'package:sqflite/sqflite.dart';

import 'tableNameKey.dart';

class DataBaseHelperHandling {
  funcOnCreate(Database db) async {
    await db.execute('''
          CREATE TABLE ${TBL001RecordKey().tableName} (
            ${TBL001RecordKey().id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${TBL001RecordKey().date} TEXT NOT NULL,
            ${TBL001RecordKey().price} INTEGER NOT NULL,
            ${TBL001RecordKey().paymentCategoryId} INTEGER NOT NULL,
            ${TBL001RecordKey().memo} TEXT)
          ;
          ''');

    await db.execute('''
          CREATE TABLE ${TBL002RecordKey().tableName} (
            ${TBL002RecordKey().id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${TBL002RecordKey().date} TEXT NOT NULL,
            ${TBL002RecordKey().price} INTEGER NOT NULL,
            ${TBL002RecordKey().incomeCategoryId} INTEGER NOT NULL,
            ${TBL002RecordKey().memo} TEXT
          );
          ''');

    await db.execute('''
          CREATE TABLE ${TBL003RecordKey().tableName} (
            ${TBL003RecordKey().id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${TBL003RecordKey().date} TEXT NOT NULL,
            ${TBL003RecordKey().bigCategoryId} INTEGER NOT NULL,
            ${TBL003RecordKey().price} INTEGER
          );
          ''');

    await db.execute('''
          CREATE TABLE ${TBL201RecordKey().tableName} (
            ${TBL201RecordKey().id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${TBL201RecordKey().smallCategoryOrderKey} INTEGER NOT NULL,
            ${TBL201RecordKey().bigCategoryKey} INTEGER NOT NULL,
            ${TBL201RecordKey().displayedOrderInBig} INTEGER NOT NULL,
            ${TBL201RecordKey().categoryName} TEXT NOT NULL,
            ${TBL201RecordKey().defaultDisplayed} INTEGER NOT NULL
          );
          ''');

    await db.execute('''
          INSERT INTO TBL201 (
            ${TBL201RecordKey().id},
            ${TBL201RecordKey().smallCategoryOrderKey},
            ${TBL201RecordKey().bigCategoryKey},
            ${TBL201RecordKey().displayedOrderInBig},
            ${TBL201RecordKey().categoryName},
            ${TBL201RecordKey().defaultDisplayed}) 
            VALUES(0, 0, 0, 0, '食費', 1),
                  (1, 1, 0, 1, 'コンビニ', 1),
                  (2, 2, 0, 2, '外食', 1),
                  (3, 3, 0, 3, '社食', 1),
                  (4, 4, 1, 0, '消耗品', 1),
                  (5, 5, 1, 1, '雑貨', 1),
                  (6, 6, 2, 0, '遊び', 1),
                  (7, 7, 2, 1, '飲み', 1),
                  (8, 8, 2, 2, 'ライブ', 1),
                  (9, 9, 2, 3, 'ご褒美', 1),
                  (10, 10, 3, 0, '交通費', 1),
                  (11, 11, 3, 1, '帰省', 1),
                  (12, 12, 4, 0, 'カット', 1),
                  (13, 13, 5, 0, '医療費', 1),
                  (14, 14, 6, 0, 'その他', 1);
          ''');

    await db.execute('''
          CREATE TABLE ${TBL202RecordKey().tableName} (
            ${TBL202RecordKey().id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${TBL202RecordKey().colorCode} TEXT NOT NULL,
            ${TBL202RecordKey().bigCategoryName} TEXT NOT NULL,
            ${TBL202RecordKey().resourcePath} TEXT NOT NULL,
            ${TBL202RecordKey().displayOrder} INTEGER NOT NULL,
            ${TBL202RecordKey().isDisplayed} INTEGER NOT NULL
          )
          ;''');

    await db.execute('''
          INSERT INTO TBL202 (
          ${TBL202RecordKey().id},
          ${TBL202RecordKey().colorCode},
          ${TBL202RecordKey().bigCategoryName},
          ${TBL202RecordKey().resourcePath},
          ${TBL202RecordKey().displayOrder},
          ${TBL202RecordKey().isDisplayed}) 
          VALUES(0, 'FF7070', '食費', 'assets/images/icon_meal.svg', 0, 1),
                (1, '21D19F', '日用品', 'assets/images/icon_commodity.svg', 1, 1),
                (2, 'ED112B', '遊び娯楽', 'assets/images/icon_favo.svg', 2, 1),
                (3, '2596FF', '交通費', 'assets/images/icon_transportation.svg', 3, 1),
                (4, 'FFC857', '衣服美容', 'assets/images/icon_clothes.svg', 4, 1),
                (5, 'B118C8', '医療費', 'assets/images/icon_medical.svg', 5, 1),
                (6, '3E2F5B', '雑費', 'assets/images/icon_others.svg', 6, 1);
          ''');

    await db.execute('''
          CREATE TABLE ${TBL211RecordKey().tableName} (
            ${TBL211RecordKey().id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${TBL211RecordKey().smallCategoryOrderKey} INTEGER NOT NULL,
            ${TBL211RecordKey().bigCategoryKey} INTEGER NOT NULL,
            ${TBL211RecordKey().displayedOrderInBig} INTEGER NOT NULL,
            ${TBL211RecordKey().categoryName} TEXT NOT NULL,
            ${TBL211RecordKey().defaultDisplayed} INTEGER NOT NULL
          );
          ''');

    await db.execute('''
          INSERT INTO ${TBL211RecordKey().tableName} (
            ${TBL211RecordKey().id},
            ${TBL211RecordKey().smallCategoryOrderKey},
            ${TBL211RecordKey().bigCategoryKey},
            ${TBL211RecordKey().displayedOrderInBig},
            ${TBL211RecordKey().categoryName},
            ${TBL211RecordKey().defaultDisplayed}) 
            VALUES(0, 0, 0, 0, '給与', 1),
                  (1, 1, 1, 1, 'ボーナス', 1),
                  (2, 2, 1, 2, '小遣い', 1),
                  (3, 3, 1, 3, '臨時収入', 1);
          ''');

    await db.execute('''
          CREATE TABLE ${TBL212RecordKey().tableName} (
            ${TBL212RecordKey().id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${TBL212RecordKey().colorCode} TEXT NOT NULL,
            ${TBL212RecordKey().bigCategoryName} TEXT NOT NULL,
            ${TBL212RecordKey().resourcePath} TEXT NOT NULL,
            ${TBL212RecordKey().displayOrder} INTEGER NOT NULL,
            ${TBL212RecordKey().isDisplayed} INTEGER NOT NULL
          )
          ;''');

    await db.execute('''
          INSERT INTO ${TBL212RecordKey().tableName} (
          ${TBL212RecordKey().id},
          ${TBL212RecordKey().colorCode},
          ${TBL212RecordKey().bigCategoryName},
          ${TBL212RecordKey().resourcePath},
          ${TBL212RecordKey().displayOrder},
          ${TBL212RecordKey().isDisplayed}) 
          VALUES
          (0, 'FFC857', '定期収入', 'assets/images/icon_regular_income.svg', 0, 1),
          (1, 'ECB22D', '臨時収入', 'assets/images/icon_extra_income.svg', 1, 1);
          ''');

    await db.execute('''
          INSERT INTO ${TBL003RecordKey().tableName}
          (_id, date, big_category_id, price)
          VALUES
          (0, '20240101', 0, 35000),
          (1, '20240101', 1, 5000),
          (2, '20240101', 2, 32000),
          (3, '20240101', 3, 9000),
          (4, '20240101', 4, 15000),
          (5, '20240101', 5, 0),
          (6, '20240101', 6, 5000),
          (7, '20240225', 0, 32000);
          ''');

    
  }

  funcOnUpdate(Database db) async {
  // print('データベースの更新処理が呼び出されました');
  }
}
