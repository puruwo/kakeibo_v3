import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/batch/batch_history_usecase.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/constant/styles/app_motion.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/domain_service/year_period_service/month_period_service.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/logger.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/family_page/family_page.dart';
import 'package:kakeibo/view/historical_calendar_page/expense_history_page.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view/unconfirmed_fixed_cost_prompt/unconfirmed_fixed_cost_prompt_sheet.dart';
import 'package:kakeibo/application/unconfirmed_fixed_cost_prompt/unconfirmed_fixed_cost_prompt_provider.dart';
import 'package:kakeibo/view/monthly_page/monthly_page.dart';
import 'package:kakeibo/view/year_page/year_page.dart';
import 'package:kakeibo/view_model/state/calendar_page/page_controller/calendar_page_controller.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/selected_datetime/analyze_page_selected_datetime.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/home_date_scope.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/selected_datetime/home_selected_datetime.dart';
import 'package:kakeibo/view_model/state/navigation_bar_number.dart';
import 'package:kakeibo/view_model/state/initial_open.dart';
import 'package:kakeibo/constant/icon.dart';

class Foundation extends ConsumerStatefulWidget {
  const Foundation({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FoundationState();
}

class _FoundationState extends ConsumerState<Foundation>
    with SingleTickerProviderStateMixin {
  // 各タブごとの Navigator にアクセスするための GlobalKey
  // index 0:全体 / 1:月間分析 / 2:入力(未使用) / 3:家族 / 4:履歴
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  //navigationBarに設定するbodyのpageリスト
  final List<Widget> pageList = [
    const YearPage(),
    const MonthlyPage(),
    Container(), // 入力タブは入力モーダルを表示するための空のコンテナ
    const FamilyPage(),
    const ExpenseHistoryPage(),
  ];

  // フェードインアニメーション用のコントローラー
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppMotion.switchDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: AppMotion.switchInCurve));
    _fadeController.value = 1.0; // 初期状態では完全に表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onBuildComplete(context, ref);
      _showExpenseEntrySheet(context); // 起動時に入力画面を表示する
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //navigationBarの状態管理
    final navigationBarState = ref.watch(navigationBarNumberNotifierProvider);

    // タブ切り替え時のフェードイン
    // グロナビ操作・生活収支グラフからの遷移など、どの経路でタブが変わっても共通で発火させる
    ref.listen<int>(navigationBarNumberNotifierProvider, (previous, next) {
      if (previous != next) {
        _fadeController.value = 0.0;
        _fadeController.forward();
      }
    });

    return Scaffold(
      extendBody: true,
      // IndexedStack によって、各タブの Navigator を保持
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: ref.watch(navigationBarNumberNotifierProvider),
          children: [
            // index 0: 全体
            Navigator(
              key: navigatorKeys[0],
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(builder: (_) => pageList[0]);
              },
            ),
            // index 1: 月間分析
            Navigator(
              key: navigatorKeys[1],
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(builder: (_) => pageList[1]);
              },
            ),
            // index 2: 入力（入力モーダルを表示するための空のコンテナ）
            Container(),
            // index 3: 家族
            Navigator(
              key: navigatorKeys[3],
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(builder: (_) => pageList[3]);
              },
            ),
            // index 4: 履歴
            Navigator(
              key: navigatorKeys[4],
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(builder: (_) => pageList[4]);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        // グロナビ上端の境界線（foreground で ColoredBox の上に描画）
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: context.colors.separator, width: 0.5),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: ColoredBox(
              color: context.colors.surfaceElevated.withOpacity(0.7),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  // 高さの正本は appBottomNavBarHeight（クリアランス計算と共有）
                  height: appBottomNavBarHeight,
                  child: Row(
                    children: [
                      _buildNavItem(
                        AppIcons.navHome,
                        AppIcons.navHome,
                        '全体',
                        0,
                        navigationBarState,
                      ),
                      _buildNavItem(
                        AppIcons.navAnalysis,
                        AppIcons.navAnalysis,
                        '月間分析',
                        1,
                        navigationBarState,
                      ),
                      _buildAddButton(),
                      _buildNavItem(
                        AppIcons.navCouple,
                        AppIcons.navCouple,
                        '家族',
                        3,
                        navigationBarState,
                      ),
                      _buildNavItem(
                        AppIcons.navCalendar,
                        AppIcons.navCalendar,
                        '履歴',
                        4,
                        navigationBarState,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 通常ナビアイテム（アイコン＋ラベル）
  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
    int currentIndex,
  ) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(index, ref),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? context.colors.text
                  : context.colors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: isSelected
                  ? context.textStyles.bottomNavSelectedLabel
                  : context.textStyles.bottomNavUnselectedLabel,
            ),
          ],
        ),
      ),
    );
  }

  // 中央の入力ボタン（緑 rounded-square）
  Widget _buildAddButton() {
    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(2, ref),
        child: Center(
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              AppIcons.add,
              color: context.colors.onPrimary,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  // タブがタップされたときの処理
  /// 期間ヘッダーを持つタブ（全体・月間分析・履歴）の表示期間を、今日を含む期間に戻す（KP-025）。
  /// すでに現在の期間を表示中なら何もしない（再読み込みを起こさない）
  Future<void> _resetPeriodToCurrent(int index, WidgetRef ref) async {
    final now = ref.read(systemDatetimeNotifierProvider);
    switch (index) {
      case 0:
        final current =
            await ref.read(yearPeriodServiceProvider).fetchYearPeriod(now);
        final shown =
            ref.read(homeDateScopeEntityProvider).valueOrNull?.yearPeriod;
        if (shown?.startDatetime == current.startDatetime) return;
        ref.read(homeSelectedDatetimeNotifierProvider.notifier).updateState(now);
      case 1:
        final current =
            await ref.read(monthPeriodServiceProvider).fetchMonthPeriod(now);
        final shown = ref
            .read(analyzePageDateScopeEntityProvider)
            .valueOrNull
            ?.aggregationMonthPeriod;
        if (shown?.startDatetime == current.startDatetime) return;
        ref
            .read(analyzePageSelectedDatetimeNotifierProvider.notifier)
            .updateState(now);
      case 4:
        ref
            .read(calendarPageControllerNotifierProvider.notifier)
            .jumpToMonth(now);
    }
  }

  void _selectTab(int index, WidgetRef ref) {
    // 2（入力）をタップしたときは、入力モーダルを表示する
    if (index == 2) {
      _showExpenseEntrySheet(ref.context);
    }
    // それ以外のタブがタップされた場合
    else {
      // 同じタブが再タップされた場合は、Navigatorを初期状態までポップしてリセットする
      if (index == ref.read(navigationBarNumberNotifierProvider)) {
        final navigator = navigatorKeys[index].currentState;
        // 下層ページを開いていれば、まずタブ内の Navigator を初期状態までポップしてリセットする
        if (navigator != null && navigator.canPop()) {
          navigator.popUntil((route) => route.isFirst);
        } else {
          // 最初の画面で再タップされたら、表示中の期間を現在の期間に戻す（KP-025 段階的に戻る）
          _resetPeriodToCurrent(index, ref);
        }
      } else {
        // タブを切り替える（フェードインは navigationBarNumber の変化を listen して実行）
        final notifier = ref.read(navigationBarNumberNotifierProvider.notifier);
        notifier.updateState(index);
      }
    }
  }
}

void _onBuildComplete(BuildContext context, WidgetRef ref) async {
  final isInitialOpen = ref.read(initialOpenNotifierProvider);
  if (isInitialOpen == false) return;
  // 月の変わり目にバッチ処理を実行
  // バッチが失敗しても起動は継続させる
  // 失敗した期間は batch_history に記録されないため、次回起動時にリトライされる
  try {
    await ref.read(batchProcessUsecaseProvider).grobalBatchProscessing();
  } catch (e) {
    logger.e('[FAIL]: 起動時のバッチ処理に失敗しました: $e');
  }

  //状態を更新
  final initialOpenNotifier = ref.read(initialOpenNotifierProvider.notifier);
  initialOpenNotifier.updateState();

  // バッチで当月分の固定費行が生成された後に、過去の月度の未確定固定費を促す（KP-028）
  if (!context.mounted) return;
  await _showUnconfirmedFixedCostPromptIfNeeded(context, ref);
}

/// 過去の月度に未確定の固定費行が残っていれば、一覧シートで金額確定を促す
///
/// 起動時に開く記録モーダルの上に重ねる（閉じると記録モーダルがそのまま使える）。
/// 取得に失敗しても起動は継続させる。
Future<void> _showUnconfirmedFixedCostPromptIfNeeded(
  BuildContext context,
  WidgetRef ref,
) async {
  try {
    final targets =
        await ref.read(launchUnconfirmedFixedCostTargetsProvider.future);
    if (targets.isEmpty || !context.mounted) return;
    await showUnconfirmedFixedCostPromptSheet(context);
  } catch (e) {
    logger.e('[FAIL]: 未確定固定費の促しの表示に失敗しました: $e');
  }
}

void _showExpenseEntrySheet(BuildContext context) {
  showAppModalBottomSheet(
    context,
    child: const RegisaterPageBase.addExpense(
      transactionMode: TransactionMode.expense,
    ),
  );
}
