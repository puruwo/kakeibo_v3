import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/budget/budget_provider.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';

// 選択期間を取得し、Valuesを取得する中間プロバイダ
final resolvedBudgetEditValueProvider =
    FutureProvider<List<BudgetEditValue>>((ref) async {

  // 選択された日付から代表月を取得する
  final representativeMonth = await ref.watch(analyzePageDateScopeEntityProvider.selectAsync((data) => data.representativeMonth));

  // 選択された代表月を元に、Valuesを取得する
  final values = ref.watch(budgetProvider(representativeMonth).future);
  return values;
});
