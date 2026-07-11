// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_icon_contoroller/big_category_icon_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/income_big_category_icon_controller/income_big_category_icon_controller.dart';

class IconSelectDialog extends ConsumerStatefulWidget {
  const IconSelectDialog({
    super.key,
    this.categoryType = CategoryType.expense,
  });

  final CategoryType categoryType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IconSelectDialog();
}

class _IconSelectDialog extends ConsumerState<IconSelectDialog> {
  //選択カテゴリーのpath
  String? iconPath;

  final List<String> iconPathList = [
    'assets/images/icon_favo.svg',
    'assets/images/icon_meal.svg',
    'assets/images/icon_clothes.svg',
    'assets/images/icon_commodity.svg',
    'assets/images/icon_medical.svg',
    'assets/images/icon_others.svg',
    'assets/images/icon_transportation.svg',
    'assets/images/icon_star.svg',
    'assets/images/icon_smartphone.svg',
    'assets/images/icon_travel.svg',
  ];

  @override
  Widget build(BuildContext context) {
    // ====状態管理====

    // アイコンのパスを取得
    iconPath = widget.categoryType == CategoryType.income
        ? ref.watch(incomeBigCategoryIconControllerNotifierProvider)
        : ref.watch(bigCategroyIconControllerNotifierProvider);

    // ==============

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        alignment: Alignment.center,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('カテゴリーアイコンを選択'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (upperRowIndex) {
                final index = upperRowIndex;
                final url = iconPathList[index];
                return AppInkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      urlSelectFunction(url);
                    },
                    child: iconWidget(url, iconPath, context.colors.text));
              }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (upperRowIndex) {
                final index = 5 + upperRowIndex;
                final url = iconPathList[index];
                return AppInkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      urlSelectFunction(url);
                    },
                    child: iconWidget(url, iconPath, context.colors.text));
              }),
            ),
          ],
        ),
      ),
    );
  }

  void urlSelectFunction(String url) {
    setState(() {
      iconPath = url;
    });
    Navigator.of(context).pop();
    if (widget.categoryType == CategoryType.income) {
      ref
          .read(incomeBigCategoryIconControllerNotifierProvider.notifier)
          .updateState(url);
    } else {
      ref
          .read(bigCategroyIconControllerNotifierProvider.notifier)
          .updateState(url);
    }
  }
}

Widget iconWidget(String url, String? selectedUrl, Color iconColor) {
  // 選択非選択の判定
  final isSelected = (url == selectedUrl);

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 35,
      width: 35,
      // 選択中はカラー選択ダイアログと同じ白枠リングで示す
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            isSelected ? Border.all(color: iconColor, width: 2.5) : null,
      ),
      child:
          CategoryHandler().iconWidget(url, iconColor, width: 15, height: 15),
    ),
  );
}
