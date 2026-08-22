import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/category_palette.dart';
import 'package:kakeibo/domain/ui_value/edit_income_small_category_list_value/edit_income_small_category_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_income_small_category_list/editting_income_small_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_account_type_controller/income_big_category_account_type_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_color_controller/income_big_category_color_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_icon_controller/income_big_category_icon_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_name_controller/income_big_category_name_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_big_category_appearance_edited/is_income_big_category_appearance_edited.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_small_category_list_edited/is_income_small_category_list_edited.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class UpdateCompleteIncomeCategoryDetailButton extends ConsumerWidget
    with PresentationMixin {
  const UpdateCompleteIncomeCategoryDetailButton({
    required this.bigId,
    super.key,
  });

  final int bigId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = ref.read(incomeCategoryUsecaseProvider);

    return Row(
      children: [
        // 削除ボタン（id=1, id=2 は表示しない）
        if (!IncomeBigCategoryConstants.isDefaultCategory(bigId))
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: context.colors.text,
            ),
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    backgroundColor: context.colors.surfaceElevated,
                    title: Text(
                      'カテゴリーを削除しますか？',
                      style: TextStyle(color: context.colors.text),
                    ),
                    content: Text(
                      'このカテゴリーに紐づく項目および収入レコードがすべて削除されます。',
                      style: TextStyle(color: context.colors.text),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text(
                          '削除',
                          style: TextStyle(color: CategoryPalette.expense1),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (shouldDelete != true) return;

              execute(
                context,
                action: () async {
                  await usecase.deleteBig(bigId);
                },
                succesAction: () async {
                  ref
                      .read(updateDBCountNotifierProvider.notifier)
                      .incrementState();

                  ref.invalidate(allIncomeBigCategoriesWithSmallListProvider);
                  ref.invalidate(allIncomeSmallCategoriesListProvider(bigId));

                  SuccessSnackBar.show(
                    ScaffoldMessenger.of(context),
                    message: '削除が完了しました',
                  );

                  ref.invalidate(
                    isIncomeSmallCategoryListEditedNotifierProvider,
                  );
                  ref.invalidate(
                    isIncomeBigCategoryAppearanceEditedNotifierProvider,
                  );
                  ref.invalidate(
                    edittingIncomeSmallCategoryListNotifierProvider,
                  );

                  Navigator.of(context).pop();
                },
              );
            },
          ),

        // 完了ボタン
        IconButton(
          icon: Icon(Icons.done_rounded, color: context.colors.text),
          onPressed: () async {
            execute(
              context,
              action: () async {
                final isBigChanged = ref.watch(
                  isIncomeBigCategoryAppearanceEditedNotifierProvider,
                );
                final isSmallChanged = ref.watch(
                  isIncomeSmallCategoryListEditedNotifierProvider,
                );
                if (!isBigChanged && !isSmallChanged) {
                  throw const AppException('編集がされていません');
                }

                final editedList = ref.watch(
                  edittingIncomeSmallCategoryListNotifierProvider,
                );
                for (EditIncomeSmallCategoryValue value in editedList) {
                  if (value.name.isEmpty) {
                    throw const AppException('名前が入力されていない項目名があります');
                  }
                }

                // 大カテゴリー編集
                if (isBigChanged) {
                  await ref.read(anIncomeBigCategoryProvider(bigId).future).then((
                    initialData,
                  ) async {
                    final name = ref
                        .watch(incomeBigCategoryNameControllerProvider)
                        .text;
                    final colorCode = ColorCode.fromColor(
                      ref.watch(
                        incomeBigCategoryColorControllerNotifierProvider,
                      ),
                    );
                    final resourcePath = ref.watch(
                      incomeBigCategoryIconControllerNotifierProvider,
                    );

                    // 会計種別（ADR-025）。既定カテゴリーはUIでロックしているため
                    // 元の値を維持し、それ以外はコントローラの選択値を使う
                    final accountType =
                        IncomeBigCategoryConstants.isDefaultCategory(bigId)
                        ? initialData.accountType
                        : ref.watch(
                            incomeBigCategoryAccountTypeControllerNotifierProvider,
                          );

                    final editEntity = IncomeBigCategoryEntity(
                      id: initialData.id,
                      name: name,
                      colorCode: colorCode,
                      iconPath: resourcePath,
                      accountType: accountType,
                    );

                    await usecase.bigEdit(
                      original: initialData,
                      edit: editEntity,
                    );
                  });
                }

                // 小カテゴリー編集
                if (isSmallChanged) {
                  await ref
                      .read(allIncomeSmallCategoriesListProvider(bigId).future)
                      .then((initialData) async {
                        await usecase.smallEdit(
                          originalValues: initialData,
                          editValues: editedList,
                        );
                      });
                }
              },
              succesAction: () async {
                ref
                    .read(updateDBCountNotifierProvider.notifier)
                    .incrementState();

                ref.invalidate(allIncomeBigCategoriesWithSmallListProvider);
                ref.invalidate(allIncomeSmallCategoriesListProvider(bigId));

                SuccessSnackBar.show(
                  ScaffoldMessenger.of(context),
                  message: '登録が完了しました',
                );

                ref.invalidate(isIncomeSmallCategoryListEditedNotifierProvider);
                ref.invalidate(
                  isIncomeBigCategoryAppearanceEditedNotifierProvider,
                );
                ref.invalidate(edittingIncomeSmallCategoryListNotifierProvider);

                Navigator.of(context).pop();
              },
            );
          },
        ),
      ],
    );
  }
}
