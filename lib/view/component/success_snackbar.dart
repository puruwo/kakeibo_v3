import 'package:flutter/material.dart';

/// 処理成功用スナックバー
class SuccessSnackBar extends SnackBar {
  SuccessSnackBar._({required String message})
      : super(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        );

  static void show(
    ScaffoldMessengerState scaffoldMessenger, {
    required String message,
  }) {
    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SuccessSnackBar._(message: message));
  }
}
