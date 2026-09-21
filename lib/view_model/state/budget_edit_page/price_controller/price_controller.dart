import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/view_model/state/budget_edit_page/editing_budget_prices/editing_budget_prices.dart';

final enteredBudgetPriceControllerProvider = Provider.autoDispose
    .family<TextEditingController, BudgetEditValue>((ref, value) {
  // 一覧は遅延生成のため、行が画面外へ出るとこのコントローラーは破棄される。
  // 作り直すときは編集中の金額を優先し、入力した値が消えないようにする
  final price =
      ref.read(editingBudgetPricesNotifierProvider)[value.expenseBigCategoryId] ??
          value.price;
  return TextEditingController(
      // 未設定（0円）は空欄にしてヒント「金額を入力」を見せる（仕様 §8.5）
      text: price == 0
          ? ''
          : NumberTextInputFormatter.formatInitialValue(price));
});
