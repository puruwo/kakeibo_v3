// packegeImport
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/view_model/provider/small_category_edit_page/selected_color.dart';
import 'package:kakeibo/view_model/provider/small_category_edit_page/selected_icon_path.dart';
import 'package:kakeibo/view_model/provider/torok_state/selected_segment_status.dart';

class IconSelectPage extends ConsumerStatefulWidget {
  const IconSelectPage({super.key, this.categoryIconPath});
  final String? categoryIconPath;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IconSelectPageState();
}

class _IconSelectPageState extends ConsumerState<IconSelectPage> {
  //選択カテゴリーのpath
  String? iconPath;

  final List<String> iconPathList = [
    'assets/images/icon_clothes.svg',
    'assets/images/icon_commodity.svg',
    'assets/images/icon_favo.svg',
    'assets/images/icon_meal.svg',
    'assets/images/icon_medical.svg',
    'assets/images/icon_others.svg',
    'assets/images/icon_transportation.svg',
    'assets/images/icon_star.svg',
    'assets/images/icon_smartphone.svg',
    'assets/images/icon_travel.svg',
    ];

  @override
  void initState() {
    // 初期化が終わる前にbuildが完了してしまうのでawait&SetStateする
    Future(() async {
      await initialize();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.all(8.0),
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

  initialize() {
    iconPath = widget.categoryIconPath;
  }

  void urlSelectFunction(String url) {
    setState(() {
      iconPath = url;
    });
    Navigator.of(context).pop();
    final notifier = ref.read(selectedIconPathNotifierProvider.notifier);
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
