import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';

final enteredPriceControllerProvider =
    Provider.autoDispose<TextEditingController>(
  (value) => TextEditingController.fromValue(
     NumberTextInputFormatter().formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue.empty,
      )
  ),
);