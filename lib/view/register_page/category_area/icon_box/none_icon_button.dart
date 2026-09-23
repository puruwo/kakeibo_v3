import 'package:flutter/material.dart';

import 'package:kakeibo/util/extension/media_query_extension.dart';

/// 空きスロット。ADR-020: 何も描画しない（背景色での塗りつぶしもしない）。
/// レイアウト上の footprint だけは [NormalIconButton]/[SelectedIconButton] と揃え、
/// 行の高さが埋まっているセルと空セルで変わらないようにする。
class NoneIconBox extends StatelessWidget {
  const NoneIconBox({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 幅は NormalIconButton のラベル幅と同じ式にする（違うと最後の行だけ列がずれる）
      width: 62.2 * ((context.screenHorizontalMagnification - 1) / 5 + 1),
      height: 34 * context.screenVerticalMagnification + 30,
    );
  }
}
