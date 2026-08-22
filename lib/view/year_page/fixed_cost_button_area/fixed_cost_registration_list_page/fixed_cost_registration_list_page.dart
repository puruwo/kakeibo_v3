import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/app_fab_stack.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_call_to_action_button.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_category_cards_area.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

class FixedCostRegistrationListPage extends ConsumerWidget {
  const FixedCostRegistrationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedCostListAsync = ref.watch(
      fixedCostRegistrationListNotifierProvider,
    );
    // 透過AppBarの下に潜らないための上部余白（空状態・リストで共通）
    final topInset =
        MediaQuery.of(context).padding.top + kToolbarHeight + AppSpacing.lg;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('固定費', style: AppTextStyles.pageHeaderText),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: context.colors.text),
            onPressed: () => {
              // 設定画面にrootのNavigatorで遷移
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const ConfigTop()),
              ),
            },
          ),
        ],
      ),
      body: fixedCostListAsync.when(
        data: (fixedCostList) {
          // 0件時は ADR-022 の「次アクションあり」空状態カードで追加導線を出す
          // （FAB はリストがある分岐にしか無いため、ここで導線を切らさない）
          if (fixedCostList.categoryGroups.isEmpty) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                topInset,
                AppSpacing.lg,
                0,
              ),
              child: const FixedCostRegistrationCallToActionButton(),
            );
          }

          return AppFabStack(
            fabLabel: '固定費を追加',
            onFabTap: () {
              showAppModalBottomSheet(
                context,
                child: const RegisaterPageBase.addFixedCost(),
              );
            },
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                topInset,
                AppSpacing.lg,
                fabBottomOf(context) + 46,
              ),
              itemCount: fixedCostList.categoryGroups.length,
              itemBuilder: (context, index) {
                return FixedCostCategoryCardsArea(
                  group: fixedCostList.categoryGroups[index],
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const AppErrorState(),
      ),
    );
  }
}
