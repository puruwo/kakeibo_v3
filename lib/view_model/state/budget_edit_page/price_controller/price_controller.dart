import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';

final enteredBudgetPriceControllerProvider = Provider.autoDispose
    .family<TextEditingController, BudgetEditValue>((_, value) =>
        TextEditingController(
            text: NumberTextInputFormatter.formatInitialValue(value.price)));
