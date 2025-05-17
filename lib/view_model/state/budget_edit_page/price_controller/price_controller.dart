
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';

final enteredBudgetPriceControllerProvider = Provider.autoDispose.family<TextEditingController, BudgetEditValue>(
(_,value) => TextEditingController(text: value.price.toString())
);