import 'package:flutter/material.dart';
import 'package:kakeibo/view/component/app_exception.dart';
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
    try {
      
      await action();
      
      // 関数が指定されている場合は、成功時に実行し、指定されていない場合は何もしない
      await succesAction?.call();

      await Future.delayed(const Duration(milliseconds: 100));
      
      // 成功メッセージがある場合は、1フレーム遅らせてから SnackBar を表示
      if (successMessage != null) {
        Future.microtask(() {
          final messenger = ScaffoldMessenger.maybeOf(context);
          if (messenger != null) {
            SuccessSnackBar.show(messenger, message: successMessage);
          }
        });
      }
    } on AppException catch (e) {
      // 同様にエラーメッセージも 1フレーム遅らせる
      Future.microtask(() {
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          FailureSnackBar.show(messenger, message: e.toString());
        }
      });
    }
    }
  }

