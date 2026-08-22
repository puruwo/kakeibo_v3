import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';

final enteredBudgetPriceControllerProvider = Provider.autoDispose
    .family<TextEditingController, BudgetEditValue>((_, value) =>
        TextEditingController(
            // 未設定（0円）は空欄にしてヒント「金額を入力」を見せる（仕様 §8.5）
            text: value.price == 0
                ? ''
                : NumberTextInputFormatter.formatInitialValue(value.price)));
