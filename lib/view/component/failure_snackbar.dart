import 'package:flutter/material.dart';

/// 処理失敗(エラー)用のスナックバー
class FailureSnackBar extends SnackBar {
  FailureSnackBar._({required String message})
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
      ..showSnackBar(FailureSnackBar._(message: message));
  }
}
