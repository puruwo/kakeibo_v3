import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/component/card_container.dart';

/// 月ごとのアコーディオンセクション（案件 UIデザイン改修 §6・追加改修 0828）
///
/// ヘッダー行に月ラベル・件数・月計を表示し、タップで明細を開閉する。
/// 支出カテゴリー明細と収入一覧で共用する。
class MonthAccordionSection extends StatelessWidget {
  const MonthAccordionSection({
    super.key,
    required this.label,
    required this.itemCount,
    required this.totalLabel,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  /// 月見出し（例: 「8月」「2027年1月」）
  final String label;

  /// この月の明細件数
  final int itemCount;

  /// この月の合計の表示文字列（例: 「¥ 40,000」）
  final String totalLabel;

  final bool isExpanded;
  final VoidCallback onToggle;

  /// 展開時に表示する明細タイル
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        children: [
          // 月ヘッダー行（タイルと同じ面の語彙で、タップで開閉）
          AppInkWell(
            borderRadius: appCardRadius,
            color: context.colors.fillQuaternary,
            border: Border.all(color: context.colors.surfaceBorder, width: 1),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Text(label, style: AppTextStyles.listTilePrimaryTitle),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '$itemCount件',
                      style: AppTextStyles.listCardSecondaryTitle,
                    ),
                  ),
                  Text(
                    totalLabel,
                    style: AppTextStyles.appCardSecondaryPriceLabel,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 明細タイル（開閉アニメーション付き）
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Column(children: children),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
