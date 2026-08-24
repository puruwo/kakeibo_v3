import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_usecase.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_detail_provider.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_payment_history_summary.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_empty_state.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/fixed_cost_setting_page/fixed_cost_history_price_label.dart';
import 'package:kakeibo/view/register_page/expense_tab/open_fixed_cost_record_edit_sheet.dart';

/// 固定費の支払い履歴ページ
///
/// 固定費の設定画面の「すべての支払いを見る」からの遷移先（仕様 §6.8）。
/// 先頭にサマリー（合計・回数・平均）、その下に年ごとのインセットグループで全件を並べる。
/// 行タップで固定費行の編集シートを開く。
class FixedCostPaymentHistoryPage extends ConsumerWidget {
  const FixedCostPaymentHistoryPage({super.key, required this.fixedCostId});

  /// 表示対象の固定費マスタID
  final int fixedCostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedCost = ref.watch(fixedCostByIdProvider(fixedCostId)).valueOrNull;
    final historyAsync = ref.watch(fixedCostAllPaymentHistoryProvider(fixedCostId));

    return Scaffold(
      backgroundColor: context.colors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: const GlassAppBarBackground(),
        title: Text('支払い履歴', style: AppTextStyles.pageHeaderText),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.colors.text,
          ),
        ),
      ),
      body: historyAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AppEmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'まだ支払いの記録がありません',
                  description: '支払日が来ると自動で記録され、ここに並びます',
                ),
              ),
            );
          }

          final summary = FixedCostPaymentHistorySummary.fromHistory(history);
          final topPadding =
              MediaQuery.of(context).padding.top + kToolbarHeight;

          // extendBody:true のボトムナビ背後までリストが広がるため、
          // MediaQuery では取得できない下部セーフエリアを View から直接取得し、
          // ボトムナビ高さとあわせて末尾余白に加算する（最後の行が隠れないように）
          final view = View.of(context);
          final bottomSafeArea = view.padding.bottom / view.devicePixelRatio;
          final bottomInset =
              kBottomNavigationBarHeight + bottomSafeArea + AppSpacing.xl;

          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              topPadding + AppSpacing.md,
              AppSpacing.lg,
              bottomInset,
            ),
            children: [
              // 対象の固定費（カテゴリーアイコン＋名称）
              _TitleRow(fixedCost: fixedCost),
              const SizedBox(height: AppSpacing.lg),
              _SummaryCard(summary: summary, fixedCost: fixedCost),
              const SizedBox(height: AppSpacing.xl),
              for (final group in summary.yearGroups) ...[
                _buildYearGroup(context, ref, group),
                const SizedBox(height: AppSpacing.xl),
              ],
            ],
          );
        },
      ),
    );
  }

  /// 年ごとのインセットグループ（見出し右に確定済みの年合計）
  Widget _buildYearGroup(
    BuildContext context,
    WidgetRef ref,
    PaymentHistoryYearGroup group,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
          child: Row(
            children: [
              Text('${group.year}年', style: AppTextStyles.insetGroupHeader),
              const Spacer(),
              Text(
                yenmarkFormattedPriceGetter(group.confirmedTotal),
                style: AppTextStyles.insetGroupHeader,
              ),
            ],
          ),
        ),
        AppInsetGroup(
          children: [
            for (final expense in group.records)
              _HistoryRow(
                expense: expense,
                // 行タップで固定費行の編集シートを開く（未確定行の確定もここから）
                onTap: () => openFixedCostRecordEditSheet(
                  context,
                  ref,
                  expenseId: expense.id,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// 見出し行（カテゴリーアイコン＋固定費名。中央揃え）
///
/// アイコンは固定費の設定画面のカテゴリー行と同じ部品（大カテゴリーの色・図柄）。
class _TitleRow extends ConsumerWidget {
  const _TitleRow({required this.fixedCost});

  final FixedCostEntity? fixedCost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedCost = this.fixedCost;
    // マスタ取得前は高さだけ確保する
    if (fixedCost == null) {
      return Text('', style: AppTextStyles.pageSubjectTitle);
    }

    return FutureBuilder(
      future: ref
          .read(categoryUsecaseProvider)
          .fetchBySmallId(fixedCost.expenseSmallCategoryId),
      builder: (context, snapshot) {
        final category = snapshot.data;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (category != null) ...[
              ExpenseCategoryIcon(
                resourcePath: category.resourcePath,
                colorCode: category.colorCode,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                fixedCost.name,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.pageSubjectTitle,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// サマリーカード（合計・回数・平均）
///
/// 確定型（金額が固定）では平均が自明なので、3列目を初回支払日に差し替える。
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.fixedCost});

  final FixedCostPaymentHistorySummary summary;
  final FixedCostEntity? fixedCost;

  @override
  Widget build(BuildContext context) {
    final isVariable = fixedCost?.variable == 1;
    final cells = <(String, String)>[
      ('支払い合計', yenmarkFormattedPriceGetter(summary.totalPrice)),
      ('支払い回数', '${summary.confirmedCount}回'),
      if (isVariable)
        (
          '平均（確定分）',
          summary.averagePrice == null
              ? '—'
              : yenmarkFormattedPriceGetter(summary.averagePrice!),
        )
      else
        (
          '初回支払日',
          summary.firstPaymentDate == null
              ? '—'
              : _formatYearMonth(summary.firstPaymentDate!),
        ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.fillQuaternary,
        border: Border.all(color: context.colors.surfaceBorder),
        borderRadius: appInsetGroupRadius,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: 0.5,
                  thickness: 0.5,
                  color: context.colors.separator,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      Text(cells[i].$1, style: AppTextStyles.insetGroupNote),
                      const SizedBox(height: 2),
                      Text(
                        cells[i].$2,
                        style: AppTextStyles.insetGroupHistoryPrice.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 支払い履歴の1行（日付／金額／シェブロン）
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.expense, required this.onTap});

  final ExpenseEntity expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = expense.date;

    return AppInkWell(
      borderRadius: BorderRadius.zero,
      onTap: onTap,
      child: SizedBox(
        height: kAppInsetRowHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kAppInsetRowIndent, 0, 12, 0),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  '${int.parse(date.substring(4, 6))}/'
                  '${int.parse(date.substring(6, 8))}',
                  style: AppTextStyles.insetGroupHistoryDate,
                ),
              ),
              const Spacer(),
              FixedCostHistoryPriceLabel(expense: expense),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: kAppInsetRowIconSize,
                color: context.colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// yyyyMMdd → yyyy/M
String _formatYearMonth(String yyyyMMdd) {
  return '${yyyyMMdd.substring(0, 4)}/${int.parse(yyyyMMdd.substring(4, 6))}';
}
