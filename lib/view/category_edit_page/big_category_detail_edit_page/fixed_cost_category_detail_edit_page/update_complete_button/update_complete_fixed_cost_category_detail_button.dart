// packageImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// LocalImport
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_usecase.dart';
import 'package:kakeibo/application/fixed_cost_category/fixed_cost_category_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_name_controller/fixed_cost_category_name_controller.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_icon_controller/fixed_cost_category_icon_controller.dart';
import 'package:kakeibo/view_model/state/fixed_cost_category_detail_edit_page/fixed_cost_category_color_controller/fixed_cost_category_color_controller.dart';

class UpdateCompleteFixedCostCategoryDetailButton extends ConsumerWidget {
  const UpdateCompleteFixedCostCategoryDetailButton({
    super.key,
    required this.fixedCostCategoryId,
  });

  final int fixedCostCategoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryName =
        ref.watch(fixedCostCategoryNameControllerNotifierProvider);
    final iconPath =
        ref.watch(fixedCostCategoryIconControllerNotifierProvider);
    final colorCode =
        ref.watch(fixedCostCategoryColorControllerNotifierProvider);

    return TextButton(
      onPressed: () async {
        try {
          final usecase = ref.read(fixedCostCategoryUsecaseProvider);
          final categories =
              await ref.read(allFixedCostCategoriesProvider.future);
          final originalEntity = categories.firstWhere(
            (c) => c.id == fixedCostCategoryId,
          );

          final updatedEntity = originalEntity.copyWith(
            name: categoryName,
            resourcePath: iconPath,
            colorCode: MyColors().getHexFromColor(colorCode),
          );

          await usecase.edit(
            originalEntity: originalEntity,
            editEntity: updatedEntity,
          );

          if (context.mounted) {
            Navigator.of(context).pop();
            ref.invalidate(fixedCostCategoryNameControllerNotifierProvider);
            ref.invalidate(fixedCostCategoryIconControllerNotifierProvider);
            ref.invalidate(fixedCostCategoryColorControllerNotifierProvider);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      },
      child: const Text(
        '完了',
        style: TextStyle(
          color: MyColors.systemGreen,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
