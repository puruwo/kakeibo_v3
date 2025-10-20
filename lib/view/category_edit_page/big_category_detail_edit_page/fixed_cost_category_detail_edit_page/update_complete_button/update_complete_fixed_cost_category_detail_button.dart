// packageImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// LocalImport
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_usecase.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_name_controller/fixed_cost_category_name_controller.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_icon_controller/fixed_cost_category_icon_controller.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_color_controller/fixed_cost_category_color_controller.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class UpdateCompleteFixedCostCategoryDetailButton extends ConsumerWidget
    with PresentationMixin {
  const UpdateCompleteFixedCostCategoryDetailButton({
    super.key,
    required this.fixedCostCategoryId,
  });

  final int fixedCostCategoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = ref.read(fixedCostCategoryUsecaseProvider);

    return IconButton(
      icon: const Icon(
        Icons.done_rounded,
        color: MyColors.white,
      ),
      onPressed: () async {
        execute(
          context,
          action: () async {
            final categoryName =
                ref.watch(fixedCostCategoryNameControllerNotifierProvider);
            if (categoryName.isEmpty) {
              throw const AppException('カテゴリー名を入力してください');
            }

            final categories =
                await ref.read(allFixedCostCategoriesProvider.future);
            final originalEntity = categories.firstWhere(
              (c) => c.id == fixedCostCategoryId,
            );

            final iconPath =
                ref.watch(fixedCostCategoryIconControllerNotifierProvider);
            final colorCode =
                ref.watch(fixedCostCategoryColorControllerNotifierProvider);

            // 変更があるかチェック
            if (originalEntity.name == categoryName &&
                originalEntity.resourcePath == iconPath &&
                originalEntity.colorCode == MyColors().getHexFromColor(colorCode)) {
              throw const AppException('編集がされていません');
            }

            final updatedEntity = originalEntity.copyWith(
              name: categoryName,
              resourcePath: iconPath,
              colorCode: MyColors().getHexFromColor(colorCode),
            );

            await usecase.edit(
              originalEntity: originalEntity,
              editEntity: updatedEntity,
            );
          },
          succesAction: () async {
            // DBの更新を通知
            ref.read(updateDBCountNotifierProvider.notifier).incrementState();

            // プロバイダーをinvalidate
            ref.invalidate(allFixedCostCategoriesProvider);

            // 呼び出し元画面でスナックバーを表示
            SuccessSnackBar.show(
              ScaffoldMessenger.of(context),
              message: '登録が完了しました',
            );

            ref.invalidate(fixedCostCategoryNameControllerNotifierProvider);
            ref.invalidate(fixedCostCategoryIconControllerNotifierProvider);
            ref.invalidate(fixedCostCategoryColorControllerNotifierProvider);

            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
