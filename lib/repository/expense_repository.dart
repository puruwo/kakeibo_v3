import 'package:intl/intl.dart';
import 'package:kakeibo/domain/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/tbl001/expense_entity.dart';
import 'package:kakeibo/domain/tbl001/expense_repository.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/providerLogger.dart';

//DatabaseHelperの初期化
DatabaseHelper db = DatabaseHelper.instance;

class ImplementsExpenseRepository implements ExpenseRepository {
  // カテゴリーを指定しないで取得する
  @override
  Future<List<ExpenseEntity>> fetchWithoutCategory(
      {required MonthPeriodValue period}) async {
    final sql = '''
      SELECT 
        a._id AS id,
        a.date AS date,
        a.price AS price, 
        a.payment_category_id AS paymentCategoryId, 
        a.memo AS memo
      FROM TBL001 a
      WHERE a.date >= ${DateFormat('yyyyMMdd').format(period.startDatetime)} AND a.date <= ${DateFormat('yyyyMMdd').format(period.endDatetime)};
    ''';

    try {
      final jsonList = await db.query(sql);

      final results = jsonList.map((json) => ExpenseEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }
}
