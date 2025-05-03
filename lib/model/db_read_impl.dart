import 'package:intl/intl.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

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
      SELECT SUM(a.price) as sum_price_daily , a.date FROM ${SqfExpense.tableName} a
      WHERE ${DateFormat('yyyyMMdd').format(fromDate)} <= a.${SqfExpense.date} and a.${SqfExpense.date} <= ${DateFormat('yyyyMMdd').format(toDate)}
      GROUP BY a.${SqfExpense.date};
      ''';
    // print(sql);
    final immutable = db.query(sql);
    final mutable = makeMutable(immutable);
    return mutable;
  }

  //全データ取得
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return db.queryRows(SqfExpense.tableName);
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
            SELECT a.${SqfExpenseBigCategory().id}, IFNULL(b.sum_by_bigcategory, 0) as sum_by_bigcategory FROM TBL202 a
            LEFT JOIN (SELECT SUM(price) as sum_by_bigcategory, y.${TBL201RecordKey().bigCategoryKey}
                        FROM ${SqfExpense.tableName} x
						            INNER JOIN ${TBL201RecordKey().tableName} y
						            ON x.${SqfExpense.paymentCategoryId} = y.${TBL201RecordKey().id}
                        WHERE ${SqfExpense.date} >= ${DateFormat('yyyyMMdd').format(fromDate)} AND ${SqfExpense.date} < ${DateFormat('yyyyMMdd').format(toDate)}  
                        GROUP BY y.${TBL201RecordKey().bigCategoryKey}) b
            on a.${SqfExpenseBigCategory().id} = b.${TBL201RecordKey().bigCategoryKey}
            ORDER BY a.${SqfExpenseBigCategory().displayOrder}
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
            SELECT SUM(a.${SqfBudget().price}) as budget_sum
            FROM ${SqfBudget().tableName} a
              INNER JOIN ${SqfExpenseBigCategory().tableName} b
              ON a.${SqfBudget().bigCategoryId} = b.${SqfExpenseBigCategory().id}
            WHERE ${SqfBudget().date} = (
              SELECT MAX(${SqfBudget().date})
              FROM ${SqfBudget().tableName} a2
              WHERE a.${SqfBudget().bigCategoryId} = a2.${SqfBudget().bigCategoryId}
            )
            ORDER BY b.${SqfExpenseBigCategory().displayOrder}
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
            SELECT a.${SqfBudget().bigCategoryId},a.${SqfBudget().price},b.${SqfExpenseBigCategory().colorCode},b.${SqfExpenseBigCategory().bigCategoryName},b.${SqfExpenseBigCategory().resourcePath},b.${SqfExpenseBigCategory().displayOrder},b.${SqfExpenseBigCategory().isDisplayed}
            FROM ${SqfBudget().tableName} a
              INNER JOIN ${SqfExpenseBigCategory().tableName} b
              ON a.${SqfBudget().bigCategoryId} = b.${SqfExpenseBigCategory().id}
            WHERE ${SqfBudget().date} = (
              SELECT MAX(${SqfBudget().date})
              FROM ${SqfBudget().tableName} a2
              WHERE a.${SqfBudget().bigCategoryId} = a2.${SqfBudget().bigCategoryId}
            )
            ORDER BY b.${SqfExpenseBigCategory().displayOrder}
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
              WHERE ${SqfIncome().date} >= ${DateFormat('yyyyMMdd').format(fromDate)} AND ${SqfIncome().date} <= ${DateFormat('yyyyMMdd').format(toDate)};
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
              SELECT * FROM ${SqfBudget().tableName} a
              WHERE a.${SqfBudget().date} = $date
              AND a.${SqfBudget().bigCategoryId} = $bigCategory
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
              SELECT * FROM ${SqfExpenseBigCategory().tableName} a
              WHERE a.${SqfExpenseBigCategory().id} = $bigCategoryId
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
