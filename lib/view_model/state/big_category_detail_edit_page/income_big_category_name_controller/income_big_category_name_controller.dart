import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final incomeBigCategoryNameControllerProvider =
    Provider.autoDispose<TextEditingController>(
  (value) => TextEditingController(text: ''),
);
