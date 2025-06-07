// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_color_contoroller/big_category_color_contoroller.dart';

class ColorSelectPage extends ConsumerStatefulWidget {
  const ColorSelectPage({super.key,});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ColorSelectPageState();
}

class _ColorSelectPageState extends ConsumerState<ColorSelectPage> {
  //選択カラー
  Color selectedColor = MyColors.transparent;

  final List<Color> colorList = [
    MyColors.red,
    MyColors.pink,
    MyColors.blue,
    MyColors.mint,
    MyColors.yellow,
    MyColors.giantsOrange,
    MyColors.uranianBlue,
    MyColors.erin,
    MyColors.maize,
    MyColors.tinberWolf,
  ];

  @override
  Widget build(BuildContext context) {

    // ====状態管理====

    // アイコンのパスを取得
    selectedColor = ref.watch(bigCategroyColorControllerNotifierProvider);

    // ==============

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        alignment:Alignment.center,
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
                final color = colorList[index];
                return GestureDetector(child: colorCircle(color,selectedColor), onTap: () {colorSelectFunction(color);});
              }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (underRowIndex) {
                final index = 5 + underRowIndex;
                final color = colorList[index];
                return GestureDetector(child: colorCircle(color,selectedColor), onTap: () {colorSelectFunction(color);});
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
    final notifier = ref.read(bigCategroyColorControllerNotifierProvider.notifier);
    notifier.updateState(color);
  }
}

Widget colorCircle(Color color, Color? selectedColor) {
  // 選択非選択の判定
  final isSelected = (color == selectedColor);

  return isSelected
      // 選択時
      ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.rectangle,
            ),
          ),
      )
      // 非選択時
      : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
      );
}
