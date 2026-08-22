import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';

class FixedCostService {
  // 次の支払い日を設定しentityを返す
  FixedCostEntity populateNextPaymentEntity(FixedCostEntity entity) {
    // 次支払い日が設定されている場合はそれを基準にする、なければ最初の支払い日を基準にする
    final recentPaymentDate = entity.nextPaymentDate ?? entity.firstPaymentDate;

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

  /// 固定費の実績行を作成し、expenseに挿入する（v10で fixed_cost_expense から移管）
  ///
  /// 確定型（variable=0）: price=マスタの金額 / is_confirmed=1 / estimated_price=NULL
  /// 変動型（variable=1）: price=NULL / estimated_price=マスタの推定額 / is_confirmed=0
  /// 実額と予想額は別列に分離して保持する（仕様 §3）。
  /// 挿入の失敗を呼び出し元が検知できるよう、完了を待てるFutureを返す
  Future<void> insertToFixedCostExpense(
    Ref ref,
    FixedCostEntity fixedCostEntity,
    String paymentDate,
  ) async {
    // 金額が毎回変わる固定費か（マスタのvariableから導出する。仕様 §3）
    final isVariable = fixedCostEntity.variable == 1;

    final expenseEntity = ExpenseEntity(
      date: paymentDate,
      // 変動型は実額が未確定なのでNULL。予想額はestimatedPriceに持たせる
      price: isVariable ? null : fixedCostEntity.price,
      // カテゴリーはマスタの支出小カテゴリーを引き継ぐ
      paymentCategoryId: fixedCostEntity.expenseSmallCategoryId,
      memo: fixedCostEntity.name,
      // 拠出元は通常支出と同じ既定値（生活支出）
      incomeSourceBigCategory: AccountTypeConstants.living,
      fixedCostId: fixedCostEntity.id!,
      isConfirmed: isVariable ? 0 : 1,
      estimatedPrice: isVariable ? fixedCostEntity.estimatedPrice : null,
    );

    // 挿入
    await ref
        .read(expenseRepositoryProvider)
        .insertFixedCostExpense(expenseEntity);
  }

  /// 確定した固定費の合計と未確定の固定費の合計値をまとめて返却する
  Future<int> getFixedCostTotal(Ref ref, DateScopeEntity dateScope) async {
    // 支払いがある固定費の合計を取得
    // 支払額未定の固定費は推定額を使用する
    final confirmedFixedCostExpenseTotal = await ref
        .read(fixedCostExpenseRepositoryProvider)
        .fetchTotalConfirmedFixedCostExpenseWithPeriod(
            period: dateScope.aggregationMonthPeriod);
    final unconfirmedFixedCostList = await ref
        .read(fixedCostExpenseRepositoryProvider)
        .fetchUnconfirmedFixedCostExpenseWithPeriod(
            period: dateScope.aggregationMonthPeriod);
    final unconfirmedFixedCostEstimatedTotal = await Future.wait(
        unconfirmedFixedCostList.map((element) async {
      final estimatePrice = await ref
          .read(fixedCostRepositoryProvider)
          .fetchEstimatedPriceById(id: element.fixedCostId);
      return estimatePrice;
    })).then((values) => values.fold<int>(
        0, (previousValue, estimatePrice) => previousValue + estimatePrice));

    return confirmedFixedCostExpenseTotal + unconfirmedFixedCostEstimatedTotal;
  }
}
