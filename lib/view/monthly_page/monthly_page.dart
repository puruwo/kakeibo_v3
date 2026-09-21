/// Package imports
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/styles/app_motion.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';

/// Local imports
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/monthly_fixed_cost_page.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_summary_area.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_register_prompt_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_page.dart';
import 'package:kakeibo/view/monthly_page/category_tile/category_sum_tile_list.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_list_page.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';
import 'package:kakeibo/application/prediction_graph/prediction_graph_provider.dart';
import 'package:kakeibo/view/monthly_page/prediction_graph_area/prediction_graph.dart';
import 'package:kakeibo/view/monthly_page/unconfirmed_fixed_cost_banner.dart';
import 'package:kakeibo/view/component/page_loading_indicator.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_category_tile_entity_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/component/app_contents_header.dart';
import 'package:kakeibo/view/component/app_period_header.dart';
import 'package:kakeibo/view/component/app_year_month_picker.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/selected_datetime/analyze_page_selected_datetime.dart';
import 'package:kakeibo/constant/icon.dart';

class MonthlyPage extends ConsumerStatefulWidget {
  const MonthlyPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MonthlyPage();
}

class _MonthlyPage extends ConsumerState<MonthlyPage> {
  /// ピッカーで月変更した直後、provider 側のローディング状態に切り替わるまでの
  /// 数フレームのチラつき（前月コンテンツの一瞬表示）を防ぐためのフラグ
  bool _isMonthSwitching = false;

  /// 月度を切り替える。[target] はその月度に含まれる月末日（ピッカーの戻り値と同じ形）。
  /// [currentStart] は表示中の月度の開始日（月度はこの日を含む月で数える）
  void _changeMonth(DateTime target, DateTime? currentStart) {
    // 同じ月度なら provider 再評価が走らないので、フラグも立てずに早期 return
    if (currentStart != null &&
        target.year == currentStart.year &&
        target.month == currentStart.month) {
      return;
    }

    // 切り替えた瞬間に強制ローディング表示にしてチラつきを防ぐ
    setState(() => _isMonthSwitching = true);
    ref
        .read(analyzePageSelectedDatetimeNotifierProvider.notifier)
        .updateState(target);
  }

  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    // タブ再タップ（Foundation）など、この画面の外から月度が変わったときもチラつきを防ぐ（KP-025）
    ref.listen<DateTime>(analyzePageSelectedDatetimeNotifierProvider, (
      previous,
      next,
    ) {
      if (previous != next && !_isMonthSwitching) {
        setState(() => _isMonthSwitching = true);
      }
    });

    // 全カードの通信が完了するまでフルスケルトン表示する
    // 月切替時もスケルトンに戻すため、各providerのisLoadingを判定する
    final dateScopeAsync = ref.watch(analyzePageDateScopeEntityProvider);
    final scope = dateScopeAsync.valueOrNull;
    // scope依存のfamilyはscopeが解決していなければwatchしない
    final graphAsync = scope != null
        ? ref.watch(predictionGraphDataProvider(scope))
        : null;
    final modelAsync = ref.watch(resolvedAllCategoryCardModelProvider);
    final tileAsync = ref.watch(resolvedAllCategoryTileEntityProvider);
    final fixedCostAsync = ref.watch(resolvedFixedCostSammaryValueProvider);

    // いずれかがloading中ならフルスケルトン
    // _isMonthSwitching は updateState 後 provider 再評価開始までの数フレームを埋める
    final isAnyLoading =
        _isMonthSwitching ||
        dateScopeAsync.isLoading ||
        scope == null ||
        (graphAsync?.isLoading ?? true) ||
        modelAsync.isLoading ||
        tileAsync.isLoading ||
        fixedCostAsync.isLoading;

    // provider 側が loading に切り替わったら、強制フラグを解除する
    // 以降は provider 側の isLoading でローディング表示が引き継がれる
    if (_isMonthSwitching && dateScopeAsync.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isMonthSwitching = false);
      });
    }

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        // 歯車（actions 48）と同じ幅を左にも取り、期間ヘッダーを画面中央に置く（KP-025）
        leading: const SizedBox.shrink(),
        leadingWidth: 48,
        titleSpacing: 0,
        flexibleSpace: const GlassAppBarBackground(),
        title: Consumer(
          builder: (context, ref, _) {
            final monthPeriodAsync = ref.watch(
              analyzePageDateScopeEntityProvider,
            );
            // 期間の再読み込み中は前の期間を出したままにし、新しい期間が届いたら
            // ラベルをフェードで切り替える（空のラベルを挟まない。KP-025）
            final monthPeriod =
                monthPeriodAsync.valueOrNull?.aggregationMonthPeriod;
            final selectedDate = ref.watch(
              analyzePageSelectedDatetimeNotifierProvider,
            );
            final label = yyyyMMtoMMGetter(monthPeriod);
            // 月度は期間の開始日を含む月で数える（ピッカーの月度表示と同じ）。
            // 期間の読み込み中は移動先を決められないため矢印を非活性にする
            final start = monthPeriod?.startDatetime;
            final canPrevious = start != null &&
                canShiftPeriodMonth(
                  year: start.year,
                  month: start.month,
                  delta: -1,
                );
            final canNext = start != null &&
                canShiftPeriodMonth(
                  year: start.year,
                  month: start.month,
                  delta: 1,
                );
            // 月ラベルの下に「生活収支」を小さく表示し、特別枠を含まない分析画面であることを示す
            // （ADR-025: UI上の会計種別ラベルは「生活収支/特別枠」で統一）
            return AppPeriodHeader(
              label: label,
              subLabel: '生活収支',
              onTapLabel: () async {
                final picked = await showAppYearMonthPicker(
                  context: context,
                  mode: AppYearMonthPickerMode.yearMonth,
                  // startDatetimeを渡すことで分析画面が表示中の月度と一致した状態でピッカーを開く
                  initialDateTime: start ?? selectedDate,
                );
                if (picked == null) return;
                _changeMonth(picked, start);
              },
              // 移動先はその月度の月の月末日（ピッカーの戻り値と同じ形）
              onPrevious: canPrevious
                  ? () => _changeMonth(
                        DateTime(start.year, start.month, 0),
                        start,
                      )
                  : null,
              onNext: canNext
                  ? () => _changeMonth(
                        DateTime(start.year, start.month + 2, 0),
                        start,
                      )
                  : null,
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () => {
              // 設定画面にrootのNavigatorで遷移
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const ConfigTop()),
              ),
            },
            icon: const Icon(AppIcons.settings),
          ),
        ],
      ),
      // 地は AppTheme の scaffoldBackgroundColor（surface）。カード地 card-surface と
      // 同色になる surfaceElevated を明示しない（KP-013）
      // ローディング → コンテンツの切り替えをフェードで行う
      body: AnimatedSwitcher(
        // グロナビのタブ切替と同じ時間・曲線で揃える（KP-025）
        duration: AppMotion.switchDuration,
        switchInCurve: AppMotion.switchInCurve,
        // content → loading への切り替えは即時にする
        // （前コンテンツの透過残像で月切替時のチラつきが見えるのを防ぐ）
        reverseDuration: Duration.zero,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: isAnyLoading
            ? const PageLoadingIndicator(key: ValueKey('loading'))
            : SingleChildScrollView(
                key: const ValueKey('content'),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.leftsidePadding,
                  ),
                  child: Column(
                    children: [
                      // AppBarのぶんだけスペースをあける
                      SizedBox(
                        height:
                            MediaQuery.of(context).padding.top + kToolbarHeight,
                      ),

                      // 未確定固定費の注意バナー（対象が無いときは高さ0。KP-028）
                      const UnconfirmedFixedCostBanner(),

                      // 支出グラフ（支出・予算・収入がすべて0のときは非表示）
                      Consumer(
                        builder: (context, ref, _) {
                          final dateScope = ref.watch(
                            analyzePageDateScopeEntityProvider,
                          );
                          return dateScope.when(
                            data: (scope) {
                              final graphData = ref.watch(
                                predictionGraphDataProvider(scope),
                              );
                              final isNoData =
                                  graphData.whenOrNull(
                                    data: (data) => !data
                                        .predictionGraphLineType
                                        .shouldShowGraph,
                                  ) ??
                                  true;
                              if (isNoData) return const SizedBox.shrink();
                              return Column(
                                children: [
                                  const AppContentsHeader(
                                    type: AppContentsHeaderType
                                        .appCardSectionTitle,
                                    title: '支出グラフ',
                                  ),
                                  PredictionGraph(dateScope: scope),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                              );
                            },
                            // ローディングはトップレベル(MonthlyPageFullSkeleton)で吸収する
                            loading: () => const SizedBox.shrink(),
                            error: (error, stack) => const SizedBox.shrink(),
                          );
                        },
                      ),

                      // KAN-113: noData時はグラフを誘導カードに差し替え、ボタンセクションは常時表示
                      Consumer(
                        builder: (context, ref, _) {
                          final modelAsync = ref.watch(
                            resolvedAllCategoryCardModelProvider,
                          );
                          final isNoData =
                              modelAsync.whenOrNull(
                                data: (model) =>
                                    model.cardStatusType ==
                                    AllCategoryCardStatusType.noData,
                              ) ??
                              false;

                          return Column(
                            children: [
                              const AppContentsHeader(
                                type: AppContentsHeaderType.appCardSectionTitle,
                                title: '今月の収支',
                              ),
                              isNoData
                                  ? const MonthlyPlanRegisterPromptArea()
                                  : const MonthlyPlanArea(),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: MainButton(
                                      buttonType: ButtonColorType.secondary,
                                      onPressed: () {
                                        final dateScope = ref
                                            .read(
                                              analyzePageDateScopeEntityProvider,
                                            )
                                            .value;
                                        if (dateScope == null) return;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                YearlyIncomeListPage(
                                                  period: dateScope
                                                      .aggregationMonthPeriod,
                                                  // 単月なので月ヘッダーは開いた状態で見せる（KP-016）
                                                  initiallyExpandAll: true,
                                                ),
                                          ),
                                        );
                                      },
                                      // 遷移先は一覧（追加は一覧側のFAB）なので一覧アイコン
                                      icon: Icon(
                                        AppIcons.list,
                                        size: 18,
                                        color: context.colors.primary,
                                      ),
                                      buttonText: '収入を見る',
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: MainButton(
                                      buttonType: ButtonColorType.main,
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const MonthlyPlanHomePage(),
                                          ),
                                        );
                                      },
                                      // 仕様 §1: mainボタンの文字色がprimaryになったためアイコンも揃える
                                      // KP-023: UI用 SVG を廃止し Material の編集アイコンへ
                                      icon: Icon(
                                        AppIcons.edit,
                                        size: 15,
                                        color: context.colors.primary,
                                      ),
                                      buttonText: '予算を編集',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                            ],
                          );
                        },
                      ),

                      AppContentsHeader(
                        type: AppContentsHeaderType.appCardSectionTitle,
                        title: 'カテゴリー別',
                        subLabel: 'カテゴリー設定',
                        isLinkable: true,
                        onTap: () {
                          showAppModalBottomSheet(
                            context,
                            child: const CategorySettingPage(),
                          );
                        },
                      ),

                      const CategorySumTileList(),

                      const SizedBox(height: AppSpacing.sm),

                      AppContentsHeader(
                        type: AppContentsHeaderType.appCardSectionTitle,
                        title: '固定費',
                        subLabel: 'さらに表示',
                        isLinkable: true,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MonthlyFixedCostPage(),
                            ),
                          );
                        },
                      ),

                      const MonthlyFixedCostSummaryArea(),

                      const SizedBox(height: 128),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
