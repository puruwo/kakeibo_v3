import 'package:flutter/material.dart';
import 'package:kakeibo/domain/app_exception.dart';
import 'package:kakeibo/view/component/failure_snackbar.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';

/// プレゼンテーション層用のエラーハンドリングをラップした共通処理 Mixin
mixin PresentationMixin {
  Future<void> execute(
    BuildContext context, {
    required Future<void> Function() action,
    Future<void> Function()? succesAction,
    String? successMessage,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      
      await action();
      
      // 関数が指定されている場合は、成功時に実行し、指定されていない場合は何もしない
      await succesAction?.call();

      await Future.delayed(const Duration(milliseconds: 100));
      
      // SuccessMessageが指定されている場合は、スナックバーを表示
      if(successMessage == null)return;
      SuccessSnackBar.show(
        scaffoldMessenger,
        message: successMessage,
      );

    } on AppException catch (e) {
      
      FailureSnackBar.show(
        scaffoldMessenger,
        message: e.toString(),

      );
    }
  }
}
