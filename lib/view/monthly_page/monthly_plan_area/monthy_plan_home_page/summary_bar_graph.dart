import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

    // 編集中は合計とdenominatorの更新タイミングがずれるため、
    // 合計がdenominatorを超えてもバーが幅をはみ出さないよう分母を補正する
    final total = amounts.fold<int>(0, (sum, e) => sum + e);
    final effectiveDenominator = total > denominator ? total : denominator;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      // アニメーション中にセグメント幅の合計が一時的に最大幅を超えても
      // RenderFlexのoverflowにならないよう、Rowには無制限幅を与えてクリップする
      child: SizedBox(
        width: maxGraphWidth,
        height: 8.5,
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: 0,
          maxWidth: double.infinity,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            ...List.generate(amounts.length, (i) {
              final ratio = amounts[i] / effectiveDenominator;
              return AnimatedContainer(
                height: 8.5,
                width: isBuilt.value ? ratio * maxGraphWidth : 0,
                color: ColorCode.toColor(colors[i]),
                duration: const Duration(milliseconds: 500),
              );
            }),
          ]),
        ),
      ),
    );
  }
}
