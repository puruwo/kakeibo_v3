import 'package:intl/intl.dart';
import 'package:kakeibo/domain/tbl001/expense_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'original_expense_entity.g.dart';

@riverpod
class OriginalExpenseEntityNotifier extends _$OriginalExpenseEntityNotifier {
  @override
  ExpenseEntity build() {
    DateTime dt = DateTime.now();
    String date = DateFormat('yyyyMMdd').format(dt);
    return ExpenseEntity(
        id: 0, date: date, price: 0, paymentCategoryId: 0, memo: '');
  }

  void setData(ExpenseEntity expenseEntity) {
    state = expenseEntity;
  }
}
