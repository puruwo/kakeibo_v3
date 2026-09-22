import 'package:flutter/material.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_mode.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/view/bulk_delete_page/bulk_delete_page.dart';

/// 一括削除ページを root Navigator で開く（KP-031）
///
/// 導線が5タブとモーダルに散らばるため、タブの Navigator に依存させず
/// 設定画面と同じく root に push する（仕様 §3）。
void openBulkDeletePage(
  BuildContext context, {
  required BulkDeleteMode mode,
  required int initialSelectedId,
}) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) =>
          BulkDeletePage(mode: mode, initialSelectedId: initialSelectedId),
    ),
  );
}

/// 長押しメニューの「まとめて削除」項目（仕様 §2）
///
/// 並びは 編集／まとめて削除／削除（カンバス A2）。この項目は画面を開くだけで
/// 破壊的ではないため通常色（primary）にし、アイコンは [AppIcons.bulkSelect]。
MenuDialogItem bulkDeleteMenuItem(
  BuildContext context, {
  required BulkDeleteMode mode,
  required int recordId,
}) {
  return MenuDialogItem(
    label: 'まとめて削除',
    icon: AppIcons.bulkSelect,
    onPressed: () =>
        openBulkDeletePage(context, mode: mode, initialSelectedId: recordId),
  );
}
