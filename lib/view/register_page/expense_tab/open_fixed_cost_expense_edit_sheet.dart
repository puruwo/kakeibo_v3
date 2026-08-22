import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

/// 固定費の実績行の編集シートを開く
///
/// 未確定行の確定操作はこのシートに一本化した（旧・金額入力ダイアログは廃止。仕様 §6.6）。
/// タイルは実績行のid（expenseのid）しか持たないため、ここで1件読み直して渡す。
Future<void> openFixedCostExpenseEditSheet(
  BuildContext context,
  WidgetRef ref, {
  required int expenseId,
}) async {
  final entity =
      await ref.read(expenseRepositoryProvider).fetchById(id: expenseId);
  if (entity == null || !context.mounted) return;

  await showAppModalBottomSheet(
    context,
    child: RegisaterPageBase.editFixedCostExpense(expenseEntity: entity),
  );
}
