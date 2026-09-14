import 'package:flutter/material.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';

/// カテゴリー編集の行頭に置く削除ボタン（KP-024 案B）
///
/// 旧・表示チェックボックスの位置に置く赤い丸マイナス。
/// [onTap] が null のときは非活性（最後の1件・既定カテゴリーなど、削除できない行）。
class CategoryDeleteRowButton extends StatelessWidget {
  const CategoryDeleteRowButton({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(
        AppIcons.deleteRow,
        size: 22,
        color: onTap == null
            ? context.colors.textTertiary
            : context.colors.danger,
      ),
    );

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: '削除',
      child: onTap == null
          ? icon
          : AppInkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap!,
              child: icon,
            ),
    );
  }
}
