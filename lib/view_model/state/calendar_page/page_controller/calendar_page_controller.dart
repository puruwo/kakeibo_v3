import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_motion.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/selected_datetime/historical_selected_datetime.dart';
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
    // 時間はグロナビのタブ切替と揃える。横移動なので曲線は減速（easeOutCubic）のまま（KP-025）
    state.previousPage(duration: AppMotion.switchDuration, curve: Curves.easeOutCubic);

    // 全体管理の状態はviewのonPageChangedで更新
    // ref.read(pageManagerNotifierProvider.notifier).previousPage();
  }  

  void nextPage() {
    // Controller:次のページに移動
    state.nextPage(duration: AppMotion.switchDuration, curve: Curves.easeOutCubic);

    // 全体管理の状態はviewのonPageChangedで更新
    // ref.read(pageManagerNotifierProvider.notifier).nextPage();
  }

  /// [target] を含む暦月のページへ移動する（ピッカー・タブ再タップ。KP-025）
  void jumpToMonth(DateTime target) {
    final selected = ref.read(historicalSelectedDatetimeNotifierProvider);
    final diff = (target.year - selected.year) * 12 +
        (target.month - selected.month);
    if (diff == 0) return;

    final currentPage = ref.read(pageManagerNotifierProvider);
    if (state.hasClients) {
      // 月・全体管理の状態は view の onPageChanged で更新
      state.jumpToPage(currentPage + diff);
      return;
    }

    // カレンダーが表示されていないときは状態だけ更新し、次の表示時に反映させる
    ref
        .read(historicalSelectedDatetimeNotifierProvider.notifier)
        .updateState(selected.addMonths(diff));
    ref.read(pageManagerNotifierProvider.notifier).updateState(currentPage + diff);
  }
}