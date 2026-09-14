/// Package imports
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/styles/app_motion.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';

/// Local imports
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_list_usecase.dart';
import 'package:kakeibo/view/component/page_loading_indicator.dart';
import 'package:kakeibo/view/year_page/annual_balance_chart/annual_balance_chart.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_area.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_register_prompt_area.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_button_area.dart';
import 'package:kakeibo/view/year_page/yearly_balance_area/yearly_balance_area.dart';
import 'package:kakeibo/domain/ui_value/yearly_balance_value/yearly_balance_value.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_annual_balance_chart_value_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_plan_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_section_display_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_yearly_balance_provider.dart';
import 'package:kakeibo/domain/ui_value/bonus_plan_value/bonus_section_display_type.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/home_date_scope.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';
import 'package:kakeibo/view/component/app_contents_header.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';
import 'package:kakeibo/view/component/app_period_header.dart';
import 'package:kakeibo/view/component/app_year_month_picker.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/selected_datetime/home_selected_datetime.dart';
import 'package:kakeibo/constant/icon.dart';

class YearPage extends ConsumerStatefulWidget {
  const YearPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _YearPageState();
}

class _YearPageState extends ConsumerState<YearPage> {
  /// ピッカーで年変更した直後、provider 側のローディング状態に切り替わるまでの
  /// 数フレームのチラつき（前年コンテンツの一瞬表示）を防ぐためのフラグ
  bool _isYearSwitching = false;

  /// 年度を [months] か月（±12）ずらす。選択日付ごと動かすため、
  /// 代表年の数え方（開始側／終了側）や年度の区切り設定に依存しない（KP-025）
  void _shiftYear(DateTime selectedDate, int months) {
    // 切り替えた瞬間に強制ローディング表示にしてチラつきを防ぐ
    setState(() => _isYearSwitching = true);
    ref
        .read(homeSelectedDatetimeNotifierProvider.notifier)
        .updateState(selectedDate.addMonths(months));
  }

  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    // タブ再タップ（Foundation）など、この画面の外から年度が変わったときもチラつきを防ぐ（KP-025）
    ref.listen<DateTime>(homeSelectedDatetimeNotifierProvider, (previous, next) {
      if (previous != next && !_isYearSwitching) {
        setState(() => _isYearSwitching = true);
      }
    });

    // 全カードの通信が完了するまでフルローディング表示する
    // 年切替時もローディングに戻すため、各providerのisLoadingを判定する
    final dateScopeAsync = ref.watch(homeDateScopeEntityProvider);
    final yearlyBalanceAsync = ref.watch(resolvedYearlyBalanceValueProvider);
    final bonusDisplayAsync = ref.watch(resolvedBonusSectionDisplayProvider);
    final bonusPlanAsync = ref.watch(resolvedBonusPlanValueProvider);
    final annualBalanceAsync = ref.watch(
      resolvedAnnualBalanceChartValueProvider,
    );
    // 固定費セクション（FixedCostButtonArea）と同じ情報源を見る（二重フェッチ防止）
    final fixedCostListAsync = ref.watch(
      fixedCostRegistrationListNotifierProvider,
    );

    // いずれかがloading中ならフルローディング
    // _isYearSwitching は updateState 後 provider 再評価開始までの数フレームを埋める
    final isAnyLoading =
        _isYearSwitching ||
        dateScopeAsync.isLoading ||
        yearlyBalanceAsync.isLoading ||
        bonusDisplayAsync.isLoading ||
        bonusPlanAsync.isLoading ||
        annualBalanceAsync.isLoading ||
        fixedCostListAsync.isLoading;

    // provider 側が loading に切り替わったら、強制フラグを解除する
    // 以降は provider 側の isLoading でローディング表示が引き継がれる
    if (_isYearSwitching && dateScopeAsync.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isYearSwitching = false);
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
            final asyncValue = ref.watch(homeDateScopeEntityProvider);
            final selectedDate = ref.watch(
              homeSelectedDatetimeNotifierProvider,
            );
            // 期間の再読み込み中は前の期間のヘッダーを出したままにし、
            // 新しい期間が届いたらラベルをフェードで切り替える（消えて出直すのを防ぐ。KP-025）
            return asyncValue.when(
              skipLoadingOnReload: true,
              data: (activeDt) {
                final start = activeDt.yearPeriod.startDatetime;
                final end = activeDt.yearPeriod.endDatetime;
                final representativeYear =
                    int.parse(activeDt.representativeYear.year.toString());
                // 矢印の移動範囲は表示中の年度（代表年）で判定する
                final canPrevious =
                    canShiftPeriodYear(year: representativeYear, delta: -1);
                final canNext =
                    canShiftPeriodYear(year: representativeYear, delta: 1);
                return AppPeriodHeader(
                  label:
                      '${start.year}年${start.month}月 - ${end.year}年${end.month}月',
                  subLabel: '$representativeYear年度',
                  subLabelIsNumeric: true,
                  onTapLabel: () async {
                    // 表示中の年度（期間の開始年）で開き・比較する。選択日付の年は
                    // 矢印やタブ再タップで年度の途中の日付になり、表示中の年度とずれることがある
                    final shownYear = start.year;
                    final picked = await showAppYearMonthPicker(
                      context: context,
                      mode: AppYearMonthPickerMode.year,
                      initialDateTime: DateTime(shownYear, 1, 1),
                    );
                    if (picked == null) return;
                    // 同じ年度なら provider 再評価が走らないので、フラグも立てずに早期return
                    if (picked.year == shownYear) return;

                    // ピッカーが閉じた瞬間に強制ローディング表示にしてチラつきを防ぐ
                    setState(() => _isYearSwitching = true);
                    await ref
                        .read(homeSelectedDatetimeNotifierProvider.notifier)
                        .updateStateAsYear(picked.year);
                  },
                  onPrevious:
                      canPrevious ? () => _shiftYear(selectedDate, -12) : null,
                  onNext: canNext ? () => _shiftYear(selectedDate, 12) : null,
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
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
        // （前コンテンツの透過残像で年切替時のチラつきが見えるのを防ぐ）
        reverseDuration: Duration.zero,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: isAnyLoading
            ? const PageLoadingIndicator(key: ValueKey('loading'))
            : SingleChildScrollView(
                key: const ValueKey('content'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // AppBarのぶんだけスペースをあける
                    SizedBox(
                      height:
                          MediaQuery.of(context).padding.top + kToolbarHeight,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.leftsidePadding,
                      ),
                      child: Column(
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final asyncValue = ref.watch(
                                resolvedYearlyBalanceValueProvider,
                              );
                              // 記録が一切ないときはセクションヘッダーを非表示
                              final shouldHide = asyncValue.maybeWhen(
                                data: (value) =>
                                    value.yearlyBalanceType ==
                                    YearlyBalanceType.noRecorod,
                                orElse: () => false,
                              );
                              if (shouldHide) {
                                return const SizedBox.shrink();
                              }
                              return const AppContentsHeader(
                                type: AppContentsHeaderType.appCardSectionTitle,
                                title: '年間収支',
                              );
                            },
                          ),
                          const YearlyBalanceArea(),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ),
                    ),
                    // カルーセルを画面端まで届かせるため、横paddingの外に置く
                    // （ヘッダー・カード列の初期左余白はウィジェット内部で確保する）
                    const FixedCostButtonArea(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.leftsidePadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          Consumer(
                            builder: (context, ref, _) {
                              final displayAsync = ref.watch(
                                resolvedBonusSectionDisplayProvider,
                              );
                              return displayAsync.maybeWhen(
                                data: (type) {
                                  switch (type) {
                                    case BonusSectionDisplayType.normal:
                                      return Column(
                                        children: [
                                          AppContentsHeader(
                                            type: AppContentsHeaderType
                                                .appCardSectionTitle,
                                            title: '特別枠の利用状況',
                                            subLabel: 'さらに表示する',
                                            isLinkable: true,
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BonusHomePage(),
                                                ),
                                              );
                                            },
                                          ),
                                          const BonusPlanArea(),
                                          const SizedBox(height: AppSpacing.lg),
                                        ],
                                      );
                                    case BonusSectionDisplayType.registerPrompt:
                                      return Column(
                                        children: const [
                                          BonusRegisterPromptArea(),
                                          SizedBox(height: AppSpacing.lg),
                                        ],
                                      );
                                    case BonusSectionDisplayType.hidden:
                                      return const SizedBox.shrink();
                                  }
                                },
                                orElse: () => const SizedBox.shrink(),
                              );
                            },
                          ),
                          Consumer(
                            builder: (context, ref, _) {
                              final asyncValue = ref.watch(
                                resolvedAnnualBalanceChartValueProvider,
                              );
                              // データなし時はセクションごと非表示
                              final shouldHide = asyncValue.maybeWhen(
                                data: (value) => value.hasNoRecord,
                                orElse: () => false,
                              );
                              if (shouldHide) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                children: const [
                                  AppContentsHeader(
                                    type: AppContentsHeaderType
                                        .appCardSectionTitle,
                                    title: '生活収支',
                                  ),
                                  AnnualBalanceChart(),
                                ],
                              );
                            },
                          ),
                          // グロナビに最後のカードが隠れないよう正準ヘルパーで余白確保
                          SizedBox(
                            height: context.bottomNavClearance + AppSpacing.xxl,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
