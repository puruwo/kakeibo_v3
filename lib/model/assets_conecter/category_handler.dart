import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/tableNameKey.dart';
import 'package:kakeibo/constant/colors.dart';


DatabaseHelper db = DatabaseHelper.instance;

class CategoryHandler {
  // 大カテゴリーKeyからアイコンを取得
  Widget sisytIconGetterFromBigCategoryKey(int bigCategoryKey,
      {double? height, double? width}) {
    final futureListMap = db.query('''
    SELECT ${TBL202RecordKey().resourcePath},${TBL202RecordKey().colorCode} FROM ${TBL202RecordKey().tableName} a
    WHERE a.${TBL202RecordKey().id} = $bigCategoryKey
    ''');
    return futureBuilder(futureListMap,width: width,height: height);
  }


  FutureBuilder futureBuilder(Future<List<Map<String, dynamic>>> futureListMap,{double? height, double? width}) {
    return FutureBuilder(
        future: futureListMap,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            String path = snapshot.data![0][TBL202RecordKey().resourcePath];
            String colorCode = snapshot.data![0][TBL202RecordKey().colorCode];
            final color = MyColors().getColorFromHex(colorCode);
            Widget icon = FittedBox(
              fit: BoxFit.scaleDown,
              child: iconWidget(path,color,width: width, height: height));
            return icon;
          } else {
            return SizedBox(width: width, height: height);
          }
        });
  }

  Widget iconWidget(String path,Color color,{double? width,double? height}){
    return SvgPicture.asset(
                path,
                semanticsLabel: 'categoryIcon',
                width: width,
                height: height,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              );
  }




}
