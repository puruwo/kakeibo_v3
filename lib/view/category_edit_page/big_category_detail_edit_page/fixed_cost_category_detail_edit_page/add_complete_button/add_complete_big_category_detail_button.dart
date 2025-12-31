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

class AddCompleteBigCategoryDetailButton extends ConsumerWidget
    with PresentationMixin {
  const AddCompleteBigCategoryDetailButton(
      {required this.categoryOrder, super.key});

  /// カテゴリーの表示順
  final int categoryOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // expenseEntityを扱うusecase
    final categoryUsecase = ref.read(categoryUsecaseProvider);

    late int addedBigCategoryId;

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
              final name = ref.watch(bigCategoryNameControllerProvider).text;
              if (name.isEmpty) {
                throw const AppException('カテゴリー名を入力してください');
              }

              final editedSmallLsit =
                  ref.watch(edittingSmallCategoryListNotifierProvider);
              if (editedSmallLsit.isEmpty) {
                throw const AppException('項目を1つ以上入力してください');
              }

              for (EditExpenseSmallCategoryValue value in editedSmallLsit) {
                if (value.name.isEmpty) {
                  throw const AppException('名前が入力されていない項目名があります');
                }
              }

              final color =
                  ref.watch(bigCategroyColorControllerNotifierProvider);
              final colorCode = MyColors().getColorCodeFromColor(color);
              if (color == Colors.transparent) {
                throw const AppException('カテゴリーの色を選択してください');
              }

              final resourcePath =
                  ref.watch(bigCategroyIconControllerNotifierProvider);
              if (resourcePath.isEmpty) {
                throw const AppException('カテゴリーのアイコンを選択してください');
              }

              // awaitの前に保存したcontextをスナックバーで利用すると怒られるため、allBigCategoriesWithSmallListProviderの取得をthenで待つようにする

              // 大カテゴリーを登録する
              final entity = ExpenseBigCategoryEntity(
                id: 0, // 新規追加のためIDは0
                bigCategoryName: name,
                colorCode: colorCode,
                resourcePath: resourcePath,
                displayOrder: categoryOrder,
                isDisplayed: 1, // デフォルトで表示する
              );
              final addedBigId = await categoryUsecase.addBig(entity);
              addedBigCategoryId = addedBigId;

              // 小カテゴリーを登録する
              for (EditExpenseSmallCategoryValue value in editedSmallLsit) {
                final smallEntity = value.toExpenseSmallCategoryEntity(
                  bigCategoryKey: addedBigId,
                );
                await categoryUsecase.addSmall(smallEntity);
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
              ref.invalidate(
                  allSmallCategoriesListProvider(addedBigCategoryId));

              // 呼び出し元画面でスナックバーを表示
              SuccessSnackBar.show(
                ScaffoldMessenger.of(context),
                message: '登録が完了しました',
              );

              ref.invalidate(isSmallCategoryListEditedNotifierProvider);
              ref.invalidate(isBigCategoryAppearanceEditedNotifierProvider);

              Navigator.of(context).pop();
            },
          );
        });
  }
}
