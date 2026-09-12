import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 処理成功用スナックバー。
/// ADR-018: 背景はベタ塗りせず、アイコンと文字色のみでincome色に区別する。
/// 地・角丸・表示位置は AppTheme の snackBarTheme に集約（KP-013）。
class SuccessSnackBar extends SnackBar {
  SuccessSnackBar._({
    required String message,
    required AppColors colors,
    required AppTextStyles textStyles,
  }) : super(
         duration: const Duration(seconds: 2),
         content: Row(
           children: [
             Icon(Icons.check_circle_rounded, size: 18, color: colors.income),
             const SizedBox(width: AppSpacing.sm),
             Expanded(
               child: Text(
                 message,
                 style: textStyles.snackBarMessage.copyWith(
                   color: colors.income,
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
    // 色は表示先のテーマ（ライト／ダーク）から解決する
    final context = scaffoldMessenger.context;
    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SuccessSnackBar._(
          message: message,
          colors: context.colors,
          textStyles: context.textStyles,
        ),
      );
  }
}
