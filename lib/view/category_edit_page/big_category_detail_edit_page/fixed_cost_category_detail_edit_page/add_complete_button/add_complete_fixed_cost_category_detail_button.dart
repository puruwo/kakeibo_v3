// packageImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// LocalImport
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_provider.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view/component/success_snackbar.dart';
import 'package:kakeibo/view/presentation_mixin.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_name_controller/fixed_cost_category_name_controller.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_icon_controller/fixed_cost_category_icon_controller.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_color_controller/fixed_cost_category_color_controller.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class AddCompleteFixedCostCategoryDetailButton extends ConsumerWidget
    with PresentationMixin {
  const AddCompleteFixedCostCategoryDetailButton({
    super.key,
    required this.categoryOrder,
  });

  final int categoryOrder;

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

            final iconPath =
                ref.watch(fixedCostCategoryIconControllerNotifierProvider);
            if (iconPath.isEmpty) {
              throw const AppException('カテゴリーのアイコンを選択してください');
            }

            final colorCode =
                ref.watch(fixedCostCategoryColorControllerNotifierProvider);

            final newEntity = FixedCostCategoryEntity(
              categoryName: categoryName,
              resourcePath: iconPath,
              colorCode: MyColors().getHexFromColor(colorCode),
              displayOrder: categoryOrder,
              isDisplayed: 1,
            );

            await usecase.add(entity: newEntity);
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
