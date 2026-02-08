import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 予算編集中の金額を一時保持するプロバイダ
/// key: expenseBigCategoryId, value: 入力された金額
/// BudgetPageSummaryAreaがwatchし、リアルタイムでサマリーに反映する
final editingBudgetPricesProvider =
    StateProvider.autoDispose<Map<int, int>>((ref) => {});
