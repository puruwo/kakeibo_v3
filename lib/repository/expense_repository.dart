import 'package:intl/intl.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
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

      final results =
          jsonList.map((json) => ExpenseEntity.fromJson(json)).toList();

      return results;
    } catch (e) {
      logger.e('[FAIL]: $e');
      return [];
    }
  }

  @override
  void insert(ExpenseEntity expenseEntity) {
    db.insert('TBL001', {
      'date': expenseEntity.date,
      'price': expenseEntity.price,
      'payment_category_id': expenseEntity.paymentCategoryId,
      'memo': expenseEntity.memo
    });
  }

  @override
  void update(ExpenseEntity expenseEntity) {
    db.update(
        'TBL001',
        {
          'date': expenseEntity.date,
          'price': expenseEntity.price,
          'payment_category_id': expenseEntity.paymentCategoryId,
          'memo': expenseEntity.memo
        },
        expenseEntity.id);
  }

  @override
  void delete(int id) async {
    await db.delete('TBL001', id);
    logger.i('TBL001で$idのレコードを削除しました');
  }
}
