import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';

/// 汎用確認ダイアログ（アクションシート型）を表示する
///
/// 案件 UIデザイン改修 §9: 中央のDialogをやめ、長押しメニュー（showMenuDialog）と
/// 同語彙のiOS ActionSheet風ボトムシートに統一する。
/// タイトル＋メッセージのヘッダーセル → 確認アクション1行 → 別枠のキャンセル。
///
/// [title] - ダイアログのタイトル
/// [message] - ダイアログのメッセージ
/// [confirmLabel] - 確認ボタンのラベル（デフォルト: "OK"）
/// [cancelLabel] - キャンセルボタンのラベル（デフォルト: "キャンセル"）
/// [onConfirm] - 確認ボタンを押したときのコールバック
/// [onCancel] - キャンセルボタンを押したときのコールバック（オプション）
/// [barrierDismissible] - 外側タップ・スワイプで閉じるか（デフォルト: false）
/// [isDestructive] - ADR-018: 削除等の不可逆操作の確認ならtrue。確認アクションがdanger色になる
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = "OK",
  String cancelLabel = "キャンセル",
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = false,
  bool isDestructive = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true, // グローバルナビゲーションにも被せる
    isDismissible: barrierDismissible,
    enableDrag: barrierDismissible,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー（タイトル+メッセージ）と確認アクションの枠
            ActionSheetBlock(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.dialogLabelEmphasis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message,
                          style: AppTextStyles.dialogLabel
                              .copyWith(color: context.colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.colors.separator,
                  ),
                  // 確認アクション
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      onTap: () => Navigator.of(context).pop(true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            confirmLabel,
                            style: AppTextStyles.dialogList.copyWith(
                              color: isDestructive
                                  ? context.colors.danger
                                  : context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // キャンセル（固定・別枠）
            ActionSheetCancelButton(
              label: cancelLabel,
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    },
  );

  if (result == true) {
    onConfirm?.call();
    return true;
  }
  // 明示的なキャンセル時のみコールバックを呼ぶ（スワイプ等で閉じた場合はfalseのみ）
  if (result == false) {
    onCancel?.call();
  }
  return false;
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
    confirmLabel: "削除する",
    cancelLabel: "キャンセル",
    onConfirm: onConfirm,
    isDestructive: true,
  );
}

/// 固定費マスタの削除確認ダイアログを表示する
///
/// マスタを削除すると未払い分の支払いも連動削除されるため、
/// 汎用の削除ダイアログとは別文言で、何が残り何が消えるかを明示する（→ ADR-007）。
///
/// [onConfirm] - 確認ボタンを押したときのコールバック
Future<bool> showFixedCostDeleteConfirmationDialog(
  BuildContext context, {
  VoidCallback? onConfirm,
}) async {
  return await showConfirmationDialog(
    context,
    title: "固定費を削除",
    message: "支払日が過ぎた記録は残りますが、\n未確定分と今後の予定は削除されます。\n本当に削除しますか？",
    confirmLabel: "削除する",
    cancelLabel: "キャンセル",
    onConfirm: onConfirm,
    isDestructive: true,
  );
}
