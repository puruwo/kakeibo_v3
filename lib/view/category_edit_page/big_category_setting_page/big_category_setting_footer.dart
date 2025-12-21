import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_provider.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_usecase.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/editting_big_category_list/editting_big_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/is_big_category_list_edited/is_big_category_list_edited.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_edit_page/editting_fixed_cost_category_list/editting_fixed_cost_category_list.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_edit_page/is_fixed_cost_category_list_edited/is_fixed_cost_category_list_edited.dart';
import 'package:kakeibo/view_model/state/category_edit_page/edit_mode.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class BigCategorySettingFooter extends ConsumerWidget with PresentationMixin {
  const BigCategorySettingFooter({
    super.key,
    required this.categoryType,
  });

  final CategoryType categoryType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (ref.watch(editModeNotifierProvider)) {
      case false:
        return _normalButtons(context, ref);
      case true:
        return _edditingButton(context, ref);
      default:
        return const SizedBox.shrink();
    }
  }

  // 通常状態のボタン
  Widget _normalButtons(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: MainButton(
        buttonType: ButtonColorType.main,
        buttonText: '表示・並び替え',
        onPressed: () {
          // 編集モードの状態を更新
          final notifier = ref.read(editModeNotifierProvider.notifier);
          notifier.updateState();
        },
      ),
    );
  }

  // 編集状態のボタン
  Widget _edditingButton(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: MainButton(
            buttonType: ButtonColorType.secondary,
            buttonText: '編集をキャンセル',
            onPressed: () {
              // 編集モードなら、providerを破棄して状態を非編集モードに変更
              if (categoryType == CategoryType.expense) {
                ref.invalidate(isBigCategoryListEditedNotifierProvider);
                ref.invalidate(edittingBigCategoryListNotifierProvider);
              } else {
                ref.invalidate(isFixedCostCategoryListEditedNotifierProvider);
                ref.invalidate(edittingFixedCostCategoryListNotifierProvider);
              }
              ref.read(editModeNotifierProvider.notifier).updateState();
            },
          ),
        ),

        const SizedBox(width: 8.0), // ボタン間のスペース

        Expanded(
          child: MainButton(
            buttonType: ButtonColorType.main,
            buttonText: '編集を完了',
            onPressed: () async {
              if (categoryType == CategoryType.expense) {
                await _saveExpenseCategoryChanges(context, ref);
              } else {
                await _saveFixedCostCategoryChanges(context, ref);
              }
            },
          ),
        ),
      ],
    );
  }

  // 一般カテゴリーの保存処理
  Future<void> _saveExpenseCategoryChanges(
      BuildContext context, WidgetRef ref) async {
    await ref
        .read(allBigCategoriesWithSmallListProvider.future)
        .then((initialData) {
      execute(
        context,
        action: () async {
          final categoryUsecase = ref.read(categoryUsecaseProvider);
          final editedList = ref.watch(edittingBigCategoryListNotifierProvider);

          final isChanged = ref.watch(isBigCategoryListEditedNotifierProvider);
          if (!isChanged) throw const AppException('編集がされていません');

          await categoryUsecase.bigCategoriesEdit(
              originalValues: initialData, editValues: editedList);
        },
        succesAction: () async {
          ref.read(updateDBCountNotifierProvider.notifier).incrementState();

          SuccessSnackBar.show(
            ScaffoldMessenger.of(context),
            message: '登録が完了しました',
          );

          ref.invalidate(isBigCategoryListEditedNotifierProvider);
          ref.invalidate(edittingBigCategoryListNotifierProvider);

          ref.read(editModeNotifierProvider.notifier).updateState();
        },
      );
    });
  }

  // 固定費カテゴリーの保存処理
  Future<void> _saveFixedCostCategoryChanges(
      BuildContext context, WidgetRef ref) async {
    await ref.read(allFixedCostCategoriesProvider.future).then((initialData) {
      execute(
        context,
        action: () async {
          final usecase = ref.read(fixedCostCategoryUsecaseProvider);
          final editedList =
              ref.watch(edittingFixedCostCategoryListNotifierProvider);

          final isChanged =
              ref.watch(isFixedCostCategoryListEditedNotifierProvider);
          if (!isChanged) throw const AppException('編集がされていません');

          // 編集されたカテゴリーを更新
          for (int i = 0; i < editedList.length; i++) {
            final editedCategory = editedList[i];
            final originalCategory =
                initialData.firstWhere((c) => c.id == editedCategory.id);

            // 表示順または表示状態が変更されている場合のみ更新
            if (originalCategory.displayOrder !=
                    editedCategory.editedStateDisplayOrder ||
                originalCategory.isDisplayed !=
                    (editedCategory.editedStateIsChecked ? 1 : 0)) {
              final updatedEntity = originalCategory.copyWith(
                displayOrder: editedCategory.editedStateDisplayOrder,
                isDisplayed: editedCategory.editedStateIsChecked ? 1 : 0,
              );

              await usecase.edit(
                originalEntity: originalCategory,
                editEntity: updatedEntity,
              );
            }
          }
        },
        succesAction: () async {
          ref.read(updateDBCountNotifierProvider.notifier).incrementState();

          SuccessSnackBar.show(
            ScaffoldMessenger.of(context),
            message: '登録が完了しました',
          );

          ref.invalidate(isFixedCostCategoryListEditedNotifierProvider);
          ref.invalidate(edittingFixedCostCategoryListNotifierProvider);

          ref.read(editModeNotifierProvider.notifier).updateState();
        },
      );
    });
  }
}
