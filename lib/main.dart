import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_repository.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_repository.dart';
import 'package:kakeibo/domain/db/aggregation_start_month_entity/aggregation_start_month_repository.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_repository.dart';
import 'package:kakeibo/domain/db/budget/budget_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/db/month_basis_entity/month_basis_repository.dart';
import 'package:kakeibo/domain/db/year_basis_entity/year_basis_entity_repository.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/repository/aggregation_start_day_repository.dart';
import 'package:kakeibo/repository/aggregation_start_month_repository.dart';
import 'package:kakeibo/repository/batch_history_repository.dart';
import 'package:kakeibo/repository/expense_big_category_repository.dart';
import 'package:kakeibo/repository/budget_repository.dart';
import 'package:kakeibo/repository/daily_expense_repository.dart';
import 'package:kakeibo/repository/expense_repository.dart';
import 'package:kakeibo/repository/fixed_cost_repository.dart';
import 'package:kakeibo/repository/fixed_cost_expense_repository.dart';
import 'package:kakeibo/repository/fixed_cost_category_repository.dart';
import 'package:kakeibo/repository/income_big_category_repository.dart';
import 'package:kakeibo/repository/income_repository.dart';
import 'package:kakeibo/repository/income_small_category_repository.dart';
import 'package:kakeibo/repository/month_basis_repository.dart';
import 'package:kakeibo/repository/small_category_Tile_repository.dart';
import 'package:kakeibo/repository/expense_small_category_repository.dart';
import 'package:kakeibo/repository/year_basis_repository.dart';
import 'package:kakeibo/view/foundation.dart';

import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_repository.dart';
import 'package:kakeibo/repository/category_repository.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        categoryAccountingRepositoryProvider.overrideWithValue(
          ImplementsCategoryAccountingRepository(),
        ),
        smallCategoryTileRepositoryProvider.overrideWithValue(
          ImplementsSmallCategoryTileRepository(),
        ),
        dailyExpenseRepositoryProvider.overrideWithValue(
          ImplementsDailyExpenseRepository(),
        ),
        aggregationStartMonthRepositoryProvider.overrideWithValue(
          ImplementsAggregationStartMonthRepository(),
        ),
        aggregationStartDayRepositoryProvider.overrideWithValue(
          ImplementsAggregationStartDayRepository(),
        ),
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          ImplementsExpenseSmallCategoryRepository(),
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          ImplementsExpenseBigCategoryRepository(),
        ),
        incomeBigCategoryRepositoryProvider.overrideWithValue(
          ImplementsIncomeBigCategoryRepository(),
        ),
        incomeSmallCategoryRepositoryProvider.overrideWithValue(
          ImplementsIncomeSmallCategoryRepository(),
        ),
        expenseRepositoryProvider.overrideWithValue(
          ImplementsExpenseRepository(),
        ),
        monthBasisRepositoryProvider.overrideWithValue(
          ImplementsMonthBasisRepository(),
        ),
        yearBasisRepositoryProvider.overrideWithValue(
          ImplementsYearBasisRepository(),
        ),
        budgetRepositoryProvider.overrideWithValue(
          ImplementsBudgetRepository(),
        ),
        incomeRepositoryProvider.overrideWithValue(
          ImplementsIncomeRepository(),
        ),
        fixedCostRepositoryProvider.overrideWithValue(
          ImplementsFixedCostRepository(),
        ),
        batchHistoryRepositoryProvider.overrideWithValue(
          ImplementsBatchHistoryRepository(),
        ),
        fixedCostExpenseRepositoryProvider.overrideWithValue(
          ImplementsFixedCostExpenseRepository(),
        ),
        fixedCostCategoryRepositoryProvider.overrideWithValue(
          ImplementsFixedCostCategoryRepository(),
        ),
      ],
      observers: const [ProviderLogger()],
      child: MaterialApp(
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: const TextScaler.linear(1.0),
              boldText: false,
            ),
            child: child!,
          );
        },
        home: const Foundation(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
      ),
    ),
  );
}
