import 'package:flutter/material.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/component/app_floating_action_button.dart';

/// FAB下端のオフセット値を計算するユーティリティ。
/// グロナビ回避分は bottomNavClearance（正準ヘルパー）に集約する。
double fabBottomOf(BuildContext context) {
  return context.bottomNavClearance + kFloatingActionButtonMargin;
}

/// [child] の右下に pill 形 FAB を重ねる Stack ラッパー。
class AppFabStack extends StatelessWidget {
  const AppFabStack({
    super.key,
    required this.child,
    required this.fabLabel,
    required this.onFabTap,
    this.fabIcon = Icons.add_rounded,
  });

  final Widget child;
  final String fabLabel;
  final VoidCallback onFabTap;
  final IconData fabIcon;

  @override
  Widget build(BuildContext context) {
    final bottom = fabBottomOf(context);
    return Stack(
      children: [
        child,
        Positioned(
          right: 16,
          bottom: bottom,
          child: AppFloatingActionButton(
            icon: fabIcon,
            label: fabLabel,
            onTap: onFabTap,
          ),
        ),
      ],
    );
  }
}
