import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/component/button_util.dart';

/// 汎用確認ダイアログを表示する
///
/// [title] - ダイアログのタイトル
/// [message] - ダイアログのメッセージ
/// [confirmLabel] - 確認ボタンのラベル（デフォルト: "OK"）
/// [cancelLabel] - キャンセルボタンのラベル（デフォルト: "キャンセル"）
/// [onConfirm] - 確認ボタンを押したときのコールバック
/// [onCancel] - キャンセルボタンを押したときのコールバック（オプション）
/// [barrierDismissible] - 外側タップで閉じるか（デフォルト: false）
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = "OK",
  String cancelLabel = "キャンセル",
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = false,
}) async {
  return await showDialog(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: MyColors.systemGray5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // タイトル
                  Text(
                    title,
                    style: MyFonts.dialogTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // メッセージ
                  Text(
                    message,
                    style: MyFonts.dialogLabel,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // ボタンエリア
                  Row(
                    children: [
                      // キャンセルボタン
                      Expanded(
                        child: SubButton(
                          buttonType: ButtonColorType.secondary,
                          buttonText: "キャンセル",
                          onPressed: () {
                            onCancel?.call();
                            Navigator.of(context).pop(false);
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 確認ボタン
                      Expanded(
                        child: SubButton(
                          buttonType: ButtonColorType.main,
                          buttonText: "OK",
                          onPressed: () {
                            onConfirm?.call();
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ) ??
      false;
}

/// ダイアログ内のボタン
class _DialogButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _DialogButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? MyColors.themeColor : MyColors.systemGray4,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: MyFonts.mainButtonText.copyWith(
                color: isPrimary ? MyColors.white : MyColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 削除確認ダイアログを表示する（showConfirmationDialogのラッパー）
///
/// [onConfirm] - 確認ボタンを押したときのコールバック
Future<bool> showDeleteConfirmationDialog(
  BuildContext context, {
  VoidCallback? onConfirm,
}) async {
  return await showConfirmationDialog(
    context,
    title: "登録履歴の削除",
    message: "削除したデータは戻せません。\n本当に削除しますか？",
    confirmLabel: "OK",
    cancelLabel: "キャンセル",
    onConfirm: onConfirm,
  );
}
