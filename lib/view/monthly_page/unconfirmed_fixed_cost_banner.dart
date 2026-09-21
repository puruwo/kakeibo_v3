import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/unconfirmed_fixed_cost_prompt/unconfirmed_fixed_cost_prompt_provider.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/unconfirmed_fixed_cost_prompt/unconfirmed_fixed_cost_prompt_sheet.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';

/// 月間分析の先頭に出す、未確定固定費の注意バナー（KP-028）
///
/// 表示中の月度に、支払日から3日経過した未確定の固定費行があるときだけ出す。
/// 対象が無い・読み込み中のときは高さ0（何も出さない）。
class UnconfirmedFixedCostBanner extends ConsumerWidget {
  const UnconfirmedFixedCostBanner({super.key});

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shownPeriod = ref
        .watch(analyzePageDateScopeEntityProvider)
        .valueOrNull
        ?.aggregationMonthPeriod;
    if (shownPeriod == null) return const SizedBox.shrink();

    // 月度ごとのプロバイダーを直接読む。DB更新での再取得中は前の表示を保ち（点滅を防ぐ）、
    // 月度が変わったときは前の月度の対象を持ち越さない
    final targets =
        ref
            .watch(overdueUnconfirmedFixedCostTargetsProvider(shownPeriod))
            .valueOrNull ??
        const [];
    if (targets.isEmpty) return const SizedBox.shrink();

    // 1件のときだけ、どの固定費かを下段に出す
    final single = targets.length == 1 ? targets.first : null;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Semantics(
        button: true,
        child: AppInkWell(
          color: context.colors.danger.withValues(alpha: 0.14),
          border: Border.all(color: context.colors.danger),
          borderRadius: _radius,
          onTap: () {
            showUnconfirmedFixedCostPromptSheet(
              context,
              shownPeriod: shownPeriod,
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              children: [
                Icon(AppIcons.error, size: 20, color: context.colors.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '金額が未入力の固定費が${targets.length}件あります',
                        style: context.textStyles.listTilePrimaryTitle,
                      ),
                      if (single != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${single.name}（${single.date.month}/${single.date.day} 支払い）',
                          style: context.textStyles.listCardSecondaryTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  AppIcons.next,
                  size: 14,
                  color: context.colors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
