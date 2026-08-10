import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 処理失敗(エラー)用のスナックバー。
/// ADR-018: 背景はベタ塗りせず、アイコンと文字色のみでdanger色に区別する。
class FailureSnackBar extends SnackBar {
  FailureSnackBar._({required String message})
      : super(
          backgroundColor: AppColorsDark.surfaceElevated2,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_rounded,
                size: 18,
                color: AppColorsDark.danger,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColorsDark.danger),
                ),
              ),
            ],
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
