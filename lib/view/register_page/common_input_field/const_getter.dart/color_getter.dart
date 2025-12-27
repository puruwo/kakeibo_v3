import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';

Color getPillColor(TransactionMode mode) {
  return switch (mode) {
    TransactionMode.expense => MyColors.pink,
    TransactionMode.income => Colors.lightBlue,
    TransactionMode.fixedCost => MyColors.pink,
  };
}

Color getPillBackgroundColor(TransactionMode mode) {
  return switch (mode) {
    TransactionMode.expense => MyColors.pink.withOpacity(0.1),
    TransactionMode.income => Colors.lightBlue.withOpacity(0.1),
    TransactionMode.fixedCost => MyColors.pink.withOpacity(0.1),
  };
}
