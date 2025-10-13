import 'package:flutter/material.dart';

class MyColors {
  static const themeColor = Color.fromARGB(255, 11, 178, 131);
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

  // カテゴリーカラー
  static const red = Color(0xFFED112B);
  static const pink = Color(0xFFFF7070);
  static const blue = Color(0xFF2596FF);
  static const mintBlue = Color(0xFF36C5F1);
  static const mint = Color(0xFF21D19F);
  static const yellow = Color(0xFFFFC857);
  static const giantsOrange = Color(0xFFFF5714);
  static const uranianBlue = Color(0xFFA3D9FF);
  static const erin = Color(0xFF4DFF50);
  static const maize = Color(0xFFFFE74C);
  static const tinberWolf = Color(0xFFDAD2D8);
  static const indigoDye = Color(0xFF004777);
  static const polynesianBlue = Color(0xFF084887);
  static const purple = Color(0xFFB118C8);
  static const phthaloBlue = Color(0xFF020887);

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

  static const linkColor = Color(0xff0a84ff);

  static const separater = Color(0x99545458);

  static const barHandler = Color(0xFFD9D9D9);

  Color getColorFromHex(String colorCode) {
    int intValue = int.parse('FF$colorCode', radix: 16);
    return Color(intValue);
  }

  String getColorCodeFromColor(Color color) {
    return color.red.toRadixString(16).padLeft(2, '0') +
        color.green.toRadixString(16).padLeft(2, '0') +
        color.blue.toRadixString(16).padLeft(2, '0');
  }


  // Component colors
  static const buttonPrimary = themeColor;
  static const buttonSecondary = systemfill;
}