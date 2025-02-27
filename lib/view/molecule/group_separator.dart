import 'package:flutter/material.dart';
import 'package:kakeibo/model/tableNameKey.dart';

//StickyGroupedListViewのGroupSeparateBuilderが引数1(Map)1の形しか対応していないので下記
//ラップせずに実装した

Widget groupSeparator(Map separateLabelMap) {
  //⚪︎⚪︎年⚪︎⚪︎月⚪︎⚪︎日の形で取得
  final dateTime = separateLabelMap[SeparateLabelMapKey().dateTime];
  final label = '${dateTime.year}年${dateTime.month}月${dateTime.day}日';

  return SizedBox(
    height: 50,
    child: Align(
      alignment: Alignment.center,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.blue[300],
          border: Border.all(
            color: Colors.blue[300]!,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
