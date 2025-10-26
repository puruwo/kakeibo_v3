import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';

final fixedCostExpenseRepositoryProvider =
    Provider<FixedCostExpenseRepository>((ref) => throw UnimplementedError());

abstract class FixedCostExpenseRepository {
  Future<int> insert(FixedCostExpenseEntity entity);
  Future<List<FixedCostExpenseEntity>> fetchAll();

  // 固定費の支出を取得する
  Future<List<FixedCostExpenseEntity>> fetchByPeriod(
      {required PeriodValue period});

  // 確定している固定費の支出合計を取得する
  Future<int> fetchTotalConfirmedFixedCostExpenseWithPeriod(
      {required PeriodValue period});

  // 確定していない固定費の一覧を取得する
  Future<List<FixedCostExpenseEntity>>
      fetchUnconfirmedFixedCostExpenseWithPeriod({required PeriodValue period});

  // 確定している固定費の合計額を取得する
  Future<List<FixedCostExpenseEntity>> fetchByFixedCostId(
      {required int fixedCostId});

  Future<void> update(FixedCostExpenseEntity entity);

  Future<void> delete(int id);

  // 未確定の固定費支出を確定させる
  Future<void> confirmExpense({required int id, required int price});

  // 固定費の支出をID指定で取得する
  Future<double> fetchFixedCostEstimatedPriceById({required int fixedCostId});

  // 日付を指定して固定費支出の合計を取得する
  Future<int> fetchDailyFixedCostExpenseByPeriod({required DateTime date});
}
