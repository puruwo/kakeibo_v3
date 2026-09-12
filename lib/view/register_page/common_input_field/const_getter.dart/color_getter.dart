import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/theme/app_colors.dart';

Color getPillColor(BuildContext context, TransactionMode mode) {
  return switch (mode) {
    TransactionMode.expense => context.colors.expense,
    TransactionMode.income => context.colors.income,
  };
}

Color getPillBackgroundColor(BuildContext context, TransactionMode mode) {
  return switch (mode) {
    TransactionMode.expense => context.colors.expense.withValues(alpha: 0.1),
    TransactionMode.income => context.colors.income.withValues(alpha: 0.1),
  };
}
