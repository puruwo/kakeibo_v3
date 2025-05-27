import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_manager.g.dart';

// アプリ全体でページ状態を管理するためのprovider
// PageContorollerを管理するproviderもあるが、カレンダーがビルドされていないとページ状態を変更できないため、
// この管理providerで全体管理する
@Riverpod(keepAlive: true)
class PageManagerNotifier extends _$PageManagerNotifier {
  @override
  int build() {
    // 最初のデータ
    const initialCenter = 500;
    return initialCenter;
  }

  void previousPage() {
    // 前のページに移動
    state = state - 1;
  }  

  void nextPage() {
    // 次のページに移動
    state = state + 1;
  }  
}