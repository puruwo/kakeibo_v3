import 'package:flutter/material.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';

/// カテゴリー削除の確認（KP-024）
///
/// 削除は取り消せないため破壊的操作として出す。[message] には何が残り何が消えるかを書く。
Future<bool> showCategoryDeleteConfirmationDialog(
  BuildContext context, {
  required String categoryName,
  required String message,
}) {
  return showConfirmationDialog(
    context,
    title: '「$categoryName」を削除しますか？',
    message: message,
    confirmLabel: '削除する',
    isDestructive: true,
  );
}

/// 固定費が使っているカテゴリーを削除しようとしたときの案内（KP-024）
///
/// 削除は行わない。「固定費を見る」で固定費の一覧を開き、
/// 固定費のカテゴリーを変えてから削除してもらう。
Future<void> showCategoryInUseByFixedCostDialog(
  BuildContext context, {
  required String categoryName,
  required List<String> fixedCostNames,
}) async {
  final shouldOpenFixedCosts = await showConfirmationDialog(
    context,
    title: '「$categoryName」は削除できません',
    message:
        '固定費「${fixedCostNames.join("」「")}」がこのカテゴリーを使っています。\n固定費のカテゴリーを変更してから\n削除してください。',
    confirmLabel: '固定費を見る',
    cancelLabel: '閉じる',
    barrierDismissible: true,
  );

  if (!shouldOpenFixedCosts || !context.mounted) {
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const FixedCostRegistrationListPage(),
    ),
  );
}
