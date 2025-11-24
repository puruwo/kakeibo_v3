/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/budget_setting_page/budget_cotegory_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_footer.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/income_list_area/income_list_area.dart';
import 'package:kakeibo/view_model/state/budget_edit_page/price_controller/price_controller.dart';
import 'package:kakeibo/view_model/state/monthly_plan_page/footer_state_controller/footer_state_controller.dart';

class MonthlyPlanHomePage extends ConsumerStatefulWidget {
  const MonthlyPlanHomePage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MonthlyPlanHomePage();
}

class _MonthlyPlanHomePage extends ConsumerState<MonthlyPlanHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _monthlyPlanKey = GlobalKey();
  double _monthlyPlanHeight = 0;

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
      final notifier = ref.read(footerStateControllerNotifierProvider.notifier);
      if (_tabController.index == 1) {
        notifier.updateState(TabState.income);
      } else {
        notifier.updateState(TabState.budgetNormal);
      }
      // タブ切り替え時に全てのTextControllerをリセット
      ref.invalidate(enteredBudgetPriceControllerProvider);
    });

    // initialTabに応じてフッターの状態を初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(footerStateControllerNotifierProvider.notifier);
      if (widget.initialTab == 1) {
        notifier.updateState(TabState.income);
      } else {
        notifier.updateState(TabState.budgetNormal);
      }

      // MonthlyPlanAreaの高さを取得
      _measureMonthlyPlanHeight();
    });
  }

  void _measureMonthlyPlanHeight() {
    final RenderBox? renderBox =
        _monthlyPlanKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _monthlyPlanHeight = renderBox.size.height;
      });
    }
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
            '毎月の予算',
            style: MyFonts.pageHeaderText,
          ),
        ),

        // 本体
        body: LayoutBuilder(
          builder: (context, constraints) {
            // MonthlyPlanAreaの実際の高さ + パディング
            const topPadding = 16.0;
            final totalTopHeight = _monthlyPlanHeight + topPadding;

            // DraggableScrollableSheetの初期サイズを計算
            // MonthlyPlanAreaのすぐ下から表示（被らないギリギリの位置）
            final initialSize = _monthlyPlanHeight > 0
                ? (constraints.maxHeight - totalTopHeight) /
                    constraints.maxHeight
                : 0.6; // 高さ取得前のデフォルト値

            return Stack(
              children: [
                // 上部（ここに通常の内容など追加）
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: SizedBox(
                    key: _monthlyPlanKey,
                    child: const MonthlyPlanArea(hasButtonArea: false),
                  ),
                ),
                DraggableScrollableSheet(
                    // 初期の表示割合（MonthlyPlanAreaの下から開始）
                    initialChildSize: initialSize,
                    // 最小の表示割合
                    minChildSize: initialSize,
                    // 最大の表示割合
                    maxChildSize: 1.0,
                    // ドラッグを離した時に一番近いsnapSizeになるか
                    snap: true,
                    // snapで止める時の割合
                    snapSizes: [initialSize, 1.0],
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
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 4.0),
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
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24)),
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
                                        TabBar(
                                          controller: _tabController,
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          indicatorColor: MyColors.themeColor,
                                          unselectedLabelStyle:
                                              MyFonts.unselectedLabelStyle,
                                          labelStyle:
                                              MyFonts.selectedLabelStyle,
                                          indicatorWeight: 2,
                                          tabs: const [
                                            Tab(text: '予算'),
                                            Tab(text: '収入'),
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
                        ],
                      );
                    }),
              ],
            );
          },
        ),
      ),
    );
  }
}
