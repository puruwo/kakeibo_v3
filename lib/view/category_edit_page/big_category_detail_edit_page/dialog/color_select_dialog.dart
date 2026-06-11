// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/theme/category_palette.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_color_contoroller/big_category_color_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_color_controller/income_big_category_color_controller.dart';

class ColorSelectDialog extends ConsumerStatefulWidget {
  const ColorSelectDialog({
    super.key,
    this.categoryType = CategoryType.expense,
  });

  final CategoryType categoryType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ColorSelectDialogState();
}

class _ColorSelectDialogState extends ConsumerState<ColorSelectDialog> {
  //選択カラー
  Color selectedColor = Colors.transparent;

  final List<Color> colorList = CategoryPalette.expenseSwatches;

  final List<Color> incomeColorList = CategoryPalette.incomeSwatches;

  @override
  Widget build(BuildContext context) {
    // ====状態管理====

    // 選択カラーを取得（カテゴリータイプに応じて切り替え）
    selectedColor = widget.categoryType == CategoryType.income
        ? ref.watch(incomeBigCategoryColorControllerNotifierProvider)
        : ref.watch(bigCategroyColorControllerNotifierProvider);

    // ==============

    final effectiveList = widget.categoryType == CategoryType.income
        ? incomeColorList
        : colorList;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        alignment: Alignment.center,
        height: widget.categoryType == CategoryType.income ? 100 : 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('カテゴリーカラーを選択'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final color = effectiveList[index];
                return AppInkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    colorSelectFunction(color);
                  },
                  child: colorCircle(color, selectedColor),
                );
              }),
            ),
            if (widget.categoryType != CategoryType.income)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final color = effectiveList[4 + index];
                  return AppInkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      colorSelectFunction(color);
                    },
                    child: colorCircle(color, selectedColor),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  void colorSelectFunction(Color color) {
    setState(() {
      selectedColor = color;
    });
    Navigator.of(context).pop();
    if (widget.categoryType == CategoryType.income) {
      ref
          .read(incomeBigCategoryColorControllerNotifierProvider.notifier)
          .updateState(color);
    } else {
      ref
          .read(bigCategroyColorControllerNotifierProvider.notifier)
          .updateState(color);
    }
  }
}

Widget colorCircle(Color color, Color? selectedColor) {
  final isSelected = (color == selectedColor);

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 35,
      width: 35,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: Colors.white, width: 2.5)
            : null,
      ),
    ),
  );
}
