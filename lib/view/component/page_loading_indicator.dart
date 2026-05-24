import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';

/// ページ全体に被せる共通ローディング表示。
///
/// 各ページで複数の provider を一括ロードする際、全 provider が解決するまで
/// このウィジェットをページ body に置き換えて、各カードがバラバラに描画される
/// 「ぴょこぴょこ」を抑える。AnimatedSwitcher のフェード遷移中に裏のレンダリングが
/// 透けて見えないよう、Scaffold.backgroundColor と同じ色で背面を塗りつぶす。
class PageLoadingIndicator extends StatelessWidget {
  const PageLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: MyColors.secondarySystemBackground,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
