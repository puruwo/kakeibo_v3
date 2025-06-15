// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_icon_contoroller/big_category_icon_contoroller.dart';

class IconSelectDialog extends ConsumerStatefulWidget {
  const IconSelectDialog({super.key,});

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
    iconPath = ref.watch(bigCategroyIconControllerNotifierProvider);

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
              child: Text('カテゴリーカラーを選択'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (upperRowIndex) {
                final index = upperRowIndex;
                final url = iconPathList[index];
                return GestureDetector(
                    child: iconWidget(url, iconPath),
                    onTap: () {
                      urlSelectFunction(url);
                    });
              }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (upperRowIndex) {
                final index = 5 + upperRowIndex;
                final url = iconPathList[index];
                return GestureDetector(
                    child: iconWidget(url, iconPath),
                    onTap: () {
                      urlSelectFunction(url);
                    });
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
    final notifier = ref.read(bigCategroyIconControllerNotifierProvider.notifier);
    notifier.updateState(url);
  }
}

Widget iconWidget(String url, String? selectedUrl) {
  // 選択非選択の判定
  final isSelected = (url == selectedUrl);

  return isSelected
      // 選択時
      ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 35,
            width: 35,
            child: CategoryHandler()
                .iconWidget(url, MyColors.white, width: 15, height: 15),
          ),
        )
      // 非選択時
      : Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 35,
            width: 35,
            child: CategoryHandler()
                .iconWidget(url, MyColors.white, width: 15, height: 15),
          ),
        );
}
