import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/card_container.dart';

/// 帯付きサマリーカード（収入一覧・支出一覧とそのカテゴリー明細で共用）
///
/// カード上部に淡いティントの帯（合計金額など）を置き、
/// 区切り線の下に [children] を縦に並べる。帯の色はカテゴリーの意味色
/// （収入=income / 支出=expense）を薄く敷く。
class SummaryBandCard extends StatelessWidget {
  const SummaryBandCard({
    super.key,
    required this.tintColor,
    required this.band,
    this.children = const [],
  });

  /// 帯の下地に薄く敷く色（context.colors.income / expense）
  final Color tintColor;

  /// 帯の中身
  final Widget band;

  /// 帯の下に並べる内容
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: tintColor.withValues(alpha: 0.10),
              border: Border(
                bottom: BorderSide(color: context.colors.separator, width: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: band,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// 帯の基本行（ラベル＋大きな金額。右端に補足を置ける）
class SummaryBandRow extends StatelessWidget {
  const SummaryBandRow({
    super.key,
    required this.label,
    required this.priceLabel,
    this.trailing,
  });

  /// 左のラベル（「総収入」「合計」等）
  final String label;

  /// フォーマット済みの金額
  final String priceLabel;

  /// 右端に置く補足（月平均・状態ピル等）
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(label, style: AppTextStyles.appCardTertiaryTitleLabel),
        const SizedBox(width: AppSpacing.sm),
        Text(priceLabel, style: AppTextStyles.summaryHeroPriceLabel),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}
