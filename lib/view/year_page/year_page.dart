/// Package imports
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';

/// Local imports
import 'package:kakeibo/view/year_page/annual_balance_chart/annual_balance_chart.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_home_page/bonus_home_page.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_area.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_register_prompt_area.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_button_area.dart';
import 'package:kakeibo/view/year_page/yearly_balance_area/yearly_balance_area.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/ui_value/yearly_balance_value/yearly_balance_value.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_annual_balance_chart_value_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_section_display_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_yearly_balance_provider.dart';
import 'package:kakeibo/domain/ui_value/bonus_plan_value/bonus_section_display_type.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/home_date_scope.dart';
import 'package:kakeibo/view/component/app_contents_header.dart';
import 'package:kakeibo/view/component/app_year_month_picker.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/selected_datetime/home_selected_datetime.dart';

class YearPage extends ConsumerStatefulWidget {
  const YearPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _YearPageState();
}

class _YearPageState extends ConsumerState<YearPage> {
  @override
  Widget build(BuildContext context) {
    //レイアウト------------------------------------------------------------------------------------

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: const GlassAppBarBackground(),
        title: Consumer(
          builder: (context, ref, _) {
            final asyncValue = ref.watch(homeDateScopeEntityProvider);
            final selectedDate = ref.watch(homeSelectedDatetimeNotifierProvider);
            return asyncValue.when(
              data: (activeDt) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final picked = await showAppYearMonthPicker(
                    context: context,
                    mode: AppYearMonthPickerMode.year,
                    initialDateTime: selectedDate,
                  );
                  if (picked == null) return;
                  await ref
                      .read(homeSelectedDatetimeNotifierProvider.notifier)
                      .updateStateAsYear(picked.year);
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: () {
                    final start = activeDt.yearPeriod.startDatetime;
                    final end = activeDt.yearPeriod.endDatetime;
                    final periodLabel =
                        '${start.year}年${start.month}月〜${end.year}年${end.month}月';
                    final yearLabel =
                        '${activeDt.representativeYear.year}年度';
                    return Column(
                      key: ValueKey('${start.year}${start.month}'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(periodLabel, style: AppTextStyles.pageHeaderText),
                        Text(yearLabel, style: AppTextStyles.pageHeaderSubText),
                      ],
                    );
                  }(),
                ),
              ),
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
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      backgroundColor: MyColors.secondarySystemBackground,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.leftsidePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // AppBarのぶんだけスペースをあける
              SizedBox(
                height: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),

              Consumer(
                builder: (context, ref, _) {
                  final asyncValue =
                      ref.watch(resolvedYearlyBalanceValueProvider);
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
              const SizedBox(height: 8),
              const FixedCostButtonArea(),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) {
                  final displayAsync =
                      ref.watch(resolvedBonusSectionDisplayProvider);
                  return displayAsync.maybeWhen(
                    data: (type) {
                      switch (type) {
                        case BonusSectionDisplayType.normal:
                          return Column(
                            children: [
                              AppContentsHeader(
                                type: AppContentsHeaderType.appCardSectionTitle,
                                title: 'ボーナス利用状況',
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
                              const SizedBox(height: 16),
                            ],
                          );
                        case BonusSectionDisplayType.registerPrompt:
                          return Column(
                            children: const [
                              BonusRegisterPromptArea(),
                              SizedBox(height: 16),
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
                  final asyncValue =
                      ref.watch(resolvedAnnualBalanceChartValueProvider);
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
                        type: AppContentsHeaderType.appCardSectionTitle,
                        title: '生活収支',
                      ),
                      AnnualBalanceChart(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 128),
            ],
          ),
        ),
      ),
    );
  }
}
