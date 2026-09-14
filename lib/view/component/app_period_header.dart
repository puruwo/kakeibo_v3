import 'package:flutter/material.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_motion.dart';
import 'package:kakeibo/view/component/button_util.dart';

/// 期間ヘッダーの矢印で移動できる最小の年（ピッカーの既定 minYear と同じ）
const int kAppPeriodMinYear = 2000;

/// 期間ヘッダーの矢印で移動できる最大の年（ピッカーの既定 maxYear と同じ今年＋10年）
int appPeriodMaxYear() => DateTime.now().year + 10;

/// 年月（月度・暦月）を [delta] か月動かした先が移動範囲内か
bool canShiftPeriodMonth({
  required int year,
  required int month,
  required int delta,
  int? maxYear,
}) {
  final target = DateTime(year, month + delta);
  return target.year >= kAppPeriodMinYear &&
      target.year <= (maxYear ?? appPeriodMaxYear());
}

/// 年度を [delta] 年動かした先が移動範囲内か
bool canShiftPeriodYear({required int year, required int delta, int? maxYear}) {
  final target = year + delta;
  return target >= kAppPeriodMinYear &&
      target <= (maxYear ?? appPeriodMaxYear());
}

/// 3タブ（全体・月間分析・履歴）共通の AppBar 期間ヘッダー（KP-025）。
///
/// 「◀ ラベル ▶」の構成。ラベルのタップでピッカーを開き、左右の円ボタンで1期間ずつ送る。
/// 円ボタンは AppBar の裸アイコン規約（ボタンルール §4）の例外として
/// [IconOnlyButton]（直径24・枠なし）を使う。移動範囲の端では onPrevious / onNext を null にして非活性にする。
///
/// AppBar に置くときは、左にも歯車（actions）と同じ幅を取って左右を対称にすること
/// （`leading: SizedBox.shrink()`・`leadingWidth: 48`・`titleSpacing: 0`）。非対称だと
/// 長いラベルのとき NavigationToolbar がタイトルを歯車から離すため左へずらす。
/// それでも幅が足りない端末では、ずらさずに全体を縮小して中央に収める（FittedBox）。
class AppPeriodHeader extends StatelessWidget {
  const AppPeriodHeader({
    super.key,
    required this.label,
    this.subLabel,
    this.subLabelIsNumeric = false,
    required this.onTapLabel,
    required this.onPrevious,
    required this.onNext,
  });

  /// 期間の表示（「2026年 8 - 9月」等）
  final String label;

  /// 2段目の補足（「2026年度」「生活収支」等）。無ければ1段
  final String? subLabel;

  /// 2段目が数字主役なら true（sfUi）。和文主役なら false（noto）
  final bool subLabelIsNumeric;

  /// ラベルのタップ（ピッカーを開く）
  final VoidCallback? onTapLabel;

  /// 前の期間へ。null のとき非活性
  final VoidCallback? onPrevious;

  /// 次の期間へ。null のとき非活性
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final subStyle = subLabelIsNumeric
        ? context.textStyles.pageHeaderSubNumeric
        : context.textStyles.pageHeaderSubText;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PeriodArrowButton(
          key: const ValueKey('period_header_previous'),
          icon: AppIcons.periodPrev,
          semanticLabel: '前の期間',
          onTap: onPrevious,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapLabel,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedSwitcher(
              // グロナビのタブ切替と同じ時間・曲線で揃える
              duration: AppMotion.switchDuration,
              switchInCurve: AppMotion.switchInCurve,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Column(
                key: ValueKey('$label/${subLabel ?? ''}'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: context.textStyles.pageHeaderNumeric),
                  if (subLabel != null) Text(subLabel!, style: subStyle),
                ],
              ),
            ),
          ),
        ),
        _PeriodArrowButton(
          key: const ValueKey('period_header_next'),
          icon: AppIcons.periodNext,
          semanticLabel: '次の期間',
          onTap: onNext,
        ),
      ],
      ),
    );
  }
}

/// 期間送りの円ボタン。円（直径24）より広い 40×48 をタップ領域にする。
/// 円はラベルより目立たせないため小さくする（2026-09-14 ユーザーレビュー: 32→16→間をとって24）
class _PeriodArrowButton extends StatelessWidget {
  const _PeriodArrowButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // 円の外側のタップも同じ操作にする（円の内側は IconOnlyButton のインクが優先される）
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 48,
        child: Center(
          child: Semantics(
            label: semanticLabel,
            child: IconOnlyButton(
              icon: icon,
              onTap: onTap,
              size: 24,
              iconSize: 16,
              bordered: false,
            ),
          ),
        ),
      ),
    );
  }
}
