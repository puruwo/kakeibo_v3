import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';

/// カテゴリー一覧の行（KP-032）
///
/// カテゴリー設定の一覧行（アイコン／名前／項目／右端）を共通部品にしたもの。
/// **アプリ内のカテゴリー一覧はこの行で統一する**（全体ルール）。
/// 大カテゴリーの行にも小カテゴリーの行にも使う（小カテゴリーは大のアイコン・色を継承する）。
class CategoryListTile extends StatelessWidget {
  const CategoryListTile({
    super.key,
    required this.resourcePath,
    required this.colorCode,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.selected = false,
    this.titleFlexible = false,
  });

  /// カテゴリーアイコン（SVG）のアセットパス
  final String resourcePath;

  /// カテゴリー色（描画側で着色する）
  final String colorCode;

  /// 主ラベル（大カテゴリー名／小カテゴリー名）
  final String title;

  /// 副ラベル（小カテゴリー名のカンマ列挙など）。無ければ主ラベルの右は空く
  final String? subtitle;

  /// 右端（「＞」・チェック・「表示中」など）
  final Widget? trailing;

  final VoidCallback? onTap;

  /// false のとき薄く表示しタップできない（追加モードで表示中の項目など）
  final bool enabled;

  /// 選択中の行を淡い primary の地で示す
  final bool selected;

  /// 主ラベルを固定幅にせず余白いっぱいに広げる（副ラベルの無い小カテゴリー行）
  final bool titleFlexible;

  /// 画面幅に応じた行内テキストボックスの拡大分（カテゴリー設定の一覧と同じ計算）
  static double textBoxOffset(BuildContext context) {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    final offset = defaultWidth < 0 ? 0.0 : context.screenWidth - defaultWidth;
    return offset / 2;
  }

  /// 行の左右の余白（カテゴリー設定の一覧と同じ）
  static double sidePadding(BuildContext context) =>
      14.5 * context.screenHorizontalMagnification;

  @override
  Widget build(BuildContext context) {
    final leftsidePadding = sidePadding(context);
    final listSTextBoxOffset = textBoxOffset(context);
    final color = ColorCode.toColor(colorCode);
    final textColor = enabled
        ? context.colors.text
        : context.colors.textTertiary;
    final subColor = enabled
        ? context.colors.textSecondary
        : context.colors.textTertiary;

    final titleWidget = Text(
      title,
      style: context.textStyles.listTilePrimaryTitle.copyWith(color: textColor),
      overflow: TextOverflow.ellipsis,
    );

    final row = Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // アイコン（無着色の SVG にカテゴリー色を乗せる）
                Padding(
                  padding: const EdgeInsets.all(12.5),
                  child: Opacity(
                    opacity: enabled ? 1.0 : 0.35,
                    child: SvgPicture.asset(
                      resourcePath,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      semanticsLabel: 'categoryIcon',
                      width: 25,
                      height: 25,
                    ),
                  ),
                ),

                // 主ラベル
                if (titleFlexible)
                  Expanded(child: titleWidget)
                else
                  SizedBox(width: 90 + listSTextBoxOffset, child: titleWidget),

                // 副ラベル
                if (!titleFlexible)
                  Expanded(
                    child: Text(
                      subtitle ?? '',
                      style: context.textStyles.listTileSecondaryTitle.copyWith(
                        color: subColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // 右端
                Padding(
                  padding: const EdgeInsets.all(12.5),
                  child: trailing ?? const SizedBox(width: 18),
                ),
              ],
            ),
          ),
        ),

        // 区切り線
        Divider(
          thickness: 0.25,
          height: 0.25,
          indent: leftsidePadding + 50,
          endIndent: leftsidePadding,
          color: context.colors.separator,
        ),
      ],
    );

    if (!enabled || onTap == null) {
      return row;
    }
    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      color: selected ? context.colors.primaryTint : null,
      onTap: onTap,
      child: row,
    );
  }
}

/// カテゴリー一覧の凡例行（「カテゴリー／項目／詳細」など。KP-032）
///
/// カテゴリー設定の一覧と同じ組み方。[middle] を省くと左のラベルだけになる。
class CategoryListLegend extends StatelessWidget {
  const CategoryListLegend({
    super.key,
    required this.leading,
    this.middle,
    required this.trailing,
  });

  final String leading;
  final String? middle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final leftsidePadding = CategoryListTile.sidePadding(context);
    final listSTextBoxOffset = CategoryListTile.textBoxOffset(context);

    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: SizedBox(
                      width: 37 + 90 + listSTextBoxOffset,
                      child: Text(
                        leading,
                        style: context.textStyles.listTileLegendTitle,
                      ),
                    ),
                  ),
                  if (middle != null)
                    Text(
                      middle!,
                      style: context.textStyles.listTileLegendTitle,
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  trailing,
                  style: context.textStyles.listTileLegendTitle,
                ),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 0.25,
          height: 0.25,
          indent: leftsidePadding,
          endIndent: leftsidePadding,
          color: context.colors.separator,
        ),
      ],
    );
  }
}
