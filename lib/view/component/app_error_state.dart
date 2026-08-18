import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// ADR-018: 一覧取得等でエラーが起きたときの共通表示。
/// `AsyncValue.when` の `error` 分岐で生の例外（`Text('$error')`）をそのまま
/// ユーザーに見せないよう、固定文言のみを表示する。例外の詳細は呼び出し側でログに出すこと。
///
/// 見た目は失敗トースト（`FailureSnackBar`）と同じ語彙＝アイコン＋文字色のみdanger色で、
/// 背景はベタ塗りしない。空状態（`AppTextStyles.listEmptyMessage`・textSecondary）とは
/// 色とアイコンの有無で区別する。
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, this.message = 'エラーが発生しました'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_rounded, size: 18, color: context.colors.danger),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(message, style: AppTextStyles.errorMessage),
          ),
        ],
      ),
    );
  }
}
