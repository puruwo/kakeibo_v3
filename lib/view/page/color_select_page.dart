// packegeImport
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/provider/small_category_edit_page/selected_color.dart';

class ColorSelectPage extends ConsumerStatefulWidget {
  const ColorSelectPage({super.key, this.categoryColor});
  final Color? categoryColor;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ColorSelectPageState();
}

class _ColorSelectPageState extends ConsumerState<ColorSelectPage> {
  //選択カラー
  Color? selectedColor;

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

  initialize() {
    selectedColor = widget.categoryColor;
  }
  
  void colorSelectFunction(Color color) {
    setState(() {
      selectedColor = color;
    });
    Navigator.of(context).pop();
    final notifier = ref.read(selectedColorNotifierProvider.notifier);
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
