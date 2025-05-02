import 'package:intl/intl.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/tableNameKey.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

//Paymentの操作
class TBL001Impl {
  

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
