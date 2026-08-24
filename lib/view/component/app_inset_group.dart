import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';

/// インセットグループの角丸（iOS設定アプリのグループ化リストに相当する見た目）
final BorderRadius appInsetGroupRadius = BorderRadius.circular(14);

/// インセットグループの行の高さ
const double kAppInsetRowHeight = 46;

/// 行の左端インデント（区切り線もこの位置から始まる）
const double kAppInsetRowIndent = 16;

/// 行の先頭アイコンのサイズ
const double kAppInsetRowIconSize = 18;

/// 行の増減でグループの高さが変わるときのアニメーション時間
///
/// 固定費トグルの展開・収縮で使う（レイアウトジャンプを防ぐ。仕様 §6.8）。
const Duration kAppInsetGroupResizeDuration = Duration(milliseconds: 200);

/// 設定アプリ風のインセットグループ
///
/// 背景: `fillQuaternary` ／ 枠線: 1px `surfaceBorder` ／ 角丸: 14px。
/// 行同士は 0.5px の `separator` で区切る（左端は [kAppInsetRowIndent] 分インデント）。
/// [header] を渡すとグループの上に見出しを置く。
///
/// 登録シート・編集シート・固定費の設定画面で共用する（仕様 §8.5）。
class AppInsetGroup extends StatelessWidget {
  const AppInsetGroup({
    super.key,
    required this.children,
    this.header,
    this.note,
  });

  /// グループに並べる行（[AppInsetRow] を想定）
  final List<Widget> children;

  /// 任意のグループ見出し
  final String? header;

  /// グループの下に添える補足文
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Text(header!, style: AppTextStyles.insetGroupHeader),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.fillQuaternary,
            border: Border.all(color: context.colors.surfaceBorder),
            borderRadius: appInsetGroupRadius,
          ),
          child: ClipRRect(
            borderRadius: appInsetGroupRadius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _withSeparators(context),
            ),
          ),
        ),
        if (note != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
            child: Text(note!, style: AppTextStyles.insetGroupNote),
          ),
      ],
    );
  }

  /// 行の間に 0.5px の区切り線を挟む（末尾の行の下には引かない）
  List<Widget> _withSeparators(BuildContext context) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i != children.length - 1) {
        result.add(
          Padding(
            padding: const EdgeInsets.only(left: kAppInsetRowIndent),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: context.colors.separator,
            ),
          ),
        );
      }
    }
    return result;
  }
}

/// [AppInsetGroup] に並べる1行
///
/// 構成は「アイコン18 ／ ラベル ／ 値 ／ 右端の操作部品」で共通。
/// 右端に何を置くかで4つの型を使い分ける。
/// - [AppInsetRow.navigation] 右矢印つき。タップで別画面・シートを開く
/// - [AppInsetRow.switchRow] スイッチ
/// - [AppInsetRow.textField] インラインのテキスト入力
/// - [AppInsetRow.display] 表示のみ（操作不可）
class AppInsetRow extends StatelessWidget {
  /// ナビゲーション行（右矢印つき）
  const AppInsetRow.navigation({
    super.key,
    this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.valueWidget,
    required this.onTap,
    this.iconColor,
    this.leading,
    // 選択して閉じる行など、遷移ではない行では右矢印を出さない
    this.showChevron = true,
  })  : _type = _AppInsetRowType.navigation,
        switchValue = null,
        onSwitchChanged = null,
        controller = null,
        hintText = null,
        keyboardType = null,
        inputFormatters = null,
        maxLength = null,
        onChanged = null,
        textAlign = TextAlign.right;

  /// スイッチ行
  const AppInsetRow.switchRow({
    super.key,
    this.icon,
    required this.label,
    required bool this.switchValue,
    required ValueChanged<bool> this.onSwitchChanged,
    this.iconColor,
    this.leading,
  })  : _type = _AppInsetRowType.switchRow,
        showChevron = false,
        value = null,
        valueColor = null,
        valueWidget = null,
        onTap = null,
        controller = null,
        hintText = null,
        keyboardType = null,
        inputFormatters = null,
        maxLength = null,
        onChanged = null,
        textAlign = TextAlign.right;

  /// テキストフィールド行
  const AppInsetRow.textField({
    super.key,
    this.icon,
    required this.label,
    required TextEditingController this.controller,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.iconColor,
    this.leading,
  })  : _type = _AppInsetRowType.textField,
        showChevron = false,
        value = null,
        valueColor = null,
        valueWidget = null,
        onTap = null,
        switchValue = null,
        onSwitchChanged = null,
        textAlign = TextAlign.right;

  /// 表示のみの行
  const AppInsetRow.display({
    super.key,
    this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.valueWidget,
    this.iconColor,
    this.leading,
  })  : _type = _AppInsetRowType.display,
        showChevron = false,
        onTap = null,
        switchValue = null,
        onSwitchChanged = null,
        controller = null,
        hintText = null,
        keyboardType = null,
        inputFormatters = null,
        maxLength = null,
        onChanged = null,
        textAlign = TextAlign.right;

  final _AppInsetRowType _type;

  /// 行の先頭アイコン（省略時はアイコン枠だけ確保してラベル位置を揃える）
  final IconData? icon;

  /// アイコンの色（省略時は textSecondary）
  final Color? iconColor;

  /// アイコン枠に置く任意のウィジェット（SVGのカテゴリーアイコン等）
  ///
  /// 指定すると [icon] より優先する。
  final Widget? leading;

  /// 遷移行で右矢印を表示するか
  final bool showChevron;

  /// 行のラベル
  final String label;

  /// 右寄せで表示する値
  final String? value;

  /// 値の文字色（省略時は text。未設定の値を薄く見せたいときに使う）
  final Color? valueColor;

  /// 値の位置に置く任意のウィジェット（色スウォッチ・アイコンプレビュー等）
  ///
  /// navigation / display 行で指定でき、[value] より優先する。
  final Widget? valueWidget;

  /// テキストフィールド行の変更通知
  final ValueChanged<String>? onChanged;

  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: kAppInsetRowHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kAppInsetRowIndent, 0, 12, 0),
        child: Row(
          children: [
            SizedBox(
              width: kAppInsetRowIconSize,
              child: leading ??
                  (icon == null
                      ? null
                      : Icon(
                          icon,
                          size: kAppInsetRowIconSize,
                          color: iconColor ?? context.colors.textSecondary,
                        )),
            ),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.insetGroupLabel),
            const SizedBox(width: 10),
            Expanded(child: _buildTrailing(context)),
          ],
        ),
      ),
    );

    if (_type == _AppInsetRowType.navigation && onTap != null) {
      // グループ側で角丸をクリップ済みなので、行のリップルは角丸なしにする
      return AppInkWell(
        borderRadius: BorderRadius.zero,
        onTap: onTap,
        child: row,
      );
    }
    return row;
  }

  /// 行の右側（値・矢印・スイッチ・入力欄）を組み立てる
  Widget _buildTrailing(BuildContext context) {
    switch (_type) {
      case _AppInsetRowType.navigation:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: valueWidget ?? _buildValueText(context)),
            if (showChevron) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: context.colors.textTertiary,
              ),
            ],
          ],
        );
      case _AppInsetRowType.display:
        return Align(
          alignment: Alignment.centerRight,
          child: valueWidget ?? _buildValueText(context),
        );
      case _AppInsetRowType.switchRow:
        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 45,
            child: Theme(
              // ThemeDataを上書きして、トグルOnの時のborderを透明にする
              data: ThemeData(useMaterial3: true).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(outline: Colors.transparent),
              ),
              // 大きさを小さくするためにTransform.scaleを使用
              child: Transform.scale(
                alignment: Alignment.centerRight,
                scale: 0.7,
                child: Switch(
                  activeTrackColor: context.colors.primary,
                  inactiveTrackColor: context.colors.icon,
                  thumbColor: WidgetStateProperty.all(Colors.white),
                  value: switchValue!,
                  onChanged: onSwitchChanged,
                ),
              ),
            ),
          ),
        );
      case _AppInsetRowType.textField:
        return TextFormField(
          controller: controller,
          textAlign: textAlign,
          textAlignVertical: TextAlignVertical.center,
          style: AppTextStyles.insetGroupValue,
          cursorColor: context.colors.primary,
          cursorWidth: 2,
          minLines: 1,
          maxLines: 1,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          keyboardAppearance: Brightness.dark,
          buildCounter: (
            BuildContext context, {
            required int currentLength,
            required bool isFocused,
            required int? maxLength,
          }) {
            return null;
          },
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: AppTextStyles.insetGroupPlaceholder,
          ),
          onChanged: onChanged,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
          },
        );
    }
  }

  Widget _buildValueText(BuildContext context) {
    final style = valueColor == null
        ? AppTextStyles.insetGroupValue
        : AppTextStyles.insetGroupValue.copyWith(color: valueColor);
    return Text(
      value ?? '',
      textAlign: TextAlign.right,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

/// [AppInsetRow] の行の型
enum _AppInsetRowType { navigation, switchRow, textField, display }
