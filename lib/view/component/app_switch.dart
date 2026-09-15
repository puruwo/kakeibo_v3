import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// アプリ共通のスイッチ（KP-013）
///
/// 見た目は AppInsetRow.switchRow のもの（0.7 倍・枠線なし・つまみ onPrimary・
/// トラックは ON が primary / OFF が icon）。枠線の消去やつまみの色は AppTheme の
/// switchTheme に集約してあるため、ここでは Theme を新規生成しない。
/// 設定画面の「ダークモード」行とインセット行の両方で使う。
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// 非活性（onChanged が null）のときの不透明度（KP-026）
  ///
  /// トラック・つまみの色を固定しているため Switch 標準の非活性表現が効かず、
  /// 操作できる状態と見分けがつかない。スイッチ全体を薄くして非活性を示す。
  static const double disabledOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      child: Opacity(
        opacity: onChanged == null ? disabledOpacity : 1,
        child: Transform.scale(
          alignment: Alignment.centerRight,
          // Material のスイッチは行高 46 に対して大きいため縮小する
          scale: 0.7,
          child: Switch(
            activeTrackColor: context.colors.primary,
            inactiveTrackColor: context.colors.icon,
            thumbColor: WidgetStatePropertyAll(context.colors.onPrimary),
            value: value,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
