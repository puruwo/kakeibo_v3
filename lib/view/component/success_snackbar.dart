import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 処理成功用スナックバー。
/// ADR-018: 背景はベタ塗りせず、アイコンと文字色のみでincome色に区別する。
class SuccessSnackBar extends SnackBar {
  SuccessSnackBar._({required String message})
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
                Icons.check_circle_rounded,
                size: 18,
                color: AppColorsDark.income,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.snackBarMessage.copyWith(
                    color: AppColorsDark.income,
                  ),
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
      ..showSnackBar(SuccessSnackBar._(message: message));
  }
}
