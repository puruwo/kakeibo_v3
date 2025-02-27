import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberTextInputFormatter extends TextInputFormatter {
final _exceptNumberAndComma = RegExp(r'[^0-9,]+');
final _numberFormatter = NumberFormat('#,###');
@override
TextEditingValue formatEditUpdate(
TextEditingValue oldValue,
TextEditingValue newValue,
  ) {
if (newValue.text.isEmpty) {
return newValue;
    }
if (_exceptNumberAndComma.hasMatch(newValue.text)) {
return oldValue;
    }
final isDeleted = newValue.text.length - oldValue.text.length < 0;
final String adjustedText;
if (isDeleted) {
final isCommaDeleted = oldValue.text.substring(
            newValue.selection.extentOffset,
            oldValue.selection.extentOffset,
          ) ==
',';
if (isCommaDeleted) {
        adjustedText = newValue.text.replaceRange(
          newValue.selection.extentOffset - 1,
          newValue.selection.extentOffset,
'',
        );
      } else {
        adjustedText = newValue.text;
      }
    } else {
      adjustedText = newValue.text;
    }
final int value;
try {
      value = int.parse(adjustedText.replaceAll(',', ''));
    } on FormatException {
return oldValue;
    }
final formattedText = _numberFormatter.format(value);
final selection = newValue.selection.extentOffset +
        formattedText.length -
        newValue.text.length;
return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selection < 0 ? 0 : selection),
    );
  }
}