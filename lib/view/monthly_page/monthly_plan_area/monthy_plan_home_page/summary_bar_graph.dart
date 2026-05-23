import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';

/// 予算ページ用の棒グラフウィジェット
/// 生の金額リストとdenominatorを受け取り、ウィジェット内でratioを計算する
/// グレー背景バーなし
class SummaryBarGraph extends HookConsumerWidget {
  const SummaryBarGraph({
    super.key,
    required this.amounts,
    required this.colors,
    required this.denominator,
    required this.maxGraphWidth,
  });

  final List<int> amounts;
  final List<String> colors;
  final int denominator;
  final double maxGraphWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ビルドが完了したかどうか
    final isBuilt = useState(false);

    // ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isBuilt.value = true;
    });

    if (denominator == 0 || amounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 0,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ...List.generate(amounts.length, (i) {
            final ratio = amounts[i] / denominator;
            return AnimatedContainer(
              height: 8.5,
              width: isBuilt.value ? ratio * maxGraphWidth : 0,
              color: MyColors().getColorFromHex(colors[i]),
              duration: const Duration(milliseconds: 500),
            );
          }),
        ]),
      ),
    );
  }
}
