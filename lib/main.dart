import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/view/foundation.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: MediaQuery.withClampedTextScaling(
          // テキストサイズの制御
          minScaleFactor: 0.7,
          maxScaleFactor: 0.95,
          child: Foundation(),
        ),
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        // アプリ全体にテキストサイズの制御を適用
        // builder: (context, child) => TextScaleFactor(child: child!),
      ),
    ),
  );
}
