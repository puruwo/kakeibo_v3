import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/editting_big_category_list/editting_big_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/is_big_category_list_edited/is_big_category_list_edited.dart';
import 'package:kakeibo/view_model/state/category_edit_page/edit_mode.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class BigCategorySettingFooter extends ConsumerWidget with PresentationMixin {
  const BigCategorySettingFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (ref.watch(editModeNotifierProvider)) {
      case false:
        return _normalButtons(context, ref);
      case true:
        return _edditingButton(context, ref);
      default:
        return const SizedBox.shrink(); // 他のタブでは何も表示しない
    }
  }

  // 通常状態のボタン
  Widget _normalButtons(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 編集モードの状態を更新
          final notifier = ref.read(editModeNotifierProvider.notifier);
          notifier.updateState();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.buttonPrimary,
        ),
        child: Text(
          '表示・並び替え',
          style: MyFonts.mainButtonText,
        ),
      ),
    );
  }

  // 編集状態のボタン
  Widget _edditingButton(BuildContext context, WidgetRef ref) {
    return Row(
      children: [


        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // 編集モードなら、providerを破棄して状態を非編集モードに変更
              ref.invalidate(isBigCategoryListEditedNotifierProvider);
              ref.invalidate(edittingBigCategoryListNotifierProvider);
              ref.read(editModeNotifierProvider.notifier).updateState();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.buttonSecondary,
            ),
            child: Text(
              '編集をキャンセル',
              style: MyFonts.secondaryButtonText,
            ),
          ),
        ),

        const SizedBox(width: 8.0), // ボタン間のスペース

        Expanded(
          child: ElevatedButton(
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
                    // expenseEntityを扱うusecase
                    final categoryUsecase = ref.read(categoryUsecaseProvider);
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
                    final notifier =
                        ref.read(editModeNotifierProvider.notifier);
                    notifier.updateState();
                  },
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.buttonPrimary,
            ),
            child: Text(
              '編集を完了',
              style: MyFonts.mainButtonText,
            ),
          ),
        ),
      ],
    );
  }
}
