// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/category_palette.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/component/app_selection_sheet.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_color_contoroller/big_category_color_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_color_controller/income_big_category_color_controller.dart';

/// カテゴリーカラー選択シートを表示する（選択即決定・案件 UIデザイン改修 §8）
Future<void> showColorSelectSheet(
  BuildContext context, {
  CategoryType categoryType = CategoryType.expense,
}) {
  return AppSelectionSheet.show(
    context,
    title: 'カテゴリーカラーを選択',
    child: ColorSelectDialog(categoryType: categoryType),
  );
}

/// カラー選択シートの中身（スウォッチの5列グリッド）
class ColorSelectDialog extends ConsumerWidget {
  const ColorSelectDialog({
    super.key,
    this.categoryType = CategoryType.expense,
  });

  final CategoryType categoryType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 選択カラーを取得（カテゴリータイプに応じて切り替え）
    final selectedColor = categoryType == CategoryType.income
        ? ref.watch(incomeBigCategoryColorControllerNotifierProvider)
        : ref.watch(bigCategroyColorControllerNotifierProvider);

    final effectiveList = categoryType == CategoryType.income
        ? CategoryPalette.incomeSwatches
        : CategoryPalette.expenseSwatches;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        // 正方形セルだと縦に間延びするため、セル高を約55ptに詰める
        childAspectRatio: 1.3,
        children: [
          for (final color in effectiveList)
            _ColorCell(
              color: color,
              isSelected: color == selectedColor,
              onTap: () {
                Navigator.of(context).pop();
                if (categoryType == CategoryType.income) {
                  ref
                      .read(incomeBigCategoryColorControllerNotifierProvider
                          .notifier)
                      .updateState(color);
                } else {
                  ref
                      .read(bigCategroyColorControllerNotifierProvider.notifier)
                      .updateState(color);
                }
              },
            ),
        ],
      ),
    );
  }
}

/// スウォッチの1セル。円35px。選択中はtext色の2.5pxリング（旧実装のColors.white直書きをトークン化）
class _ColorCell extends StatelessWidget {
  const _ColorCell({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppInkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: context.colors.text, width: 2.5)
                : null,
          ),
        ),
      ),
    );
  }
}
