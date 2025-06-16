import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_color_contoroller/big_category_color_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_icon_contoroller/big_category_icon_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_name_contoroller/big_category_name_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_small_category_edit_list%20copy/editting_small_category_edit_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_big_category_appearance_edited/is_big_category_appearance_edited.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_small_category_list_edited/is_small_category_list_edited.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class UpdateCompleteBigCategoryDetailButton extends ConsumerWidget
    with PresentationMixin {
  const UpdateCompleteBigCategoryDetailButton({required this.bigId, super.key});

  final int bigId;

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

          // 実行
          execute(
            context,
            action: () async {
              // 大カテゴリーが編集されているか確認する
              final isBigCategoryListChanged =
                  ref.watch(isBigCategoryAppearanceEditedNotifierProvider);
              // 小カテゴリーが編集されているか確認する
              final isSmallCategoryListChanged =
                  ref.watch(isSmallCategoryListEditedNotifierProvider);
              if (!isSmallCategoryListChanged && !isBigCategoryListChanged) {
                throw const AppException('編集がされていません');
              }

              final editedLsit =
                  ref.watch(edittingSmallCategoryListNotifierProvider);
              for (EditExpenseSmallCategoryValue value in editedLsit) {
                if (value.name.isEmpty) {
                  throw const AppException('名前が入力されていない項目名があります');
                }
              }

              // awaitの前に保存したcontextをスナックバーで利用すると怒られるため、allBigCategoriesWithSmallListProviderの取得をthenで待つようにする

              // 大カテゴリーが編集されている場合は大カテゴリーを更新する
              if (isBigCategoryListChanged) {
                await ref
                    .read(bigCategoriesProvider(bigId).future)
                    .then((initialData) async {
                  final name =
                      ref.watch(bigCategoryNameControllerProvider).text;
                  final colorCode = MyColors().getColorCodeFromColor(
                      ref.watch(bigCategroyColorControllerNotifierProvider));
                  final resourcePath =
                      ref.watch(bigCategroyIconControllerNotifierProvider);
                  final editEntity = ExpenseBigCategoryEntity(
                    id: initialData.id,
                    bigCategoryName: name,
                    colorCode: colorCode,
                    resourcePath: resourcePath,
                    displayOrder: initialData.displayOrder,
                    isDisplayed: initialData.displayOrder,
                  );
                  await categoryUsecase.bigEdit(
                      original: initialData, edit: editEntity);
                });
              }
              // 小カテゴリーが編集されている場合は小カテゴリーを更新する
              if (isSmallCategoryListChanged) {
                await ref
                    .read(allSmallCategoriesListProvider(bigId).future)
                    .then((initialData) async {
                  await categoryUsecase.smallEdit(
                      originalValues: initialData, editValues: editedLsit);
                });
              }
            },

            // actionを実行しエラーがレスポンスされなかった場合の成功時の処理
            succesAction: () async {
              // DBの更新を通知
              // 個別のproviderをinvalidateするのではなく、ほとんど全てのデータを取り直す必要があるためDBの更新を通知する
              ref.read(updateDBCountNotifierProvider.notifier).incrementState();

              // 大カテゴリーのデータを保持するproviderをinvalidateする
              // pop元の画面で表示されている大カテゴリーのデータを更新するため
              ref.invalidate(allBigCategoriesWithSmallListProvider);
              ref.invalidate(allSmallCategoriesListProvider(bigId));

              // 呼び出し元画面でスナックバーを表示
              SuccessSnackBar.show(
                ScaffoldMessenger.of(context),
                message: '登録が完了しました',
              );

              ref.invalidate(isSmallCategoryListEditedNotifierProvider);
              ref.invalidate(isBigCategoryAppearanceEditedNotifierProvider);
              ref.invalidate(edittingSmallCategoryListNotifierProvider);

              Navigator.of(context).pop();
            },
          );
        });
  }
}
