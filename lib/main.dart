import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/all_category_entity/all_category_repository.dart';
import 'package:kakeibo/repository/all_category_repository.dart';
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
          // Flavor.isDemo ? MockPostRepository() : GraphQlPostRepository()),
          ImplementsCategoryRepository(),
        ),
        smallCategoryRepositoryProvider.overrideWithValue(
          // Flavor.isDemo ? MockPostRepository() : GraphQlPostRepository()),
          ImplementsSmallCategoryRepository(),
        ),
        allCategoryRepositoryProvider.overrideWithValue(
          // Flavor.isDemo ? MockPostRepository() : GraphQlPostRepository()),
          ImplementsAllCategoryRepository(),
        ),
      ],
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
        // アプリ全体にテキストサイズの制御を適用
        // builder: (context, child) => TextScaleFactor(child: child!),
      ),
    ),
  );
}
