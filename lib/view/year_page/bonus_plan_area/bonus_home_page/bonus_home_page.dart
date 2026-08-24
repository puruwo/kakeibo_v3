/// packegeImport
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/app_component.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_expense_list_area/bonus_expense_list_area.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_home_footer.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_income_list_area/bonus_income_list_area.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_detail_summary.dart';
import 'package:kakeibo/view_model/state/bonus_home_page/selected_tab_controller/selected_tab_controller.dart';

/// 特別枠の利用状況ページ（案件 UIデザイン改修 §4）
///
/// ハーフモーダル風（DraggableScrollableSheet）を廃止した通常のフルページ。
/// 上部にページ用サマリー（BonusPlanDetailSummary）を置き、
/// リストをスクロールするとサマリーが1行のコンパクトバー
/// （BonusPlanCollapsedBar）に折りたたまれる。
class BonusHomePage extends ConsumerStatefulWidget {
  const BonusHomePage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BonusHomePage();
}

class _BonusHomePage extends ConsumerState<BonusHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// サマリーを1行バーへ折りたたんでいるか
  bool _isSummaryCollapsed = false;

  /// 折りたたむスクロール量のしきい値。
  /// 折りたたみ⇄展開が同じ境界で往復してチラつかないようヒステリシスを持たせる
  static const double _collapseThreshold = 32;
  static const double _expandThreshold = 8;

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

  /// タブ内リストのスクロールを監視してサマリーの折りたたみを切り替える
  bool _onScrollNotification(ScrollNotification notification) {
    // TabBarView自身（横方向のPageView）の通知は対象外
    if (notification.metrics.axis != Axis.vertical) return false;

    final pixels = notification.metrics.pixels;
    // バウンス（末尾側のオーバースクロール）中は無視する。
    // 内容が短いリストを引っ張っただけで折りたたみが往復しないように
    if (pixels > notification.metrics.maxScrollExtent) return false;

    if (!_isSummaryCollapsed && pixels > _collapseThreshold) {
      setState(() => _isSummaryCollapsed = true);
    } else if (_isSummaryCollapsed && pixels < _expandThreshold) {
      setState(() => _isSummaryCollapsed = false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: context.colors.surfaceElevated,
        // ヘッダー
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: const GlassAppBarBackground(),
          title: Text('特別枠の利用状況', style: AppTextStyles.pageHeaderText),
        ),

        // 本体
        body: Column(
          children: [
            // サマリー（スクロールで1行バーへ折りたたみ）
            AnimatedSize(
              duration: _kSummaryCollapseDuration,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _isSummaryCollapsed
                  ? const BonusPlanCollapsedBar()
                  : const Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xs,
                      ),
                      child: BonusPlanDetailSummary(),
                    ),
            ),

            // タブ
            AppTab(
              tabController: _tabController,
              tabs: const [
                Tab(text: '特別枠支出'),
                Tab(text: '特別枠収入'),
              ],
            ),
            const Divider(height: 1),

            // リスト
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScrollNotification,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    // ボーナス支出のエリア
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: BonusExpenseListArea(),
                    ),

                    // ボーナス収入のエリア
                    BonusIncomeListArea(),
                  ],
                ),
              ),
            ),

            // フッターボタンエリア（仕様 §1: 区切り線は置かない。
            // グロナビに隠れないようSafeAreaを適用）
            const SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: BonusHomeFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// サマリーの折りたたみアニメーション時間
const Duration _kSummaryCollapseDuration = Duration(milliseconds: 200);
