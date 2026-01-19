import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/component/card_container.dart';

/// 履歴リストタイル用の統一ウィジェット
///
/// 利用元はStringを渡すだけでOK。スタイリングは内部で定義。
///
/// 配置可能なスロット:
/// - [iconPath]: 左端のアイコン (SVGパス)
/// - [iconColor]: アイコンの色 (オプション)
/// - [primaryTitle]: メインタイトル (1行目左側)
/// - [secondaryTitle]: サブタイトル (1行目右側、オプション)
/// - [subtitleLeading]: サブタイトル行の左側 (2行目左側)
/// - [subtitleTrailing]: サブタイトル行の右側 (2行目右側、オプション)
/// - [priceLabel]: 値段ラベル (フォーマット済み)
/// - [isIncome]: 収入/支出フラグ
///
/// レイアウト構造:
/// ```
/// |-------------------------------------------------------|
/// | [icon] | [primaryTitle] [secondaryTitle]  | [price +/-] |
/// |        | [subtitleLeading] [subtitleTrailing] |           |
/// |-------------------------------------------------------|
/// ```
class HistoryListTile extends StatelessWidget {
  const HistoryListTile({
    super.key,
    required this.iconPath,
    this.iconColor,
    required this.primaryTitle,
    this.secondaryTitle,
    this.subtitleLeading,
    this.subtitleTrailing,
    required this.priceLabel,
    required this.isIncome,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.height = 69.0,
    this.bottomPadding = 8.0,
    this.priceWidth = 128.0,
  });

  /// アイコンのSVGパス
  final String iconPath;

  /// アイコンの色 (nullの場合はデフォルト色)
  final Color? iconColor;

  /// メインタイトル (1行目の左側) - 必須
  final String primaryTitle;

  /// サブタイトル (1行目の右側、オプション)
  final String? secondaryTitle;

  /// サブタイトル行の左側 (2行目の左側)
  final String? subtitleLeading;

  /// サブタイトル行の右側 (2行目の右側、オプション)
  final String? subtitleTrailing;

  /// フォーマット済みの値段ラベル
  final String priceLabel;

  /// 収入の場合はtrue ('+')、支出の場合はfalse ('-')
  final bool isIncome;

  /// タップ時のコールバック
  final VoidCallback? onTap;

  /// 長押し時のコールバック
  final VoidCallback? onLongPress;

  /// 背景色 (デフォルト: MyColors.quarternarySystemfill)
  final Color? backgroundColor;

  /// タイルの高さ (デフォルト: 69.0)
  final double height;

  /// 下部のパディング (デフォルト: 8.0)
  final double bottomPadding;

  /// 値段表示エリアの幅 (デフォルト: 125.0)
  final double priceWidth;

  @override
  Widget build(BuildContext context) {
    final screenHorizontalMagnification = context.screenHorizontalMagnification;
    final sidePadding = 14.5 * screenHorizontalMagnification;

    // アイコン
    final icon = SizedBox(
      height: 25,
      width: 25,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SvgPicture.asset(
          iconPath,
          colorFilter: iconColor != null
              ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
              : null,
          semanticsLabel: 'categoryIcon',
          width: 25,
          height: 25,
        ),
      ),
    );

    // 1行目: primaryTitle + secondaryTitle
    final hasFirstRow =
        primaryTitle.isNotEmpty || (secondaryTitle?.isNotEmpty ?? false);
    final firstRow = hasFirstRow
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200, minWidth: 70),
                child: Text(
                  primaryTitle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.listCardTitleLabel,
                ),
              ),
              if (secondaryTitle != null && secondaryTitle!.isNotEmpty)
                Text(
                  secondaryTitle!,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.listCardSecondaryTitle,
                ),
            ],
          )
        : null;

    // 2行目: subtitleLeading + subtitleTrailing
    final hasSecondRow = (subtitleLeading?.isNotEmpty ?? false) ||
        (subtitleTrailing?.isNotEmpty ?? false);
    final secondRow = hasSecondRow
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitleLeading != null && subtitleLeading!.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 70),
                  child: Text(
                    subtitleLeading!,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.listCardSecondaryTitle,
                  ),
                ),
              if (subtitleTrailing != null && subtitleTrailing!.isNotEmpty)
                Text(
                  subtitleTrailing!,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.listCardSecondaryTitle,
                ),
            ],
          )
        : null;

    // 値段表示
    // - 値段が短い場合: コンパクトに表示（左のRowが大きくなる）
    // - 値段がpriceWidthを超える場合: テキストサイズが縮小される
    final priceWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: priceWidth),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              priceLabel,
              textAlign: TextAlign.end,
              style: AppTextStyles.listCardPriceLabel,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isIncome ? '+' : '-',
          style: isIncome
              ? AppTextStyles.listCardPlusLabel
              : AppTextStyles.listCardMinusLabel,
        ),
      ],
    );

    return Padding(
      // タイル下のタイル間の余白
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: AppInkWell(
        borderRadius: appCardRadius,
        color: backgroundColor ?? MyColors.quarternarySystemfill,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左端: アイコンエリア
                icon,
                const SizedBox(width: 8),

                // 中央: タイトルエリア
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (firstRow != null) firstRow,
                      if (firstRow != null && secondRow != null)
                        const SizedBox(height: 4),
                      if (secondRow != null) secondRow,
                    ],
                  ),
                ),

                // 右端: 値段エリア
                priceWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
