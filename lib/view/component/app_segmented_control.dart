import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';

/// セグメンテッドコントロールのトラックの角丸
final BorderRadius appSegmentedControlRadius = BorderRadius.circular(10);

/// セグメンテッドコントロールの選択中セグメントの角丸
final BorderRadius _segmentRadius = BorderRadius.circular(8);

/// iOS風のセグメンテッドコントロール（2件以上の排他選択）
///
/// 背景: `fillQuaternary` ／ 枠線: 1px `surfaceBorder` ／ 角丸: 10px。
/// 選択中セグメントだけ `surfaceElevated2` の角丸8pxで塗り分ける。
/// 予想額の入力シート（自動で算出｜自分で設定。仕様 §6.9）で使う。
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  /// 各セグメントのラベル（左から順に並ぶ）
  final List<String> labels;

  /// 選択中セグメントの位置
  final int selectedIndex;

  /// セグメントがタップされたときに選択位置を返す
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.fillQuaternary,
        border: Border.all(color: context.colors.surfaceBorder),
        borderRadius: appSegmentedControlRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i != 0) const SizedBox(width: 3),
              Expanded(
                child: _Segment(
                  label: labels[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onChanged(i),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// セグメント1つ
class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      borderRadius: _segmentRadius,
      color: isSelected ? context.colors.surfaceElevated2 : Colors.transparent,
      onTap: onTap,
      child: SizedBox(
        height: 34,
        child: Center(
          child: Text(
            label,
            style: isSelected
                ? AppTextStyles.segmentedSelectedLabel
                : AppTextStyles.segmentedLabel,
          ),
        ),
      ),
    );
  }
}
