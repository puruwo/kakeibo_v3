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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
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
    );
  }
}
