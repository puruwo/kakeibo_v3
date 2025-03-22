import 'package:intl/intl.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/tableNameKey.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

//Paymentの操作
class TBL001Impl {
  //月またぎ、1月分の毎日のレコードを取得(Mutable)
  // {
  //    '_id':
  //    'date':
  //    'price':
  //    'payment_category_id':
  //    'memo':
  //    'category_name':
  //    'big_category_name':
  //    'resource_path':
  // }
  Future<List<Map<String, dynamic>>> queryCrossMonthMutableRows(
      DateTime fromDate, DateTime toDate) async {
    final sql = '''
      SELECT a.${TBL001RecordKey().id},a.${TBL001RecordKey().date},a.${TBL001RecordKey().price},a.${TBL001RecordKey().paymentCategoryId},a.${TBL001RecordKey().memo},b.${TBL201RecordKey().categoryName},b.${TBL202RecordKey().bigCategoryName},b.${TBL202RecordKey().resourcePath} 
      FROM ${TBL001RecordKey().tableName} a
      INNER JOIN (SELECT x.${TBL201RecordKey().id},x.${TBL201RecordKey().categoryName},y.${TBL202RecordKey().bigCategoryName},y.${TBL202RecordKey().resourcePath}  
                  FROM ${TBL201RecordKey().tableName} x
                  INNER JOIN ${TBL202RecordKey().tableName} y
                  ON x.${TBL201RecordKey().bigCategoryKey} = y.${TBL202RecordKey().id}) b
      ON a.${TBL001RecordKey().paymentCategoryId} = b.${TBL201RecordKey().id}
      WHERE a.${TBL001RecordKey().date} >= ${DateFormat('yyyyMMdd').format(fromDate)} 
      AND a.${TBL001RecordKey().date} <= ${DateFormat('yyyyMMdd').format(toDate)};
      ''';
    // print(sql);
    final immutable = db.query(sql);
    final mutable = makeMutable(immutable);
    return mutable;
  }

  // 一ヶ月間の日毎の支出合計の取得
  // 支出がない日はレコードが返らない
  // {
  //  sum_price_daily:
  //  date:
  // }
  Future<List<Map<String, dynamic>>> queryPriceByDateCrossMonthRows(
      DateTime fromDate, DateTime toDate) async {
    final sql = '''
      SELECT SUM(a.price) as sum_price_daily , a.date FROM ${TBL001RecordKey().tableName} a
      WHERE ${DateFormat('yyyyMMdd').format(fromDate)} <= a.${TBL001RecordKey().date} and a.${TBL001RecordKey().date} <= ${DateFormat('yyyyMMdd').format(toDate)}
      GROUP BY a.${TBL001RecordKey().date};
      ''';
    // print(sql);
    final immutable = db.query(sql);
    final mutable = makeMutable(immutable);
    return mutable;
  }

  //1日分取得(Mutable)
  Future<List<Map<String, dynamic>>> queryDayMutableRows(DateTime date) async {
    //where句の作成
    //一周期の条件指定が難しいのでここで作成
    //ex)
    //from 2023-06-25 to 2023-07-24なら
    //(year = 2023 and month = 6 and day >= 25 and day <= 31) or (year = 2023 and month = 7 and day >= 1 and day <25)
    final where = '${TBL001RecordKey().date} = ? ';
    final whereArgs = [DateFormat('yyyyMMdd').format(date)];

    final immutable =
        db.queryRowsWhere(TBL001RecordKey().tableName, where, whereArgs);
    final mutable = makeMutable(immutable);

    return mutable;
  }

  //全データ取得
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return db.queryRows(TBL001RecordKey().tableName);
  }
}

//bigCategory指定で一ヶ月分のカテゴリーごとのレコードの取得
//月またぎ、1月分取得(Mutable)
// {
//  sum_by_bigcategory:
//  big_category_key:
// }
Future<List<Map<String, dynamic>>> queryCrossMonthMutableRowsByCategory(
    DateTime fromDate, DateTime toDate) async {
  final sql = '''
            SELECT a.${TBL202RecordKey().id}, IFNULL(b.sum_by_bigcategory, 0) as sum_by_bigcategory FROM TBL202 a
            LEFT JOIN (SELECT SUM(price) as sum_by_bigcategory, y.${TBL201RecordKey().bigCategoryKey}
                        FROM ${TBL001RecordKey().tableName} x
						            INNER JOIN ${TBL201RecordKey().tableName} y
						            ON x.${TBL001RecordKey().paymentCategoryId} = y.${TBL201RecordKey().id}
                        WHERE ${TBL001RecordKey().date} >= ${DateFormat('yyyyMMdd').format(fromDate)} AND ${TBL001RecordKey().date} < ${DateFormat('yyyyMMdd').format(toDate)}  
                        GROUP BY y.${TBL201RecordKey().bigCategoryKey}) b
            on a.${TBL202RecordKey().id} = b.${TBL201RecordKey().bigCategoryKey}
            ORDER BY a.${TBL202RecordKey().displayOrder}
            ;
            ''';

  print(sql);
  final immutable = db.query(sql);
  final mutable = makeMutable(immutable);

  return mutable;
}


//入力した日付の過去最近の目標の合計を取得
Future<List<Map<String, dynamic>>> queryMonthlyAllBudgetSum(DateTime dt) async {
  final sql = '''
            SELECT SUM(a.${TBL003RecordKey().price}) as budget_sum
            FROM ${TBL003RecordKey().tableName} a
              INNER JOIN ${TBL202RecordKey().tableName} b
              ON a.${TBL003RecordKey().bigCategoryId} = b.${TBL202RecordKey().id}
            WHERE ${TBL003RecordKey().date} = (
              SELECT MAX(${TBL003RecordKey().date})
              FROM ${TBL003RecordKey().tableName} a2
              WHERE a.${TBL003RecordKey().bigCategoryId} = a2.${TBL003RecordKey().bigCategoryId}
            )
            ORDER BY b.${TBL202RecordKey().displayOrder}
            ;
            ''';

  final immutable = db.query(sql);
  final mutable = makeMutable(immutable);

  return mutable;
}

//入力した日付の過去最近の目標の取得
// {
//  big_category_id
//  price
//  color_code
//  big_category_name
//  resource_path
//  display_order
//  is_displayed
// }
Future<List<Map<String, dynamic>>> queryMonthlyCategoryBudget(
    DateTime dt) async {
  final sql = '''
            SELECT a.${TBL003RecordKey().bigCategoryId},a.${TBL003RecordKey().price},b.${TBL202RecordKey().colorCode},b.${TBL202RecordKey().bigCategoryName},b.${TBL202RecordKey().resourcePath},b.${TBL202RecordKey().displayOrder},b.${TBL202RecordKey().isDisplayed}
            FROM ${TBL003RecordKey().tableName} a
              INNER JOIN ${TBL202RecordKey().tableName} b
              ON a.${TBL003RecordKey().bigCategoryId} = b.${TBL202RecordKey().id}
            WHERE ${TBL003RecordKey().date} = (
              SELECT MAX(${TBL003RecordKey().date})
              FROM ${TBL003RecordKey().tableName} a2
              WHERE a.${TBL003RecordKey().bigCategoryId} = a2.${TBL003RecordKey().bigCategoryId}
            )
            ORDER BY b.${TBL202RecordKey().displayOrder}
            ;
            ''';

  print(sql);

  final immutable = db.query(sql);
  final mutable = makeMutable(immutable);

  return mutable;
}

//指定したカテゴリーの過去最近の目標の取得
// {
//  price
// }
Future<int> querySpecificCategoryBudget(int bigCategoryId) async {
  final sql = '''
            SELECT a.${TBL003RecordKey().price}
            FROM ${TBL003RecordKey().tableName} a
              INNER JOIN ${TBL202RecordKey().tableName} b
              ON a.${TBL003RecordKey().bigCategoryId} = b.${TBL202RecordKey().id}
            WHERE 
			        b._id = $bigCategoryId
			      AND ${TBL003RecordKey().date} = (
              SELECT MAX(${TBL003RecordKey().date})
              FROM ${TBL003RecordKey().tableName} a2
              WHERE a.${TBL003RecordKey().bigCategoryId} = a2.${TBL003RecordKey().bigCategoryId}
            )
            ;
            ''';

  // print(sql);

  final immutable = db.query(sql);
  final mutable = await makeMutable(immutable);

  // int形式にしてreturn
  return mutable[0][TBL003RecordKey().price];
}

Future<int> getDisplaySisytCategoryNumber() async {
  final sql = '''
              SELECT count(*) as count FROM ${TBL201RecordKey().tableName} a
              WHERE a.${TBL201RecordKey().defaultDisplayed} = 1
              ;
              ''';
  List<Map<String, dynamic>> listMap = await db.query(sql);
  final count = listMap[0]['count'];
  return count;
}

Future<int> getDisplaySyunyuCategoryNumber() async {
  final sql = '''
              SELECT count(*) as count FROM ${TBL211RecordKey().tableName} a
              WHERE a.${TBL211RecordKey().defaultDisplayed} = 1
              ;
              ''';
  List<Map<String, dynamic>> listMap = await db.query(sql);
  final count = listMap[0]['count'];
  return count;
}

// all_category_entityが代替

// その月の支出合計
// {
// year_month:
// sum_price:
// }
Future<List<Map<String, dynamic>>> getMonthPaymentSum(
    DateTime fromDate, DateTime toDate) {
  final sql = '''
              SELECT SUBSTR(CAST(a.date AS STRING), 1, 6) AS year_month, COALESCE(SUM(price), 0) as sum_price FROM TBL001 a
              WHERE ${TBL001RecordKey().date} >= ${DateFormat('yyyyMMdd').format(fromDate)} AND ${TBL001RecordKey().date} <= ${DateFormat('yyyyMMdd').format(toDate)};
              ''';
  final immutable = db.query(sql);
  final mutable = makeMutable(immutable);

  return mutable;
}


// その月の収入合計
// {
// year_month:
// sum_price:
// }
Future<List<Map<String, dynamic>>> getMonthIncomeSum(
    DateTime fromDate, DateTime toDate) {
  final sql = '''
              SELECT SUBSTR(CAST(a.date AS STRING), 1, 6) AS year_month, COALESCE(SUM(price), 0) as sum_price FROM TBL002 a
              WHERE ${TBL002RecordKey().date} >= ${DateFormat('yyyyMMdd').format(fromDate)} AND ${TBL002RecordKey().date} <= ${DateFormat('yyyyMMdd').format(toDate)};
              ''';
  // print(sql);
  final immutable = db.query(sql);
  final mutable = makeMutable(immutable);

  return mutable;
}

// 日付と大カテゴリー指定した予算取得
// 1recordのみreturn
Future<List<Map<String, dynamic>>> getSpecifiedDateBigCategoryBudget(
    String date, int bigCategory) async {
  final sql = '''
              SELECT * FROM ${TBL003RecordKey().tableName} a
              WHERE a.${TBL003RecordKey().date} = $date
              AND a.${TBL003RecordKey().bigCategoryId} = $bigCategory
              ''';
  // print(sql);
  final immutable = db.query(sql);
  final mutable = await makeMutable(immutable);
  return mutable;
}

// (Payment)categoryIdからcategoryOrderを取得
Future<int> getPaymentCategoryOrderKeyFromCategoryId(int categoryId) async {
  final sql = '''
              SELECT a.${TBL201RecordKey().smallCategoryOrderKey} FROM ${TBL201RecordKey().tableName} a
              WHERE a.${TBL201RecordKey().id} = $categoryId
              ''';
  // print(sql);
  final immutable = db.query(sql);
  final mutable = await makeMutable(immutable);
  final smallCategoryOrderKey =
      mutable[0][TBL201RecordKey().smallCategoryOrderKey];
  return smallCategoryOrderKey;
}

// (Payment)categoryOrderからcategoryIdを取得
Future<int> getPaymentCategoryIdFromCategoryOrder(int categoryOrder) async {
  final sql = '''
              SELECT a.${TBL201RecordKey().id} FROM ${TBL201RecordKey().tableName} a
              WHERE a.${TBL201RecordKey().smallCategoryOrderKey} = $categoryOrder
              ''';
  // print(sql);
  final immutable = db.query(sql);
  final mutable = await makeMutable(immutable);
  final categoryId = mutable[0][TBL201RecordKey().id];
  return categoryId;
}

// (Income)categoryOrderからcategoryIdを取得
Future<int> getIncomeCategoryIdFromCategoryOrder(int categoryOrder) async {
  final sql = '''
              SELECT a.${TBL211RecordKey().id} FROM ${TBL211RecordKey().tableName} a
              WHERE a.${TBL211RecordKey().smallCategoryOrderKey} = $categoryOrder
              ''';
  // print(sql);
  final immutable = db.query(sql);
  final mutable = await makeMutable(immutable);
  final categoryId = mutable[0][TBL211RecordKey().id];
  return categoryId;
}

// {
//  id:
//  small_category_order_key
//  big_category_key
//  displayed_order_in_big
//  category_name
//  default_displayed
// }
// bigCategoryId指定でcategory情報を取得
Future<List<Map<String, dynamic>>> getCategoryDataFromCategoryId(
    int bigCategoryId) async {
  final sql = '''
              SELECT * FROM ${TBL201RecordKey().tableName} a
              WHERE a.${TBL201RecordKey().bigCategoryKey} = $bigCategoryId
              ORDER BY a.${TBL201RecordKey().displayedOrderInBig}
              ''';
  print(sql);
  final immutable = db.query(sql);
  final mutable = await makeMutable(immutable);
  return mutable;
}

// {
//  id:
//  color_code
//  big_category_name
//  resource_path
//  display_order
//  is_displayed
// }
// bigCategoryId指定でpropertyを取得
Future<Map<String, dynamic>> getBigCategoryProperty(int bigCategoryId) async {
  final sql = '''
              SELECT * FROM ${TBL202RecordKey().tableName} a
              WHERE a.${TBL202RecordKey().id} = $bigCategoryId
              ''';
  // print(sql);
  final immutable = db.query(sql);
  final mutable = await makeMutable(immutable);
  return mutable[0];
}

// 大カテゴリーに含まれる小カテゴリーの名前を返す
Future<List<String>> querySmallCategoryNameList(int bigCategoryId) async {
  final sql = '''
              SELECT ${TBL201RecordKey().categoryName} FROM ${TBL201RecordKey().tableName} a
              WHERE a.${TBL201RecordKey().bigCategoryKey} = $bigCategoryId
              AND a.${TBL201RecordKey().defaultDisplayed} = 1
              ORDER BY a.${TBL201RecordKey().displayedOrderInBig}
              ''';
  // print(sql);
  final immutable = db.query(sql);
  final mutable = await makeMutable(immutable);
  final nameList = <String>[];
  for (int i = 0; i < mutable.length; i++) {
    nameList.add(mutable[i][TBL201RecordKey().categoryName] as String);
  }
  return nameList;
}

Future<List<Map<String, dynamic>>> makeMutable(
    Future<List<Map<String, dynamic>>> mapsList) async {
  List<Map<String, dynamic>> oldList = await mapsList;
  List<Map<String, dynamic>> newList = [];
  for (var map in oldList) {
    Map<String, dynamic> newMap = Map<String, dynamic>.from(map);
    newList.add(newMap);
  }
  return newList;
}
