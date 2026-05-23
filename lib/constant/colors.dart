import 'package:flutter/material.dart';

class MyColors {
  static const themeColor = Color.fromARGB(255, 11, 178, 131);
  static const themeThinColor = Color(0xFFD7FFF4);
  static const themeSecondaryColor = Color.fromARGB(255, 63, 200, 161);

  static const transparent = Colors.transparent;

  static const white = Colors.white;
  static const black = Colors.black;

  static const blackmint = Color.fromARGB(255, 11, 178, 131);
  static const lightGray = Color(0xFFF6F6F6);
  static const dimGray = Color(0xFF6A706E);
  static const jet = Color(0xFF3F3D3D);
  static const eerieBlack = Color(0xFF1E1E1E);
  static const richBlack = Color(0xFF051014);

  // カテゴリーカラー（支出用）
  static const expenseRed = Color(0xFFDF2828);
  static const expensePink = Color(0xFFFF7171);
  static const expenseBlue = Color(0xFF4BA6FF);
  static const expenseMint = Color(0xFF3DD8E0);
  static const expenseYellow = Color(0xFFFFC700);
  static const expenseGiantsOrange = Color(0xFFFB5B01);
  static const expensePurple = Color(0xFFBB87FF);
  static const expenseBrown = Color(0xFFAC3E00);

  // カテゴリーカラー（収入用）
  static const incomeEmerald = Color(0xFF21D19F);
  static const incomeGreen = Color(0xFF10B981);
  static const incomeDeepGreen = Color(0xFF059669);
  static const incomeMintGreen = Color(0xFF6EE7B7);

  // カテゴリーカラー（固定費用）
  static const fixedCostGray = Color(0xFF8E8E93);

  // アプリカラー
  static const pink = Color(0xFFFF7171);
  static const mintBlue = Color(0xFF36C5F1);

  static const label = Color(0xffffffff);
  static const secondaryLabel = Color(0x99ebebf5);
  static const tirtiaryLabel = Color(0x4cebebf5);
  static const quarternaryLabel = Color(0x2debebf5);

  // systemFill
  static const systemfill = Color(0x5b787880);
  static const secondarySystemfill = Color(0x51787880);
  static const tirtiarySystemfill = Color(0x3d767680);
  static const quarternarySystemfill = Color(0x39767680);
  static const quarternarySystemfillOpaque = Color(0xFF2c2c30);

  static const systemGray = Color(0xff8E8E93);
  static const systemGray2 = Color(0xff636366);
  static const systemGray3 = Color(0xff48484a);
  static const systemGray4 = Color(0xff3a3a3c);
  static const systemGray5 = Color(0xff2c2c2c);
  static const systemGray6 = Color(0xff1c1c1e);

  static const systemBackground = Color(0xff000000);
  static const secondarySystemBackground = Color(0xff1c1c1e);
  static const tirtiarySystemBackground = Color(0xff2c2c2e);
  static const tertiarySystemBackground = Color(0xff2c2c2e); // typo修正版

  static const linkColor = Color(0xff0a84ff);

  static const separater = Color(0x99545458);

  static const barHandler = Color(0xFFD9D9D9);

  // ホバー用
  static const hoverColor = Color(0x33000000);

  Color getColorFromHex(String colorCode) {
    int intValue = int.parse('FF$colorCode', radix: 16);
    return Color(intValue);
  }

  String getColorCodeFromColor(Color color) {
    return color.red.toRadixString(16).padLeft(2, '0') +
        color.green.toRadixString(16).padLeft(2, '0') +
        color.blue.toRadixString(16).padLeft(2, '0');
  }

  String getHexFromColor(Color color) {
    return color.red.toRadixString(16).padLeft(2, '0').toUpperCase() +
        color.green.toRadixString(16).padLeft(2, '0').toUpperCase() +
        color.blue.toRadixString(16).padLeft(2, '0').toUpperCase();
  }

  // Component colors
  static const buttonPrimary = themeColor;
  static const buttonSecondary = systemfill;
}
