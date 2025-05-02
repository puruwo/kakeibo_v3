import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/aggregation_start_day_entity/aggregation_start_day_repository.dart';
import 'package:kakeibo/domain/core/all_category_accounting_entity/all_category_accounting_repository.dart';
import 'package:kakeibo/domain/core/daily_expense_entity/daily_expense_repository.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/providerLogger.dart';
import 'package:kakeibo/repository/aggregation_start_day_repository.dart';
import 'package:kakeibo/repository/all_category_repository.dart';
import 'package:kakeibo/repository/big_category_repository.dart';
import 'package:kakeibo/repository/daily_expense_repository.dart';
import 'package:kakeibo/repository/expense_repository.dart';
import 'package:kakeibo/repository/small_category_Tile_repository.dart';
import 'package:kakeibo/repository/small_category_repository.dart';
import 'package:kakeibo/view/foundation.dart';

import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/small_category_tile_entity/small_category_tile_repository.dart';
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
        allCategoryAccountingRepositoryProvider.overrideWithValue(
          ImplementsAllCategoryAccountingRepository(),
        ),
        dailyExpenseRepositoryProvider.overrideWithValue(
          ImplementsDailyExpenseRepository(),
        ),
        aggregationStartDayRepositoryProvider.overrideWithValue(
          ImplementsAggregationStartDayRepository(),
        ),
        expenseSmallCategoryRepositoryProvider.overrideWithValue(
          ImplementsSmallCategoryRepository(),
        ),
        expensebigCategoryRepositoryProvider.overrideWithValue(
          ImplementsBigCategoryRepository(),
        ),
        expenseRepositoryProvider.overrideWithValue(
          ImplementsExpenseRepository(),
        ),
      ],
      observers: const [ProviderLogger()],
      child: MaterialApp(
        home: MediaQuery.withClampedTextScaling(
          // テキストサイズの制御
          minScaleFactor: 0.7,
          maxScaleFactor: 0.95,
          child: Foundation(),
        ),
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
      ),
    ),
  );
}
