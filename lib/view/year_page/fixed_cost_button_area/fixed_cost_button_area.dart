import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_contents_header.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/fixed_cost_setting_page/expense_category_select_sheet.dart';
import 'package:kakeibo/view/fixed_cost_setting_page/fixed_cost_setting_page.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_call_to_action_button.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

/// トップ画面の固定費セクション（案件 UIデザイン改修 §5・案4の試行）
///
/// ナビゲーション行＋円形プラスボタンをやめ、
/// 「固定費」見出し＋横スクロールのミニカード列に刷新する。
/// - 並び順は次回支払日が近い順（トップの役割=「次に何が来るか」）
/// - 末尾に破線枠の追加カード
/// - 見出し右の「一覧（N件）」リンクを常設（横スクロールの見落とし補完）
/// - 0件時は従来どおり登録誘導カード（AppEmptyState）
class FixedCostButtonArea extends ConsumerWidget {
  const FixedCostButtonArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(fixedCostRegistrationListNotifierProvider);

    return listAsync.when(
      loading: () => const SizedBox.shrink(),
      // エラー時に追加導線ごと無言で消さない（一覧ページと同じエラー表示）
      error: (_, __) => const AppErrorState(),
      data: (value) {
        // カテゴリーグループをフラット化し、カード表示に必要な情報を集める
        final cards = <_FixedCostCardValue>[
          for (final group in value.categoryGroups)
            for (final item in group.items)
              _FixedCostCardValue(
                entity: item,
                iconPath: group.categoryIconPath,
                colorCode: group.categoryColorCode,
              ),
        ]..sort(_compareByNextPaymentDate);

        if (cards.isEmpty) {
          return const FixedCostRegistrationCallToActionButton();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppContentsHeader(
              type: AppContentsHeaderType.appCardSectionTitle,
              title: '固定費',
              subLabel: '一覧（${cards.length}件）',
              isLinkable: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: ((context) =>
                        const FixedCostRegistrationListPage()),
                  ),
                );
              },
            ),
            SizedBox(
              height: 90,
              // 固定高カードのため、文字サイズ拡大時のはみ出しを防ぐ
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.2,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cards.length + 1, // 末尾は追加カード
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    if (index == cards.length) {
                      return const _FixedCostAddCard();
                    }
                    return _FixedCostMiniCard(value: cards[index]);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 次回支払日が近い順。次回日が無いものは末尾
  ///
  /// DBは未設定を空文字で保持するため、nullと空文字の両方を「無し」と扱う
  static int _compareByNextPaymentDate(
    _FixedCostCardValue a,
    _FixedCostCardValue b,
  ) {
    final aDate = a.entity.nextPaymentDate ?? '';
    final bDate = b.entity.nextPaymentDate ?? '';
    if (aDate.isEmpty && bDate.isEmpty) return 0;
    if (aDate.isEmpty) return 1;
    if (bDate.isEmpty) return -1;
    return aDate.compareTo(bDate);
  }
}

/// ミニカード1枚分の表示値
class _FixedCostCardValue {
  const _FixedCostCardValue({
    required this.entity,
    required this.iconPath,
    required this.colorCode,
  });

  final FixedCostEntity entity;
  final String iconPath;
  final String colorCode;
}

/// 固定費のミニカード（幅140×高さ88・カード語彙）
class _FixedCostMiniCard extends StatelessWidget {
  const _FixedCostMiniCard({required this.value});

  final _FixedCostCardValue value;

  @override
  Widget build(BuildContext context) {
    final entity = value.entity;

    return SizedBox(
      width: 140,
      child: CardContainer(
        clipBehavior: Clip.antiAlias,
        child: AppInkWell(
          borderRadius: appCardRadius,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    FixedCostSettingPage(fixedCostEntity: entity),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ExpenseCategoryIcon(
                      resourcePath: value.iconPath,
                      colorCode: value.colorCode,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        entity.name,
                        style: AppTextStyles.listCardSecondaryTitle.copyWith(
                          color: context.colors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  _priceLabel(entity),
                  style: AppTextStyles.insetGroupHistoryPrice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _nextPaymentLabel(entity),
                  style: AppTextStyles.budgetFixedCostForecastLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 金額表示。一覧行（FixedCostItemTile）と同じ規則:
  /// 変動費は予想額を「平均 ¥N」、表示額が0のときは種別によらず「---」
  String _priceLabel(FixedCostEntity entity) {
    final displayPrice = entity.variable == 1
        ? entity.estimatedPrice
        : entity.price;
    if (displayPrice == 0) {
      return '---';
    }
    if (entity.variable == 1) {
      return '平均 ${yenmarkFormattedPriceGetter(displayPrice)}';
    }
    return yenmarkFormattedPriceGetter(displayPrice);
  }

  /// 「次回 M/d」。次回支払日が無ければ空文字
  String _nextPaymentLabel(FixedCostEntity entity) {
    final date = entity.nextPaymentDate;
    if (date == null || date.length != 8) return '';
    final month = int.tryParse(date.substring(4, 6));
    final day = int.tryParse(date.substring(6, 8));
    if (month == null || day == null) return '';
    return '次回 $month/$day';
  }
}

/// 末尾の追加カード（破線枠・幅88）
///
/// 旧IconOnlyButton（円形＋。ADR-016 A）はこの改修で廃止し、追加導線は
/// カード列の一部（破線カード）に統合した（案件 UIデザイン改修 §5の決定）。
/// これはIcon-onlyボタンの個別再実装ではなくカードの一種のため、
/// AppIconCircleContainerは経由しない。クローズ時のADRで判断を記録する。
class _FixedCostAddCard extends StatelessWidget {
  const _FixedCostAddCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: AppInkWell(
        borderRadius: appCardRadius,
        onTap: () {
          showAppModalBottomSheet(
            context,
            child: const RegisaterPageBase.addFixedCost(),
          );
        },
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: context.colors.surfaceBorder,
            radius: appCardRadius.topLeft.x,
          ),
          child: Center(
            child: Icon(
              Icons.add_rounded,
              size: 20,
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 追加カード用の破線枠ペインター
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dashLength = 5;
  static const double _gapLength = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
          Radius.circular(radius),
        ),
      );

    // パスに沿って破線を描く
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
