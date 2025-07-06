import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';

class FixedCostService {
  // 次の支払い日を設定しentityを返す
  FixedCostEntity populateNextPaymentEntity(FixedCostEntity entity) {
    // 基準日を取得
    // 最近支払い日が設定されている場合はそれを基準にする、なければ最初の支払い日を基準にする
    final recentPaymentDate =
        entity.recentPaymentDate ?? entity.firstPaymentDate;

    // 次の支払い日を計算
    DateTime nextPaymentDate;
    if (entity.intervalUnit == 1) {
      // 月単位の場合
      nextPaymentDate =
          DateTime.parse(recentPaymentDate).addMonths(entity.intervalNumber);
    } else if (entity.intervalUnit == 2) {
      // 年単位の場合
      nextPaymentDate =
          DateTime.parse(recentPaymentDate).addYears(entity.intervalNumber);
    } else {
      nextPaymentDate = DateTime(0000, 0, 0);
    }

    final result = entity.copyWith(
      recentPaymentDate: recentPaymentDate,
      nextPaymentDate: nextPaymentDate.toFormattedString(),
    );

    return result;
  }

  /// 固定費の支出エンティティを作成し、DBに挿入する
  insertToExpense(Ref ref, FixedCostEntity fixedCostEntity, String paymentDate,
      int fixedCostId) {
    // expenseEntityを作成
    final expenseEntity = ExpenseEntity(
        paymentCategoryId: fixedCostEntity.expenseSmallCategoryId,
        date: paymentDate,
        price: fixedCostEntity.variable == 0 ? fixedCostEntity.price! : 0,
        memo: fixedCostEntity.name,
        incomeSourceBigCategory: 0, // 固定費なので収入元は0
        fixedCostId: fixedCostId,
        isConfirmed:
            fixedCostEntity.variable == 1 ? 0 : 1 // 変動費でない場合は金額が確定しているとみなす
        );

    // 挿入
    ref.read(expenseRepositoryProvider).insert(expenseEntity);
  }
}
