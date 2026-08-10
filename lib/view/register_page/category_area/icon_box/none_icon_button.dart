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
      width: 62.2 * context.screenHorizontalMagnification,
      height: 34 * context.screenVerticalMagnification + 17 + 3 + 2.5,
    );
  }
}
