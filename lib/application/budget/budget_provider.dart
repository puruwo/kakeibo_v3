import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/budget/budget_usecase.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';

final budgetProvider = FutureProvider.autoDispose
    .family<List<BudgetEditValue>, DateScopeEntity>((ref, dateScope) =>
        ref.watch(budgetUsecaseProvider).fetchAll(dateScope: dateScope));
