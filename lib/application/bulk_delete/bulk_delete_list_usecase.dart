import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_list_service.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_mode.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/daily_transaction_group/daily_transaction_group.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 一括削除ページに出す全履歴の一覧（KP-031）
///
/// 種別（支出／収入）ごとに全レコードを取り、日付ごとのグループにして返す。
/// DB 更新（削除の完了を含む）で取り直す。ページを閉じたら破棄する（autoDispose）。
final bulkDeleteListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<
      BulkDeleteListNotifier,
      List<DailyTransactionGroup>,
      BulkDeleteMode
    >(BulkDeleteListNotifier.new);

class BulkDeleteListNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          List<DailyTransactionGroup>,
          BulkDeleteMode
        > {
  @override
  Future<List<DailyTransactionGroup>> build(BulkDeleteMode mode) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    switch (mode) {
      case BulkDeleteMode.expense:
        final expenses = await ref.read(expenseRepositoryProvider).fetchAll();
        // 削除済みカテゴリーの行にも名前を出すため fetchAllActive ではなく fetchAll を使う
        final smalls = await ref
            .read(expenseSmallCategoryRepositoryProvider)
            .fetchAll();
        final bigs = await ref
            .read(expensebigCategoryRepositoryProvider)
            .fetchAll();
        return groupBulkDeleteExpenseTiles(
          buildBulkDeleteExpenseTiles(
            expenses: expenses,
            smallCategories: smalls,
            bigCategories: bigs,
          ),
        );
      case BulkDeleteMode.income:
        final incomes = await ref.read(incomeRepositoryProvider).fetchAll();
        final smalls = await ref
            .read(incomeSmallCategoryRepositoryProvider)
            .fetchAll();
        final bigs = await ref
            .read(incomeBigCategoryRepositoryProvider)
            .fetchAll();
        return groupBulkDeleteIncomeTiles(
          buildBulkDeleteIncomeTiles(
            incomes: incomes,
            smallCategories: smalls,
            bigCategories: bigs,
          ),
        );
    }
  }
}
