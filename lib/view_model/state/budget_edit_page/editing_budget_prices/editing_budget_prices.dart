import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editing_budget_prices.g.dart';

/// 予算編集中の金額を一時保持するプロバイダ
/// key: expenseBigCategoryId, value: 入力された金額
/// BudgetPageSummaryAreaがwatchし、リアルタイムでサマリーに反映する
@riverpod
class EditingBudgetPricesNotifier extends _$EditingBudgetPricesNotifier {
  @override
  Map<int, int> build() => {};

  void update(int categoryId, int price) {
    state = {...state, categoryId: price};
  }
}
