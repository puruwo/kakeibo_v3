import 'package:kakeibo/model/db_read_impl.dart';

class AllBudgetGetter {
  Future<List<Map<String, dynamic>>> build(DateTime dt) async {
    final allBudget = queryMonthlyAllBudgetSum(dt);
    return allBudget;
  }
}
