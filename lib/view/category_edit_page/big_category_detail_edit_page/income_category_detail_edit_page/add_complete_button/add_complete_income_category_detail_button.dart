import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/application/category/income_category_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/ui_value/edit_income_small_category_list_value/edit_income_small_category_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_income_small_category_list/editting_income_small_category_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_color_controller/income_big_category_color_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_icon_controller/income_big_category_icon_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_name_controller/income_big_category_name_controller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_big_category_appearance_edited/is_income_big_category_appearance_edited.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_income_small_category_list_edited/is_income_small_category_list_edited.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class AddCompleteIncomeCategoryDetailButton extends ConsumerWidget
    with PresentationMixin {
  const AddCompleteIncomeCategoryDetailButton({
    required this.categoryOrder,
    super.key,
  });

  final int categoryOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = ref.read(incomeCategoryUsecaseProvider);

    late int addedBigCategoryId;

    return IconButton(
      icon: const Icon(
        Icons.done_rounded,
        color: MyColors.white,
      ),
      onPressed: () async {
        execute(
          context,
          action: () async {
            final name =
                ref.watch(incomeBigCategoryNameControllerProvider).text;
            if (name.isEmpty) {
              throw const AppException('カテゴリー名を入力してください');
            }

            final editedSmallList =
                ref.watch(edittingIncomeSmallCategoryListNotifierProvider);
            if (editedSmallList.isEmpty) {
              throw const AppException('項目を1つ以上入力してください');
            }

            for (EditIncomeSmallCategoryValue value in editedSmallList) {
              if (value.name.isEmpty) {
                throw const AppException('名前が入力されていない項目名があります');
              }
            }

            final color =
                ref.watch(incomeBigCategoryColorControllerNotifierProvider);
            final colorCode = ColorCode.fromColor(color);
            if (color == Colors.transparent) {
              throw const AppException('カテゴリーの色を選択してください');
            }

            final resourcePath =
                ref.watch(incomeBigCategoryIconControllerNotifierProvider);
            if (resourcePath.isEmpty) {
              throw const AppException('カテゴリーのアイコンを選択してください');
            }

            // 大カテゴリー登録（IDはAUTOINCREMENTで採番）
            final entity = IncomeBigCategoryEntity(
              id: 0,
              name: name,
              colorCode: colorCode,
              iconPath: resourcePath,
            );
            final addedBigId = await usecase.addBig(entity);
            addedBigCategoryId = addedBigId;

            // 小カテゴリー登録
            for (EditIncomeSmallCategoryValue value in editedSmallList) {
              final smallEntity = value.toIncomeSmallCategoryEntity(
                bigCategoryKey: addedBigId,
              );
              await usecase.addSmall(smallEntity);
            }
          },
          succesAction: () async {
            ref
                .read(updateDBCountNotifierProvider.notifier)
                .incrementState();

            ref.invalidate(allIncomeBigCategoriesWithSmallListProvider);
            ref.invalidate(
                allIncomeSmallCategoriesListProvider(addedBigCategoryId));

            SuccessSnackBar.show(
              ScaffoldMessenger.of(context),
              message: '登録が完了しました',
            );

            ref.invalidate(isIncomeSmallCategoryListEditedNotifierProvider);
            ref.invalidate(
                isIncomeBigCategoryAppearanceEditedNotifierProvider);

            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
