import 'package:flutter/material.dart';
import 'package:kakeibo/view_model/state/page_manager/page_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_page_controller.g.dart';

// Notifierを使用したPageControllerの管理
@Riverpod(keepAlive: false)
class CalendarPageControllerNotifier extends _$CalendarPageControllerNotifier {
  @override
  PageController build() {

    // 初回ビルド時だけ全体の管理providerからページを取得（以後は依存しない）
    final currentPage = ref.read(pageManagerNotifierProvider);

    final pageController = PageController(initialPage: currentPage);
    return pageController;
  }

  void previousPage() {
    // Controller:前のページに移動
    state.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic);

    // 全体管理の状態も更新
    ref.read(pageManagerNotifierProvider.notifier).previousPage();
  }  

  void nextPage() {
    // Controller:次のページに移動
    state.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic);

    // 全体管理の状態も更新
    ref.read(pageManagerNotifierProvider.notifier).nextPage();
  }  
}