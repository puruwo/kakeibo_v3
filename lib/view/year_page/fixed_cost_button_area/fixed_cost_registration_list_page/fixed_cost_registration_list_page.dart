import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_list_usecase.dart';
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_summary.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_summary_cells.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/app_fab_stack.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_call_to_action_button.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/expense_big_category_cards_area.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/constant/icon.dart';

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
          icon: Icon(AppIcons.back, color: context.colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // 月次固定費ページ（「◯月の固定費」）と見分けられるよう、登録内容の一覧だと名前で示す
        title: Text('登録中の固定費', style: context.textStyles.pageHeaderText),
        actions: [
          IconButton(
            icon: Icon(AppIcons.settings, color: context.colors.text),
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
              // 先頭（index 0）はサマリーカード、以降がカテゴリーごとのグループ
              itemCount: fixedCostList.categoryGroups.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _RegistrationSummaryCard(
                    summary: FixedCostRegistrationSummary.fromFixedCosts([
                      for (final group in fixedCostList.categoryGroups)
                        ...group.items,
                    ]),
                  );
                }
                return ExpenseBigCategoryCardsArea(
                  group: fixedCostList.categoryGroups[index - 1],
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

/// サマリーカードの情報アイコンで出すツールチップの文言
const registrationSummaryTooltipMessage =
    '画面に記載される月あたり・年あたりの支払い合計額は、変動固定費の支払い予想額を含めて計算されます';

/// 登録中の固定費のサマリーカード（件数・月あたり・年あたり）
///
/// 何の一覧かを説明文ではなく数字で伝える（案件 KP-030・L-B案）。
class _RegistrationSummaryCard extends StatelessWidget {
  const _RegistrationSummaryCard({required this.summary});

  final FixedCostRegistrationSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: CardContainer(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: AppSummaryCells(
          cells: [
            AppSummaryCell(label: '登録中', value: '${summary.count}件'),
            AppSummaryCell(
              label: '月あたり',
              value: yenmarkFormattedPriceGetter(summary.monthlyPrice),
              labelTrailing: _infoIcon(context),
            ),
            AppSummaryCell(
              label: '年あたり',
              value: yenmarkFormattedPriceGetter(summary.yearlyPrice),
              labelTrailing: _infoIcon(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 月あたり・年あたりのラベルに添える情報アイコン。
  /// 変動する固定費は金額が決まっていないため、予想額まじりの合計であることを
  /// ツールチップ（タップで表示）で伝える。変動を含まないときは出さない
  Widget? _infoIcon(BuildContext context) {
    if (!summary.hasVariable) return null;
    return Tooltip(
      message: registrationSummaryTooltipMessage,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 6),
      preferBelow: true,
      // 説明の対象である金額を隠さないよう、吹き出しはカードの下へ出す
      // （アイコンはラベル行にあるため、値の行とカード余白ぶん下げる）
      verticalOffset: 56,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      textStyle: context.textStyles.insetGroupNote.copyWith(
        color: context.colors.surface,
      ),
      decoration: BoxDecoration(
        color: context.colors.text,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        AppIcons.info,
        size: 14,
        color: context.colors.textTertiary,
        semanticLabel: '金額の計算方法',
      ),
    );
  }
}
