/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/budget_setting_page/budget_cotegory_area.dart';

import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_footer.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/income_list_area/income_list_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_data_area.dart';
import 'package:kakeibo/view_model/state/monthly_plan_page/footer_state_controller/footer_state_controller.dart';

class MonthlyPlanHomePage extends ConsumerStatefulWidget {
  const MonthlyPlanHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MonthlyPlanHomePage();
}

class _MonthlyPlanHomePage extends ConsumerState<MonthlyPlanHomePage> {
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
            '毎月の予算',
            style: MyFonts.pageHeaderText,
          ),
        ),

        // 本体
        body: Stack(
          children: [
            // 上部（ここに通常の内容など追加）
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: MonthlyPlanDataArea(),
            ),
            DraggableScrollableSheet(
                // 初期の表示割合
                initialChildSize: 0.7,
                // 最小の表示割合
                minChildSize: 0,
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
                          child: DefaultTabController(
                            length: 2,
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
                                      TabBar(
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        indicatorColor: MyColors.themeColor,
                                        unselectedLabelStyle:
                                            MyFonts.unselectedLabelStyle,
                                        labelStyle: MyFonts.selectedLabelStyle,
                                        indicatorWeight: 2,
                                        tabs: const [
                                          Tab(text: '予算'),
                                          Tab(text: '収入'),
                                        ],
                                        onTap: (value) {
                                          final footerState = ref.read(
                                              footerStateControllerNotifierProvider);
                                          switch (value) {
                                            case 0:
                                              // 予算タブが選択された場合
                                              if (footerState ==
                                                  TabState.income) {
                                                ref
                                                    .read(
                                                        footerStateControllerNotifierProvider
                                                            .notifier)
                                                    .updateState(
                                                        TabState.budgetNormal);
                                              }
                                              break;
                                            case 1:
                                              // 収入タブが選択された場合
                                              if (footerState !=
                                                  TabState.income) {
                                                ref
                                                    .read(
                                                        footerStateControllerNotifierProvider
                                                            .notifier)
                                                    .updateState(
                                                        TabState.income);
                                              }
                                              break;
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(height: 1),

                                const Expanded(
                                  child: TabBarView(
                                    children: [
                                      // 予算のエリア
                                      BudgetCategoryArea(),
                                      // 収入のエリア
                                      IncomeListArea(),
                                    ],
                                  ),
                                ),

                                const Divider(height: 1),

                                // フッターボタンエリア
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      16.0, 16.0, 16.0, 16.0),
                                  child: MonthlyPlanHomeFooter(),
                                ),
                              ],
                            ),
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
