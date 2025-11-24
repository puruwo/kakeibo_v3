/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/component/app_component.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_expense_list_area/bonus_expense_list_area.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_home_footer.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_income_list_area/bonus_income_list_area.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_area.dart';
import 'package:kakeibo/view_model/state/bonus_home_page/selected_tab_controller/selected_tab_controller.dart';

class BonusHomePage extends ConsumerStatefulWidget {
  const BonusHomePage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BonusHomePage();
}

class _BonusHomePage extends ConsumerState<BonusHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    // タブ変更時にフッターの状態を更新（スワイプにも対応）
    _tabController.addListener(() {
      final notifier = ref.read(selectedTabControllerNotifierProvider.notifier);
      if (_tabController.index == 1) {
        notifier.updateState(SelectedTab.bonusIncome);
      } else {
        notifier.updateState(SelectedTab.bonusExpense);
      }
    });

    // initialTabに応じてフッターの状態を初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(selectedTabControllerNotifierProvider.notifier);
      if (widget.initialTab == 1) {
        notifier.updateState(SelectedTab.bonusIncome);
      } else {
        notifier.updateState(SelectedTab.bonusExpense);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: MyColors.secondarySystemBackground,
        // ヘッダー
        appBar: AppBar(
          backgroundColor: MyColors.secondarySystemBackground,
          title: Text(
            'ボーナス利用状況',
            style: MyFonts.pageHeaderText,
          ),
        ),

        // 本体
        body: Stack(
          children: [
            // 上部（ここに通常の内容など追加）
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: BonusPlanArea(),
            ),
            DraggableScrollableSheet(
                // 初期の表示割合
                initialChildSize: 0.7,
                // 最小の表示割合
                minChildSize: 0.7,
                // 最大の表示割合
                maxChildSize: 1.0,
                // ドラッグを離した時に一番近いsnapSizeになるか
                snap: true,
                // snapで止める時の割合
                snapSizes: const [0.7, 1.0],
                builder: (context, scrollController) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ハンドルバー
                      // SingleChildScrollViewの範囲がドラッグできる範囲
                      // スクロールするにはscrollControllerを渡す必要があり、そのウィジェットに囲まれた領域だけがスクロール可能になる
                      SingleChildScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: MyColors.barHandler,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          // 背景色 & 角丸
                          decoration: const BoxDecoration(
                            color: MyColors.quarternarySystemfillOpaque,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                            boxShadow: [
                              // 少し上からの影をつけると見栄えが良い
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // SingleChildScrollViewの範囲がドラッグできる範囲
                              // スクロールするにはscrollControllerを渡す必要があり、そのウィジェットに囲まれた領域だけがスクロール可能になる
                              SingleChildScrollView(
                                controller: scrollController,
                                physics: const ClampingScrollPhysics(),
                                child: Column(
                                  children: [
                                    // タブ
                                    AppTab(
                                      tabController: _tabController,
                                      tabs: const [
                                        Tab(text: 'ボーナス支出'),
                                        Tab(text: 'ボーナス収入'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(height: 1),

                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: const [
                                    // ボーナス支出のエリア
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: BonusExpenseListArea(),
                                    ),

                                    // ボーナス収入のエリア
                                    BonusIncomeListArea(),
                                  ],
                                ),
                              ),

                              const Divider(height: 1),

                              // フッターボタンエリア
                              const Padding(
                                padding:
                                    EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                                child: BonusHomeFooter(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}
