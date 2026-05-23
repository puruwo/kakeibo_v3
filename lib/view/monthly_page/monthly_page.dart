/// Package imports
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/strings.dart';
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
import 'package:kakeibo/view/monthly_page/skeleton/prediction_graph_skeleton.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/component/app_contents_header.dart';
import 'package:kakeibo/view/component/app_year_month_picker.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/selected_datetime/analyze_page_selected_datetime.dart';

class MonthlyPage extends ConsumerStatefulWidget {
  const MonthlyPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MonthlyPage();
}

class _MonthlyPage extends ConsumerState<MonthlyPage> {
  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: const GlassAppBarBackground(),
        title: Consumer(
          builder: (context, ref, _) {
            final monthPeriodAsync = ref.watch(
              analyzePageDateScopeEntityProvider,
            );
            final monthPeriod = monthPeriodAsync.whenOrNull(
              data: (data) => data.aggregationMonthPeriod,
            );
            final selectedDate = ref.watch(
              analyzePageSelectedDatetimeNotifierProvider,
            );
            final label = yyyyMMtoMMGetter(monthPeriod);
            // 月ラベルの下に「一般会計」を小さく表示し、ボーナスを含まない分析画面であることを示す
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final picked = await showAppYearMonthPicker(
                  context: context,
                  mode: AppYearMonthPickerMode.yearMonth,
                  initialDateTime: selectedDate,
                );
                if (picked == null) return;
                ref
                    .read(
                      analyzePageSelectedDatetimeNotifierProvider.notifier,
                    )
                    .updateState(picked);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: AppTextStyles.pageHeaderText),
                  Text(
                    '一般会計',
                    style: AppTextStyles.pageHeaderSubText,
                  ),
                ],
              ),
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
            children: [
              // AppBarのぶんだけスペースをあける
              SizedBox(
                height: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),

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
                            data: (data) =>
                                !data.predictionGraphLineType.shouldShowGraph,
                          ) ??
                          true;
                      if (isNoData) return const SizedBox.shrink();
                      return Column(
                        children: [
                          const AppContentsHeader(
                            type: AppContentsHeaderType.appCardSectionTitle,
                            title: '支出グラフ',
                          ),
                          PredictionGraph(dateScope: scope),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                    loading: () => Column(
                      children: [
                        const AppContentsHeader(
                          type: AppContentsHeaderType.appCardSectionTitle,
                          title: '支出グラフ',
                        ),
                        const PredictionGraphSkeleton(),
                      ],
                    ),
                    error: (error, stack) => const SizedBox.shrink(),
                  );
                },
              ),

              // KAN-113: noData時はグラフを誘導カードに差し替え、ボタンセクションは常時表示
              Consumer(
                builder: (context, ref, _) {
                  final modelAsync =
                      ref.watch(resolvedAllCategoryCardModelProvider);
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: MainButton(
                              buttonType: ButtonColorType.secondary,
                              onPressed: () {
                                final dateScope = ref
                                    .read(analyzePageDateScopeEntityProvider)
                                    .value;
                                if (dateScope == null) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => YearlyIncomeListPage(
                                      period:
                                          dateScope.aggregationMonthPeriod,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: MyColors.themeColor,
                              ),
                              buttonText: '収入を追加',
                            ),
                          ),
                          const SizedBox(width: 8),
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
                              icon: SvgPicture.asset(
                                'assets/images/ui_icon_edit.svg',
                                colorFilter: const ColorFilter.mode(
                                  MyColors.white,
                                  BlendMode.srcIn,
                                ),
                                width: 15,
                                height: 15,
                              ),
                              buttonText: '予算を編集',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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

              const SizedBox(height: 8),

              AppContentsHeader(
                type: AppContentsHeaderType.appCardSectionTitle,
                title: '固定費',
                subLabel: 'さらに表示',
                isLinkable: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MonthlyFixedCostPage(),
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
    );
  }
}
