import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/editting_big_category_list/editting_big_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/is_big_category_list_edited/is_big_category_list_edited.dart';
import 'package:kakeibo/view_model/state/category_edit_page/edit_mode.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class SubmitBigCategoryButton extends ConsumerWidget with PresentationMixin {
  const SubmitBigCategoryButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // expenseEntityを扱うusecase
    final categoryUsecase = ref.read(categoryUsecaseProvider);

    return IconButton(
        icon: const Icon(
          //完了チェックマーク
          Icons.done_rounded,
          color: MyColors.white,
        ),
        onPressed: () async {
          // 編集前のbudgetListを取得する
          // awaitの前に保存したcontextをスナックバーで利用すると怒られるため、allBigCategoriesWithSmallListProviderの取得をthenで待つようにする
          await ref
              .read(allBigCategoriesWithSmallListProvider.future)
              .then((initialData) {
            // 実行
            execute(
              context,
              action: () async {
                final editedLsit =
                    ref.watch(edittingBigCategoryListNotifierProvider);

                // カテゴリーが編集されているか確認する
                final isChanged =
                    ref.watch(isBigCategoryListEditedNotifierProvider);
                if (!isChanged) throw const AppException('編集がされていません');

                await categoryUsecase.bigCategoriesEdit(
                    originalValues: initialData, editValues: editedLsit);
              },

              // actionを実行しエラーがレスポンスされなかった場合の成功時の処理
              succesAction: () async {
                // DBの更新を通知
                ref
                    .read(updateDBCountNotifierProvider.notifier)
                    .incrementState();

                // 呼び出し元画面でスナックバーを表示
                SuccessSnackBar.show(
                  ScaffoldMessenger.of(context),
                  message: '登録が完了しました',
                );

                ref.invalidate(isBigCategoryListEditedNotifierProvider);
                ref.invalidate(edittingBigCategoryListNotifierProvider);

                // 編集モードの状態を更新
                final notifier = ref.read(editModeNotifierProvider.notifier);
                notifier.updateState();
              },
            );
          });
        });
  }
}
