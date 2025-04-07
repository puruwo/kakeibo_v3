import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/aggregation_start_day_entity/aggregation_start_day_repository.dart';
import 'package:kakeibo/domain/all_category_entity/all_category_repository.dart';
import 'package:kakeibo/domain/daily_expense_entity/daily_expense_repository.dart';
import 'package:kakeibo/providerLogger.dart';
import 'package:kakeibo/repository/aggregation_start_day_repository.dart';
import 'package:kakeibo/repository/all_category_repository.dart';
import 'package:kakeibo/repository/daily_expense_repository.dart';
import 'package:kakeibo/view/foundation.dart';

import 'package:kakeibo/domain/category_entity/category_repository.dart';
import 'package:kakeibo/domain/small_category_entity/small_category_repository.dart';
import 'package:kakeibo/repository/category_repository.dart';
import 'package:kakeibo/repository/small_category_repository.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(
          ImplementsCategoryRepository(),
        ),
        smallCategoryRepositoryProvider.overrideWithValue(
          ImplementsSmallCategoryRepository(),
        ),
        allCategoryRepositoryProvider.overrideWithValue(
          ImplementsAllCategoryRepository(),
        ),
        dailyExpenseRepositoryProvider.overrideWithValue(
          ImplementsDailyExpenseRepository(),
        ),
        aggregationStartDayRepositoryProvider.overrideWithValue(
          ImplementsAggregationStartDayRepository(),
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
