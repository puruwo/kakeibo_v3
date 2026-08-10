import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';

/// ADR-018: 一覧取得等でエラーが起きたときの共通表示。
/// `AsyncValue.when` の `error` 分岐で生の例外（`Text('$error')`）をそのまま
/// ユーザーに見せないよう、固定文言のみを表示する。例外の詳細は呼び出し側でログに出すこと。
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, this.message = 'エラーが発生しました'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: AppTextStyles.errorMessage),
    );
  }
}
