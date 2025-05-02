import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final enteredMemoControllerProvider =
    Provider.autoDispose<TextEditingController>(
  (value) => TextEditingController(text: '')
);