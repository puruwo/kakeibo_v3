import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_page_controller.g.dart';

// Notifierを使用したPageControllerの管理
@Riverpod(keepAlive: true)
class CalendarPageControllerNotifier extends _$CalendarPageControllerNotifier {
  @override
  PageController build() {
    // 最初のデータ
    const initialCenter = 500;
    final pageController = PageController(initialPage: initialCenter);
    return pageController;
  }

  void previousPage() {
    // Controller:前のページに移動
    state.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic);
  }  

  void nextPage() {
    // Controller:次のページに移動
    state.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic);
  }  
}