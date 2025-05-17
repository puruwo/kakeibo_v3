import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/budget/budget_usecase.dart';
import 'package:kakeibo/domain/core/month_value/month_value.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';

final budgetProvider = FutureProvider.autoDispose
    .family<List<BudgetEditValue>, MonthValue>((ref, month) =>
        ref.watch(budgetUsecaseProvider).fetchAll(monthValue: month));
